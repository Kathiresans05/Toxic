package com.expertapp.backend.controller;

import com.expertapp.backend.entity.User;
import com.expertapp.backend.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "Users & Customer Operations", description = "User profile, banners, wallet and app settings")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/profile")
    @Operation(summary = "Get current authenticated user profile")
    public ResponseEntity<?> getProfile() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }
        String principal = (String) auth.getPrincipal();
        Optional<User> userOpt = userRepository.findByEmail(principal);
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByPhoneNumber(principal);
        }
        if (userOpt.isEmpty()) {
            try {
                userOpt = userRepository.findById(UUID.fromString(principal));
            } catch (Exception ignored) {}
        }
        return userOpt.map(user -> ResponseEntity.ok(Map.of(
                "id", user.getId().toString(),
                "fullName", user.getFullName(),
                "email", user.getEmail() != null ? user.getEmail() : "",
                "phoneNumber", user.getPhoneNumber() != null ? user.getPhoneNumber() : "",
                "role", user.getRole().name(),
                "walletBalance", 100.00
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

    @PutMapping("/recharge")
    @Operation(summary = "Recharge user wallet")
    public ResponseEntity<Map<String, Object>> rechargeWallet(@RequestBody Map<String, Object> body) {
        double amount = ((Number) body.getOrDefault("amount", 100.0)).doubleValue();
        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Wallet recharged successfully",
                "newBalance", 100.0 + amount
        ));
    }
}
