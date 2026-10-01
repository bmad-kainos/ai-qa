package example.orders;

import java.util.LinkedHashMap;
import java.util.Map;

public final class OrderPayloads {
    private OrderPayloads() {
    }

    public static Map<String, Object> validOrder() {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("customerId", "cust-123");
        payload.put("quantity", 1);
        payload.put("currency", "GBP");
        return payload;
    }
}
