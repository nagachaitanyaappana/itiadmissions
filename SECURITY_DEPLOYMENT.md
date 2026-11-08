# Security deployment and verification notes

This document describes the security boundary implemented by the `security-hardening` branch. It is not a certification that a production deployment is secure: the actual host/network rules and credential rotation must still be completed by the operator.

## Request architecture

Browser requests use the same-origin Frontend gateway:

```text
Browser
  |  Frontend session cookie / official access-token cookie
  v
Frontend (/backend/**)
  |  X-Internal-Service-Key + optional Bearer access token
  v
Backend (private listener)
  |
  v
PostgreSQL
```

Do not publish the Backend port to the Internet. The Backend binds to loopback by default with `BACKEND_BIND_ADDRESS=127.0.0.1`. If Frontend and Backend are on separate hosts, bind Backend to a private interface and configure the host firewall/security group to accept the Backend port from the Frontend host only. Do not use a public Backend URL.

The gateway uses an explicit public-candidate route allowlist. Existing-candidate reads/edits are bound to a Frontend HTTP session only after DOB + SSC hall-ticket verification; the session identifier is rotated at that privilege change and the candidate authorization expires after 30 minutes. Official routes require the short-lived official JWT cookie. Every Backend application endpoint requires the trusted Frontend service credential, regardless of whether an `Origin` header is present. Only health and framework error paths are excluded from the internal service credential. Backend API documentation also requires that credential; legacy routes such as `/admission-timings` and `/checkRegOrNot` are protected too.

## Required configuration

Keep secrets in each service's local `.env` or deployment secret manager. Never commit them, put them in JSP/JavaScript, or paste them into an issue or chat.

### Backend

- `APP_JWT_SECRET`: Base64-encoded 32 random bytes or stronger. Used only by Backend to sign and verify access tokens.
- `INTERNAL_API_SECRET`: a separate random secret of at least 32 characters. Must match the Frontend value exactly.
- `BACKEND_BIND_ADDRESS`: defaults to `127.0.0.1` for same-host deployments. For a split-host deployment, use a private interface address and firewall the port to Frontend only.
- Existing database settings (`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`) remain in Backend's private configuration.

### Frontend

- `BACKEND_URL`: internal Backend URL, e.g. `http://127.0.0.1:5050` for same-host development.
- `INTERNAL_API_SECRET`: the same random value as Backend's `INTERNAL_API_SECRET`.
- `SESSION_COOKIE_SECURE=true` in both services when the public Frontend is served over HTTPS. Keep it `false` only for local HTTP development.
- `DEV_LOGIN_ENABLED=false` outside a trusted local development environment.

For local Windows PowerShell 5.1, generate two independent values without printing or sharing existing secrets:

```powershell
$bytes = New-Object byte[] 32
$rng = [Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($bytes)
$jwtSecret = [Convert]::ToBase64String($bytes)
$internalSecret = [Guid]::NewGuid().ToString("N") + [Guid]::NewGuid().ToString("N")
$rng.Dispose()
# Add APP_JWT_SECRET only to Backend\.env.
# Add the same INTERNAL_API_SECRET value to Backend\.env and Frontend\.env.
# Do not commit either .env file.
```

Use the deployment platform's secret manager in production. Coordinate an internal-secret rotation across both services; rotate the JWT secret only with a plan to invalidate existing access tokens and require users to sign in again.

## Browser/API protections

- Browser-facing API URLs are rendered as the same-origin `/backend` gateway path. Do not put `BACKEND_URL` in client-side code.
- A global Frontend request interceptor rejects every unsafe method unless exactly one `Origin` header matches the request scheme/host/port, or (only when `Origin` is absent) exactly one `Sec-Fetch-Site: same-origin` header is present. Duplicate, malformed, cross-origin and missing-origin metadata fail closed. The `/backend/**` gateway applies the same check again. The Frontend is configured to honor trusted reverse-proxy forwarding headers; only the actual edge proxy should be allowed to set those headers. Postman/API clients testing writes must send `Origin: http://localhost:5051` (or the exact deployed Frontend origin); never send the internal service secret from a client.
- The gateway forwards only selected request/response headers and injects the internal service credential itself. Browser-supplied identity headers are not forwarded.
- District and ITI verification/trade/shift-unit routes derive organization scope from signed JWT claims. Candidate record reads/edits are bound to the verified candidate registration ID in the Frontend session.
- Public candidate creation accepts new records only. Existing registration edits use the verified-candidate path. Forgot-registration-ID lookup requires a server-verified captcha plus DOB and SSC hall-ticket number, returns only the registration ID, and does not create an authenticated candidate session.
- Candidate photographs are limited to 5 MB and 12 megapixels, then validated by image signature/decoding and re-encoded before persistence. The Frontend gateway has matching multipart limits and lazy multipart parsing so it can forward the upload body.

