package com.kainos.commerce.orders;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.notNullValue;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import io.restassured.RestAssured;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class OrderApiTest {
    @LocalServerPort
    private int port;

    @BeforeEach
    void configureBaseUri() {
        RestAssured.port = port;
    }

    @Test
    void createsAnOrderAndReturnsItsIdentifier() {
        given()
            .contentType("application/json")
            .body("{\"customerId\":\"cust-7\",\"sku\":\"book-1\",\"quantity\":2}")
        .when()
            .post("/orders")
        .then()
            .statusCode(201)
            .body("id", notNullValue())
            .body("quantity", equalTo(2));
    }

    @Test
    void rejectsAnOrderWithZeroQuantity() {
        given()
            .contentType("application/json")
            .body("{\"customerId\":\"cust-7\",\"sku\":\"book-1\",\"quantity\":0}")
        .when()
            .post("/orders")
        .then()
            .statusCode(400);
    }
}