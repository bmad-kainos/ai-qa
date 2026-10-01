# Orders Service architecture

The Spring Boot service exposes the Orders REST API described by [OpenAPI](openapi.yaml). `OrderController` owns request validation and the in-memory example repository; PostgreSQL is the intended persistent store for deployed environments.

The service boundary is customer-to-orders. Inventory reservation is an external call and is not part of the current fixture implementation. Local database dependencies are described in `compose.yaml`; infrastructure inputs are in `infra/main.tf`.

## Operational signals

The pipeline publishes JUnit XML from Maven Surefire. Deployment is restricted to the `main` branch and the protected `orders-staging` environment.