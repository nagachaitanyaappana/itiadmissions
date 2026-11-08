package com.server.backend.service.Auth;

import com.server.backend.Repository.LoginUserRepository;
import com.server.backend.entity.LoginUser;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.bcrypt.BCrypt;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class AuthServiceTest {

    private static final String PASSWORD = "legacy-test-password";
    private static final JwtTokenService TOKENS = new JwtTokenService(
            Base64.getEncoder().encodeToString(new byte[32]), "itiadmissions");

    @Test
    void migratesLegacyMd5OnlyWhenLiveSchemaCanStoreBcryptAndClearPlaintext() throws Exception {
        LoginUserRepository repository = mock(LoginUserRepository.class);
        JdbcTemplate jdbc = mock(JdbcTemplate.class);
        LoginUser user = legacyUser();
        when(repository.findByUserName("test-user")).thenReturn(user);
        when(jdbc.queryForList(contains("information_schema.columns"))).thenReturn(compatibleSchema());
        stubLoginHistory(jdbc);

        AuthService service = new AuthService(repository, jdbc, TOKENS);
        Map<String, Object> result = service.login("test-user", PASSWORD, "127.0.0.1", "test-session");

        assertEquals(Boolean.TRUE, result.get("success"));
        assertNotNull(TOKENS.verify((String) result.get("accessToken")));
        org.mockito.ArgumentCaptor<Object[]> args = org.mockito.ArgumentCaptor.forClass(Object[].class);
        verify(jdbc).update(contains("SET hash_password = ?, password = NULL"), args.capture());
        String upgradedHash = (String) args.getValue()[0];
        assertTrue(upgradedHash.startsWith("$2"));
        assertTrue(BCrypt.checkpw(PASSWORD, upgradedHash));
    }

    @Test
    void keepsLoginWorkingButSkipsMigrationWhenHashColumnIsTooShort() {
        LoginUserRepository repository = mock(LoginUserRepository.class);
        JdbcTemplate jdbc = mock(JdbcTemplate.class);
        when(repository.findByUserName("test-user")).thenReturn(legacyUser());
        when(jdbc.queryForList(contains("information_schema.columns"))).thenReturn(incompatibleSchema());
        stubLoginHistory(jdbc);

        AuthService service = new AuthService(repository, jdbc, TOKENS);
        Map<String, Object> result = service.login("test-user", PASSWORD, "127.0.0.1", "test-session");

        assertEquals(Boolean.TRUE, result.get("success"));
        verify(jdbc, never()).update(contains("SET hash_password = ?, password = NULL"), any(Object[].class));
    }

    private static LoginUser legacyUser() {
        LoginUser user = new LoginUser();
        user.setSlno(42);
        user.setUserName("test-user");
        user.setRoleId(2);
        user.setStatus(Boolean.TRUE);
        user.setHashPassword(md5(PASSWORD));
        user.setPassword(null);
        return user;
    }

    private static List<Map<String, Object>> compatibleSchema() {
        return List.of(
                Map.of("column_name", "hash_password", "data_type", "character varying",
                        "character_maximum_length", 255, "is_nullable", "NO"),
                Map.of("column_name", "password", "data_type", "character varying",
                        "character_maximum_length", 255, "is_nullable", "YES"));
    }

    private static List<Map<String, Object>> incompatibleSchema() {
        return List.of(
                Map.of("column_name", "hash_password", "data_type", "character varying",
                        "character_maximum_length", 32, "is_nullable", "NO"),
                Map.of("column_name", "password", "data_type", "character varying",
                        "character_maximum_length", 255, "is_nullable", "YES"));
    }

    private static void stubLoginHistory(JdbcTemplate jdbc) {
        when(jdbc.update(anyString(), any(Object[].class))).thenReturn(1);
        when(jdbc.queryForObject(contains("SELECT count(*) FROM public.login_history"),
                eq(Integer.class), any(Object[].class))).thenReturn(1);
        when(jdbc.queryForList(contains("SELECT logindatetime FROM public.login_history"),
                eq(String.class), any(Object[].class))).thenReturn(List.of());
    }

    private static String md5(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("MD5")
                    .digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(32);
            for (byte b : digest) hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (Exception ex) {
            throw new IllegalStateException(ex);
        }
    }
}
