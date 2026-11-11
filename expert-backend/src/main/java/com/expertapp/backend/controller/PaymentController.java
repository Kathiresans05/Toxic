package com.expertapp.backend.controller;

import com.expertapp.backend.config.UserPrincipal;
import com.expertapp.backend.service.PaymentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/payments")
@Tag(name = "Payments", description = "Razorpay / Cashfree Orders, Verification, and Webhooks")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping({"/create-order", "/razorpay/order"})
    @Operation(summary = "Create Razorpay Order for wallet recharge or call prepayment")
    public ResponseEntity<Map<String, Object>> createOrder(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestBody Map<String, Object> request) {
        BigDecimal amount = new BigDecimal(request.get("amount").toString());
        String currency = (String) request.getOrDefault("currency", "INR");
        return ResponseEntity.ok(paymentService.createOrder(userPrincipal.getId(), amount, currency));
    }

    @PostMapping({"/verify", "/razorpay/verify"})
    @Operation(summary = "Verify client payment signature")
    public ResponseEntity<Map<String, Object>> verifyPayment(@RequestBody Map<String, String> request) {
        String orderId = request.containsKey("orderId") ? request.get("orderId") : request.get("razorpay_order_id");
        String paymentId = request.containsKey("paymentId") ? request.get("paymentId") : request.get("razorpay_payment_id");
        String signature = request.containsKey("signature") ? request.get("signature") : request.get("razorpay_signature");

        boolean verified = paymentService.verifyAndCompletePayment(orderId, paymentId, signature);
        return ResponseEntity.ok(Map.of("verified", verified));
    }

    @PostMapping("/webhook")
    @Operation(summary = "Secure Webhook receiver for Razorpay payment events")
    public ResponseEntity<Map<String, Object>> handleWebhook(
            @RequestBody String payload,
            @RequestHeader(value = "X-Razorpay-Signature", required = false) String signature) {
        boolean processed = paymentService.processWebhook(payload, signature != null ? signature : "");
        return ResponseEntity.ok(Map.of("status", processed ? "success" : "ignored"));
    }
}