## Password migration

Legacy plaintext/MD5 verification remains temporarily for backward compatibility. After a successful legacy login, Backend inspects the live PostgreSQL `information_schema` before attempting migration. It migrates only if `hash_password` can store at least 60 characters (or is `TEXT`) and `password` is nullable, then atomically stores BCrypt and clears plaintext. If the live schema is incompatible or cannot be inspected, login still succeeds and migration is skipped. Review the migration warning and plan a database schema change before expecting every legacy account to migrate.

## Static analysis and dependency reports

- Gitleaks scans the pull-request diff or latest pushed commit for accidental secrets. It does not certify earlier Git history; run a full-history scan after the known historical database credential is rotated and the coordinated history-cleanup decision is completed.
- Trivy scans Maven/npm dependencies and configuration for high/critical vulnerabilities; its JSON report is retained as a workflow artifact.
- CodeQL analyzes Java and JavaScript/TypeScript using extended security queries; its SARIF report is retained as a workflow artifact.
- The current Trivy report for both Maven modules contains no CRITICAL/HIGH dependency vulnerabilities. CodeQL is retained as SARIF for review; its static findings are not automatically treated as a clean bill of health. The latest reviewed report included query-parameter-to-fixed-Backend-URL SSRF taint paths, backend POST handlers protected by the Frontend gateway/internal-service boundary, route-policy taint paths, and quality findings. Confirm any future SSRF/CSRF finding against the actual sink and request boundary instead of suppressing it blindly.
- The CodeQL run reviewed for this change reported no `java/sql-injection` findings. The manually reviewed dynamic SQL in the candidate registration service uses bound parameters for user values; the only dynamic table identifier is derived from a parsed numeric admission-cycle year, and the uniqueness-query column names are fixed internal literals. Continue reviewing SQL whenever query construction changes.
- The ReDoS-prone hstore parser now uses possessive quantifiers; user-supplied log fields were removed from warning/info messages; unpinned CDN script includes were replaced by local assets. The vendored SheetJS browser library was upgraded from 0.17.0 to the official 0.20.3 build, with its Apache-2.0 notice and a pinned SHA-256 checksum verified in CI. This addresses SheetJS CE CVE-2023-30533 (affected through 0.19.2) and CVE-2024-22363 (affected through 0.20.1). A scan is not proof of safety. Review findings and update vulnerable dependencies before production release.

## Operational tasks not performed by this PR

1. Rotate the PostgreSQL credential if it was ever committed in repository history. Removing it from the current file does not revoke it.
2. Decide whether historical Git history must be rewritten. Coordinate this with all collaborators and clones; do not rewrite shared history without an explicit maintenance window.
3. Apply private network/firewall rules in the actual hosting environment and verify that Backend is not reachable from public clients.
4. Set HTTPS, trusted reverse-proxy forwarding, `SESSION_COOKIE_SECURE=true`, exact CORS origins, backups, database least-privilege permissions, and production monitoring.
5. Configure edge rate limits for `/iti/login.do`, captcha verification and public registration endpoints; the current CAPTCHA attempt limit is session-scoped and is not a substitute for an IP-aware, shared rate limiter.
6. Review the Trivy and CodeQL artifacts on each release and remediate confirmed findings.

## Local smoke-test sequence

After adding the required local secrets to the existing, uncommitted `.env` files and starting both services:

1. Confirm Backend listens only on loopback and Frontend can reach `BACKEND_URL`.
2. Open the public candidate registration page. Load district/caste/sub-caste references, submit a new candidate, and verify that photo upload accepts a real JPEG/PNG but rejects renamed non-image files and oversized files.
3. Open the candidate Apply page. Submit registration ID, DOB, SSC hall-ticket number and captcha. Confirm the application details and marks load only after the gate succeeds.
4. Open candidate edit details. Confirm an incorrect DOB or hall-ticket number returns no personal data; correct details allow only that registration ID to be read, photographed, and updated.
5. Sign in as a district official. Verify that the official can list/approve only their district's candidates and cannot submit a different district code.
6. Sign in as an ITI official. Verify that trade and shift/unit operations work only for the ITI assigned to that account.
7. Verify reports are scoped to the official's district/ITI and that state-wide reports remain restricted to state/nodal roles.
8. Verify an unauthenticated request to an official `/backend/**` route returns 401, a cross-origin write to both `/backend/**` and a legacy Frontend write route returns 403, and a same-origin write succeeds. For Postman, add the exact Frontend `Origin` header. Verify a direct request to any Backend application route without the internal service credential returns 401 even when no `Origin` header is supplied. Documentation/health paths are intentionally excluded.

Do not test destructive operations against production data. Use a staging database or known test accounts and records.
