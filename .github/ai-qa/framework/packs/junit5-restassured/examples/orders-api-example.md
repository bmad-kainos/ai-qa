# JUnit 5 + REST Assured — Orders API example (illustrative, unrun)

This **hypothetical** contract documents `POST /orders` with required `customerId` and integer `quantity` 1–9. It returns **201** plus string `id` for valid requests, **400** plus `error.code` otherwise. The project must already have JUnit Jupiter, REST Assured and Hamcrest; `API_BASE_URL` must point to an authorized isolated environment. No build manifest or Java source is installed by this pack.

```java
import static io.restassured.RestAssured.given;
import static io.restassured.http.ContentType.JSON;
import static org.hamcrest.Matchers.notNullValue;
import static org.junit.jupiter.api.Assertions.assertEquals;

import io.restassured.builder.RequestSpecBuilder;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

class OrdersContractTest {
    private RequestSpecification api() {
        String baseUrl = System.getenv("API_BASE_URL");
        if (baseUrl == null || baseUrl.isBlank()) {
            throw new IllegalStateException("API_BASE_URL must be configured for an approved test environment");
        }
        return new RequestSpecBuilder().setBaseUri(baseUrl).setContentType(JSON).build();
    }

    private Map<String, Object> order(int quantity) {
        return Map.of("customerId", "isolated-example", "quantity", quantity);
    }

    @Test
    void validOrderReturns201AndId() {
        given().spec(api()).body(order(5))
            .when().post("/orders")
            .then().statusCode(201).body("id", notNullValue());
    }

    @ParameterizedTest(name = "quantity={0} returns {1}")
    @CsvSource({"0,400", "1,201", "9,201", "10,400"})
    void quantityBoundary(int quantity, int expectedStatus) {
        Response response = given().spec(api()).body(order(quantity))
            .when().post("/orders");
        assertEquals(expectedStatus, response.statusCode(),
            "quantity=" + quantity + ": " + response.asString());
        if (expectedStatus == 400) {
            response.then().body("error.code", notNullValue());
        } else {
            response.then().body("id", notNullValue());
        }
    }

    @Test
    void missingCustomerIdReturns400() {
        given().spec(api()).body(Map.of("quantity", 1))
            .when().post("/orders")
            .then().statusCode(400).body("error.code", notNullValue());
    }
}
```

Read-only request specifications are created per test invocation; no mutable global base URI or credential is shared. Adapt auth, deterministic data and cleanup to existing fixtures, and check the real contract before accepting these statuses or response paths.
