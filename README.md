# ITI Admissions (itiadmissions) — monorepo

Admissions-only split of the ITIAP workspace. Two Spring Boot apps, one repo.

| App | Path | Port | Run first? |
|-----|------|------|------------|
| Backend | `Backend/` | 6050 | yes — Frontend calls its REST API |
| Frontend | `Frontend/` | 6051 | no — needs Backend up |

## Build / run (always use the wrapper — system `mvn` breaks Lombok; use JDK 22)

```bash
export JAVA_HOME=/usr/lib/jvm/jdk-22.0.2+9   # pom pins java.version=22, lombok 1.18.46
cd Backend && ./mvnw -o clean compile   # build backend
cd Frontend && ./mvnw -o clean test     # build frontend + run tests
```

Backend must be running before Frontend (`backend.api.base-url` points at `:6050`).

### Frontend JS unit tests

The browser JS (no bundler) is unit-tested with the Node test runner:

```bash
cd Frontend && npm test     # or: node --test "src/test/js/*.test.js"
```

## Repeatable sync from combined trees

See `/home/naga/Projects/NIC/ITI/ITIAP/docs/port-to-itiadmissions.md`
in the workspace docs repo for the copy/strip/keep lists and validation steps.

## History

Created 2026-10-01/02 as an admissions-only split of `Backend/` + `Frontend/`
(placements / implant / labs removed). Merged into this monorepo 2026-10-08;
both app histories are preserved as the two parents of the merge commit.