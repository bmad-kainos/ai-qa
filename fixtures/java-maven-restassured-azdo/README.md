# Orders Service

Orders Service is a Java 21 REST API for creating and retrieving orders. PostgreSQL is the system of record; the API contract is in [docs/openapi.yaml](docs/openapi.yaml), and the service boundary is described in [docs/architecture.md](docs/architecture.md).

## Build and test

The project uses Maven. Run `sh mvnw test` to compile and run the JUnit 5 suite. API tests use RestAssured against a Spring Boot random-port server. Start local dependencies with `docker compose up -d`; the database password is supplied through the `ORDERS_DB_PASSWORD` environment variable. Never put the value in source control.

## Delivery and work items

Azure Pipelines is defined in [azure-pipelines.yml](azure-pipelines.yml) and has test and deploy stages. Infrastructure inputs are in [infra/main.tf](infra/main.tf). Delivery work is tracked by Azure Boards in the `Commerce/Orders` project at `https://dev.azure.com/kainos-commerce/Commerce`; use IDs such as `AB#123` in commits and pull requests.

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch and commit conventions and [ADR 0001](docs/adr/0001-postgres.md) for the database decision.
