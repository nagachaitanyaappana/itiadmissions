package com.server.backend.service.Auth;

import com.server.backend.Repository.LoginUserRepository;
import com.server.backend.entity.LoginUser;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);
    private volatile Boolean bcryptMigrationSchemaSupported;

    private final LoginUserRepository repo;
    private final JdbcTemplate jdbc;
    private final JwtTokenService jwtTokens;

    public AuthService(LoginUserRepository repo, JdbcTemplate jdbc, JwtTokenService jwtTokens) {
        this.repo = repo;
        this.jdbc = jdbc;
        this.jwtTokens = jwtTokens;
    }

    public Map<String, Object> login(String username, String rawPassword, String ip, String sessionId) {
        Map<String, Object> res = new HashMap<>();
        if (username == null || username.isBlank() || rawPassword == null || rawPassword.isEmpty()) {
            res.put("success", false);
            res.put("message", "Invalid credentials");
            return res;
        }

        LoginUser user = repo.findByUserName(username.trim());
        if (user == null) {
            res.put("success", false);
            res.put("message", "Invalid credentials");
            return res;
        }

        if (Boolean.FALSE.equals(user.getStatus())) {
            res.put("success", false);
            res.put("message", "Account is inactive. Contact administrator.");
            return res;
        }

        if (!passwordMatches(user, rawPassword)) {
            res.put("success", false);
            res.put("message", "Invalid credentials");
            return res;
        }

        // Upgrade legacy credentials only after inspecting the live PostgreSQL
        // schema. If the columns cannot safely store BCrypt and clear plaintext,
        // the valid login succeeds and the migration is skipped.
        upgradeLegacyPasswordIfSupported(user, rawPassword);

        res.put("success", true);
        res.put("message", "Login successful");
        res.put("username", user.getUserName());
        res.put("roleId", user.getRoleId());
        res.put("insCode", user.getDistCode());
        res.put("fullName", user.getFullName());

        // ---- login history (best effort; never blocks login) ----
        try {
            jdbc.update("INSERT INTO public.login_history (uname, logindatetime, ipaddress, sessionid, slno, login_status) " +
                        "SELECT ?, now(), ?, ?, COALESCE(MAX(slno),0)+1, 'S' FROM public.login_history",
                    user.getUserName(), ip == null ? "" : ip,
                    sessionId == null || sessionId.isBlank() ? UUID.randomUUID().toString() : sessionId);

            res.put("loginCount", jdbc.queryForObject(
                    "SELECT count(*) FROM public.login_history WHERE uname = ?", Integer.class, user.getUserName()));

            res.put("lastLogins", jdbc.queryForList(
                    "SELECT logindatetime FROM public.login_history WHERE uname = ? ORDER BY logindatetime DESC LIMIT 5",
                    String.class, user.getUserName()));
        } catch (Exception ignored) {
            res.put("loginCount", 0);
            res.put("lastLogins", List.of());
        }

        // ITI name for role-4 users (ins_code = iti code). Only ITI logins hold an ITI code:
        // role 3 (district) holds a district code, and 7 other roles hold neither, so looking
        // those up in public.iti just produced a bogus row for the navbar.
        res.put("itiName", "");
        Integer roleId = user.getRoleId();
        if (roleId != null && roleId == 4
                && user.getDistCode() != null && !user.getDistCode().isBlank()) {
            try {
                String itiName = jdbc.query(
                        "SELECT iti_name FROM public.iti WHERE CAST(iti_code AS text) = ? LIMIT 1",
                        rs -> { rs.next(); return rs.getString(1); }, user.getDistCode());
                res.put("itiName", itiName == null ? "" : itiName);
            } catch (Exception ignored) {
                res.put("itiName", "");
            }
        }

        // District name for role-3 users, mirroring itiName above: a district login holds a
        // district code in ins_code. Without this the district pages had no name to show and fell
        // back to the officer's username (or "N/A" where they read localStorage.displayName, which
        // the session-based login never writes).
        res.put("distName", "");
        if (roleId != null && roleId == 3
                && user.getDistCode() != null && !user.getDistCode().isBlank()) {
            try {
                String distName = jdbc.query(
                        "SELECT dist_name FROM public.dist_mst WHERE dist_code = ? LIMIT 1",
                        rs -> { rs.next(); return rs.getString(1); }, user.getDistCode());
                res.put("distName", distName == null ? "" : distName);
            } catch (Exception ignored) {
                res.put("distName", "");
            }
        }
        JwtTokenService.IssuedToken issued = jwtTokens.issue(
                user.getUserName(), user.getRoleId(), user.getDistCode());
        res.put("accessToken", issued.value());
        res.put("expiresAt", issued.expiresAt().toString());
        res.put("tokenType", "Bearer");
        return res;
    }

    /**
     * Password verification strategy:
     *  1. BCrypt (preferred) - hash_password starting with $2
     *  2. Legacy plaintext 'password' column equality
     *  3. Legacy MD5 variants of the raw password against hash_password
     * New / changed passwords must always be stored as bcrypt.
     */
    private boolean passwordMatches(LoginUser user, String raw) {
        String stored = user.getHashPassword();

        if (stored != null && !stored.isBlank()) {
            stored = stored.trim();
            if (stored.startsWith("$2")) {
                try {
                    return BCrypt.checkpw(raw, stored);
                } catch (IllegalArgumentException e) {
                    return false;
                }
            }
            // legacy md5 variants kept for backward compatibility only
            String h1 = md5(raw);
            if (stored.equalsIgnoreCase(h1)) return true;                       // md5(pwd)
            if (stored.equalsIgnoreCase(md5(h1))) return true;                  // md5(md5(pwd))
        }

        // legacy plaintext fallback
        String plain = user.getPassword();
        return plain != null && !plain.isBlank() && plain.equals(raw);
    }

    private void upgradeLegacyPasswordIfSupported(LoginUser user, String rawPassword) {
        if (user.getSlno() == null) return;
        String oldHash = user.getHashPassword();
        String oldPlain = user.getPassword();
        boolean hasPlaintext = oldPlain != null && !oldPlain.isBlank();
        boolean hasBcrypt = oldHash != null && oldHash.trim().startsWith("$2");
        if (hasBcrypt && !hasPlaintext) return;
        if (!schemaSupportsSafeBcryptMigration()) return;

        String replacementHash = hasBcrypt ? oldHash.trim() : toBcrypt(rawPassword);
        try {
            int updated = jdbc.update(
                    "UPDATE public.login_users SET hash_password = ?, password = NULL "
                            + "WHERE slno = ? AND COALESCE(hash_password, '') = ? "
                            + "AND COALESCE(password, '') = ?",
                    replacementHash, user.getSlno(),
                    oldHash == null ? "" : oldHash,
                    oldPlain == null ? "" : oldPlain);
            if (updated == 1) log.info("Migrated one legacy login credential to BCrypt");
        } catch (org.springframework.dao.DataAccessException ex) {
            // A concurrent password change, permission restriction, or schema
            // drift must not turn a valid login into an outage.
            log.warn("BCrypt password migration was skipped; login remains successful");
        }
    }

    /**
     * hash_password must accept at least 60 characters (or be TEXT), and the
     * legacy password column must be nullable so it can be cleared atomically.
     */
    private boolean schemaSupportsSafeBcryptMigration() {
        Boolean cached = bcryptMigrationSchemaSupported;
        if (cached != null) return cached;
        try {
            List<Map<String, Object>> columns = jdbc.queryForList(
                    "SELECT column_name, data_type, character_maximum_length, is_nullable "
                            + "FROM information_schema.columns "
                            + "WHERE table_schema = 'public' AND table_name = 'login_users' "
                            + "AND column_name IN ('hash_password', 'password')");
            Map<String, Map<String, Object>> byName = new HashMap<>();
            for (Map<String, Object> column : columns) {
                byName.put(String.valueOf(column.get("column_name")).toLowerCase(), column);
            }
            Map<String, Object> hash = byName.get("hash_password");
            Map<String, Object> plain = byName.get("password");
            if (hash == null || plain == null) {
                bcryptMigrationSchemaSupported = Boolean.FALSE;
                return false;
            }
            String type = String.valueOf(hash.get("data_type"));
            Object lengthValue = hash.get("character_maximum_length");
            boolean enoughSpace = "text".equalsIgnoreCase(type)
                    || (lengthValue instanceof Number n && n.intValue() >= 60);
            boolean canClearPlaintext = "YES".equalsIgnoreCase(String.valueOf(plain.get("is_nullable")));
            boolean supported = enoughSpace && canClearPlaintext;
            bcryptMigrationSchemaSupported = supported;
            if (!supported) {
                log.warn("BCrypt password migration is disabled because login_users columns are not schema-compatible");
            }
            return supported;
        } catch (org.springframework.dao.DataAccessException ex) {
            log.warn("BCrypt password migration is disabled because the login_users schema could not be inspected");
            return false;
        }
    }

    /** Upgrade a legacy account to bcrypt. Returns the bcrypt hash to store in hash_password. */
    public String toBcrypt(String rawPassword) {
        return BCrypt.hashpw(rawPassword, BCrypt.gensalt());
    }

    private String md5(String s) {
        try {
            byte[] d = MessageDigest.getInstance("MD5").digest(s.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(32);
            for (byte b : d) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
}
