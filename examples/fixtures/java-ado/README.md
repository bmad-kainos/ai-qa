# Orders Service

Java 21 Gradle service: REST orders API backed by PostgreSQL. Run unit tests with `gradle test`; integration tests will need a configured test task and `docker compose up -d` with `ORDERS_DB_PASSWORD` set. Pipeline definition is `azure-pipelines.yml`; Azure Boards work items use `ORD-123` in branch and PR discussions. REST contract lives in `docs/openapi.yaml`; deployment environment inputs are described in `infra/main.tf`.
