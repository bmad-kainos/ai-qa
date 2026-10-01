package example.orders;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.anyOf;
import static org.hamcrest.Matchers.blankOrNullString;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.not;

import java.util.Map;
import org.junit.jupiter.api.Test;

import io.restassured.http.ContentType;

import static org.junit.jupiter.api.Assumptions.assumeTrue;

class OrdersContractTest {
    private static final String ORDERS_PATH = "/api/v1/orders";

    @Test
    void validOrderReturnsCreatedResponse() {
        String baseUrl = System.getenv("API_BASE_URL");
        assumeTrue(baseUrl != null && !baseUrl.trim().isEmpty(), "Set API_BASE_URL to an isolated test API");

        given()
            .baseUri(baseUrl)
            .contentType(ContentType.JSON)
            .accept(ContentType.JSON)
            .body(OrderPayloads.validOrder())
        .when()
            .post(ORDERS_PATH)
        .then()
            .statusCode(201)
            .body("id", not(blankOrNullString()))
            .body("status", anyOf(equalTo("pending"), equalTo("confirmed")));
    }

    @Test
    void missingCustomerIdReturnsBadRequest() {
        String baseUrl = System.getenv("API_BASE_URL");
        assumeTrue(baseUrl != null && !baseUrl.trim().isEmpty(), "Set API_BASE_URL to an isolated test API");
        Map<String, Object> payload = OrderPayloads.validOrder();
        payload.remove("customerId");

        given()
            .baseUri(baseUrl)
            .contentType(ContentType.JSON)
            .body(payload)
        .when()
            .post(ORDERS_PATH)
        .then()
            .statusCode(400);
    }

    @Test
    void unauthenticatedRequestReturnsUnauthorized() {
        String baseUrl = System.getenv("API_BASE_URL");
        assumeTrue(baseUrl != null && !baseUrl.trim().isEmpty(), "Set API_BASE_URL to an isolated test API");

        given()
            .baseUri(baseUrl)
            .contentType(ContentType.JSON)
            .body(OrderPayloads.validOrder())
            .header("Authorization", "")
        .when()
            .post(ORDERS_PATH)
        .then()
            .statusCode(401);
    }
}
