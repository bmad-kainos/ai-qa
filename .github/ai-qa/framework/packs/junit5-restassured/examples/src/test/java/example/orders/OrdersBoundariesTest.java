package example.orders;

import static io.restassured.RestAssured.given;

import java.util.Map;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import io.restassured.http.ContentType;

import static org.junit.jupiter.api.Assumptions.assumeTrue;

class OrdersBoundariesTest {
    private static final String ORDERS_PATH = "/api/v1/orders";

    @ParameterizedTest(name = "quantity {0} returns {1}")
    @CsvSource({
        "0, 400",      // below minimum — rejected
        "1, 201",      // lower boundary — accepted
        "999, 201",    // upper boundary — accepted
        "1000, 400"    // above maximum — rejected
    })
    void quantityBoundariesReturnDocumentedStatus(int quantity, int expectedStatus) {
        String baseUrl = System.getenv("API_BASE_URL");
        assumeTrue(baseUrl != null && !baseUrl.trim().isEmpty(), "Set API_BASE_URL to an isolated test API");
        Map<String, Object> payload = OrderPayloads.validOrder();
        payload.put("quantity", quantity);

        given()
            .baseUri(baseUrl)
            .contentType(ContentType.JSON)
            .body(payload)
        .when()
            .post(ORDERS_PATH)
        .then()
            .statusCode(expectedStatus);
    }
}
