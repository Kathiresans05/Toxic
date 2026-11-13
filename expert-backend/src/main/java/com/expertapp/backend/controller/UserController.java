package com.expertapp.backend.controller;

import com.expertapp.backend.config.UserPrincipal;
import com.expertapp.backend.entity.ExpertProfile;
import com.expertapp.backend.entity.PayoutRequest;
import com.expertapp.backend.entity.User;
import com.expertapp.backend.repository.ExpertProfileRepository;
import com.expertapp.backend.repository.PayoutRequestRepository;
import com.expertapp.backend.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "Users & Customer Operations", description = "User profile, banners, wallet and app settings")
public class UserController {

    private final UserRepository userRepository;
    private final ExpertProfileRepository expertProfileRepository;
    private final PayoutRequestRepository payoutRequestRepository;

    public UserController(
            UserRepository userRepository,
            ExpertProfileRepository expertProfileRepository,
            PayoutRequestRepository payoutRequestRepository) {
        this.userRepository = userRepository;
        this.expertProfileRepository = expertProfileRepository;
        this.payoutRequestRepository = payoutRequestRepository;
    }

    @GetMapping("/profile")
    @Operation(summary = "Get current authenticated user profile")
    public ResponseEntity<?> getProfile() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }
        UUID userId = null;
        if (auth.getPrincipal() instanceof UserPrincipal up) {
            userId = up.getId();
        } else if (auth.getPrincipal() instanceof String str) {
            try {
                userId = UUID.fromString(str);
            } catch (Exception ignored) {}
        }

        Optional<User> userOpt = userId != null ? userRepository.findById(userId) : Optional.empty();
        if (userOpt.isEmpty() && auth.getName() != null) {
            userOpt = userRepository.findByEmail(auth.getName());
            if (userOpt.isEmpty()) {
                userOpt = userRepository.findByPhoneNumber(auth.getName());
            }
        }
        return userOpt.map(user -> ResponseEntity.ok(Map.of(
                "id", user.getId().toString(),
                "fullName", user.getFullName() != null ? user.getFullName() : "User",
                "email", user.getEmail() != null ? user.getEmail() : "",
                "phoneNumber", user.getPhoneNumber() != null ? user.getPhoneNumber() : "",
                "role", user.getRole().name(),
                "walletBalance", user.getWalletBalance() != null ? user.getWalletBalance() : java.math.BigDecimal.ZERO
        ))).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/banners")
    @Operation(summary = "Get active promotional banners")
    public ResponseEntity<List<Map<String, Object>>> getBanners(@RequestParam(defaultValue = "true") boolean activeOnly) {
        List<Map<String, Object>> banners = List.of(
                Map.of(
                        "id", "banner-1",
                        "title", "Expert Consultation",
                        "subtitle", "Connect with verified professionals in seconds",
                        "imageUrl", "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800",
                        "actionUrl", "/experts"
                ),
                Map.of(
                        "id", "banner-2",
                        "title", "Instant Audio & Video Calls",
                        "subtitle", "High definition call quality powered by Agora",
                        "imageUrl", "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800",
                        "actionUrl", "/calls"
                )
        );
        return ResponseEntity.ok(banners);
    }

    @GetMapping("/settings")
    @Operation(summary = "Get global application settings")
    public ResponseEntity<Map<String, Object>> getSettings() {
        return ResponseEntity.ok(Map.of(
                "minRechargeAmount", 50.0,
                "maxRechargeAmount", 50000.0,
                "currency", "INR",
                "supportPhone", "+91 9876543210",
                "termsUrl", "https://connectax.app/terms",
                "privacyUrl", "https://connectax.app/privacy"
        ));
    }

    @Value("${spring.profiles.active:dev}")
    private String activeProfile;

    @PutMapping("/recharge")
    @Operation(summary = "Recharge user wallet")
    public ResponseEntity<?> rechargeWallet(@RequestBody Map<String, Object> body) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        UUID userId = null;
        if (auth.getPrincipal() instanceof UserPrincipal up) {
            userId = up.getId();
        } else if (auth.getPrincipal() instanceof String str) {
            try {
                userId = UUID.fromString(str);
            } catch (Exception ignored) {}
        }

        Optional<User> userOpt = userId != null ? userRepository.findById(userId) : Optional.empty();
        if (userOpt.isEmpty() && auth.getName() != null) {
            userOpt = userRepository.findByEmail(auth.getName());
            if (userOpt.isEmpty()) {
                userOpt = userRepository.findByPhoneNumber(auth.getName());
            }
        }
        if (userOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        User user = userOpt.get();
        double amount = ((Number) body.getOrDefault("amount", 0.0)).doubleValue();
        if (amount < 1.0 || amount > 50000.0) {
            return ResponseEntity.badRequest().body(Map.of("error", "Recharge amount must be between ₹1 and ₹50,000"));
        }
        java.math.BigDecimal currentBalance = user.getWalletBalance() != null ? user.getWalletBalance() : java.math.BigDecimal.ZERO;
        java.math.BigDecimal newBalance = currentBalance.add(java.math.BigDecimal.valueOf(amount));
        user.setWalletBalance(newBalance);
        userRepository.save(user);

        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Wallet recharged successfully",
                "newBalance", newBalance
        ));
    }

    @PostMapping("/payout-request")
    @Operation(summary = "Submit creator earnings payout withdrawal request")
    public ResponseEntity<?> requestPayout(@RequestBody Map<String, Object> body) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        UUID userId = null;
        if (auth.getPrincipal() instanceof UserPrincipal up) {
            userId = up.getId();
        } else if (auth.getPrincipal() instanceof String str) {
            try {
                userId = UUID.fromString(str);
            } catch (Exception ignored) {}
        }

        Optional<User> userOpt = userId != null ? userRepository.findById(userId) : Optional.empty();
        if (userOpt.isEmpty() && auth.getName() != null) {
            userOpt = userRepository.findByEmail(auth.getName());
            if (userOpt.isEmpty()) {
                userOpt = userRepository.findByPhoneNumber(auth.getName());
            }
        }
        if (userOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        User user = userOpt.get();

        ExpertProfile expert = expertProfileRepository.findByUserId(user.getId())
                .orElse(null);
        if (expert == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "No creator profile found for this user account"));
        }

        double amtDouble = ((Number) body.getOrDefault("amount", 0.0)).doubleValue();
        if (amtDouble < 1.0) {
            return ResponseEntity.badRequest().body(Map.of("error", "Withdrawal amount must be at least ₹1"));
        }

        BigDecimal requestedAmount = BigDecimal.valueOf(amtDouble);
        BigDecimal currentBalance = expert.getWalletBalance() != null ? expert.getWalletBalance() : BigDecimal.ZERO;

        if (currentBalance.compareTo(requestedAmount) < 0) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", "Insufficient earnings balance in wallet",
                    "availableBalance", currentBalance,
                    "requestedAmount", requestedAmount
            ));
        }

        // Atomic deduction from creator wallet
        BigDecimal newBalance = currentBalance.subtract(requestedAmount);
        expert.setWalletBalance(newBalance);
        expertProfileRepository.save(expert);

        // Create PayoutRequest
        PayoutRequest payout = new PayoutRequest();
        payout.setExpert(expert);
        payout.setAmount(requestedAmount);
        payout.setCurrency("INR");
        payout.setStatus("REQUESTED");

        String upiId = (String) body.get("upiId");
        String bankAccountNumber = (String) body.get("accountNumber");
        String bankIfsc = (String) body.get("ifsc");
        String accountDetails = (String) body.get("accountDetails");

        if (upiId != null && !upiId.isBlank()) {
            payout.setUpiId(upiId);
        } else if (accountDetails != null && accountDetails.contains("@")) {
            payout.setUpiId(accountDetails);
        }

        if (bankAccountNumber != null && !bankAccountNumber.isBlank()) {
            payout.setBankAccountNumber(bankAccountNumber);
            payout.setBankIfsc(bankIfsc);
        } else if (accountDetails != null && !accountDetails.contains("@")) {
            payout.setBankAccountNumber(accountDetails);
        }

        payoutRequestRepository.save(payout);

        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Payout withdrawal request submitted successfully",
                "payoutId", payout.getId(),
                "amount", requestedAmount,
                "newBalance", newBalance,
                "status", "REQUESTED"
        ));
    }
}
