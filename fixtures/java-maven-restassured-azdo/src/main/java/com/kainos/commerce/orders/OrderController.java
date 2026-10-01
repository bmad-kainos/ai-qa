package com.kainos.commerce.orders;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class OrderController {
    private final Map<String, Order> orders = new ConcurrentHashMap<>();

    @PostMapping("/orders")
    @ResponseStatus(HttpStatus.CREATED)
    public Order create(@RequestBody NewOrder request) {
        if (request.customerId() == null || request.customerId().isBlank()
                || request.sku() == null || request.sku().isBlank() || request.quantity() < 1) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid order");
        }
        Order order = new Order(UUID.randomUUID().toString(), request.customerId(), request.sku(), request.quantity());
        orders.put(order.id(), order);
        return order;
    }

    @GetMapping("/orders/{id}")
    public Order get(@PathVariable String id) {
        Order order = orders.get(id);
        if (order == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found");
        }
        return order;
    }

    public record NewOrder(String customerId, String sku, int quantity) {}
    public record Order(String id, String customerId, String sku, int quantity) {}
}