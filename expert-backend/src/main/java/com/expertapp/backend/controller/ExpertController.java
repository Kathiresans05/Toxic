package com.expertapp.backend.controller;

import com.expertapp.backend.entity.*;
import com.expertapp.backend.repository.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/experts")
@Tag(name = "Creators & Experts", description = "Discovery and Profiles of Consultants")
public class ExpertController {

    private final ExpertProfileRepository expertProfileRepository;
    private final KycVerificationRepository kycVerificationRepository;
    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;
    private final CallSessionRepository callSessionRepository;

    public ExpertController(
            ExpertProfileRepository expertProfileRepository,
            KycVerificationRepository kycVerificationRepository,
            ReviewRepository reviewRepository,
            UserRepository userRepository,
            CallSessionRepository callSessionRepository) {
        this.expertProfileRepository = expertProfileRepository;
        this.kycVerificationRepository = kycVerificationRepository;
        this.reviewRepository = reviewRepository;
        this.userRepository = userRepository;
        this.callSessionRepository = callSessionRepository;
    }

    private UUID extractUserId(org.springframework.security.core.Authentication auth) {
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return null;
        }
        if (auth.getPrincipal() instanceof com.expertapp.backend.config.UserPrincipal up) {
            return up.getId();
        }
        if (auth.getPrincipal() instanceof String str) {
            try {
                return UUID.fromString(str);
            } catch (Exception ignored) {}
        }
        return null;
    }

    @GetMapping("/profile")
    @Operation(summary = "Get current authenticated expert profile")
    public ResponseEntity<?> getMyProfile() {
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        UUID userId = extractUserId(auth);
        if (userId == null) {
            return ResponseEntity.status(401).body(java.util.Map.of("error", "Unauthorized"));
        }
        String authName = auth.getName();
        return expertProfileRepository.findAll().stream()
                .filter(e -> e.getUser() != null && (
                        userId.equals(e.getUser().getId()) ||
                        (authName != null && (authName.equalsIgnoreCase(e.getUser().getEmail()) || authName.equalsIgnoreCase(e.getUser().getPhoneNumber())))
                ))
                .findFirst()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/profile")
    @Operation(summary = "Update current authenticated expert profile")
    public ResponseEntity<?> updateMyProfile(@RequestBody java.util.Map<String, Object> body) {
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        UUID userId = extractUserId(auth);
        if (userId == null) {
            return ResponseEntity.status(401).body(java.util.Map.of("error", "Unauthorized"));
        }
        String authName = auth.getName();
        ExpertProfile expert = expertProfileRepository.findAll().stream()
                .filter(e -> e.getUser() != null && (
                        userId.equals(e.getUser().getId()) ||
                        (authName != null && (authName.equalsIgnoreCase(e.getUser().getEmail()) || authName.equalsIgnoreCase(e.getUser().getPhoneNumber())))
                ))
                .findFirst()
                .orElse(null);

        if (expert == null) {
            return ResponseEntity.notFound().build();
        }

        if (body.containsKey("bio") && body.get("bio") != null) {
            expert.setBio(body.get("bio").toString());
        }
        if (body.containsKey("headline") && body.get("headline") != null) {
            expert.setHeadline(body.get("headline").toString());
        }
        if (body.containsKey("experienceYears") && body.get("experienceYears") != null) {
            expert.setExperienceYears(((Number) body.get("experienceYears")).intValue());
        }
        if (body.containsKey("audioRate") && body.get("audioRate") != null) {
            expert.setAudioRatePerMin(new java.math.BigDecimal(body.get("audioRate").toString()));
        }
        if (body.containsKey("videoRate") && body.get("videoRate") != null) {
            expert.setVideoRatePerMin(new java.math.BigDecimal(body.get("videoRate").toString()));
        }
        expertProfileRepository.save(expert);
        return ResponseEntity.ok(expert);
    }

    @PutMapping("/status")
    @Operation(summary = "Toggle creator online/offline availability status")
    public ResponseEntity<?> toggleOnlineStatus(@RequestBody Map<String, Object> body) {
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        UUID userId = extractUserId(auth);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        String authName = auth.getName();
        ExpertProfile expert = expertProfileRepository.findAll().stream()
                .filter(e -> e.getUser() != null && (
                        userId.equals(e.getUser().getId()) ||
                        (authName != null && (authName.equalsIgnoreCase(e.getUser().getEmail()) || authName.equalsIgnoreCase(e.getUser().getPhoneNumber())))
                ))
                .findFirst()
                .orElse(null);

        if (expert == null) {
            return ResponseEntity.notFound().build();
        }

        boolean isOnline = true;
        if (body.containsKey("isOnline")) {
            isOnline = Boolean.parseBoolean(body.get("isOnline").toString());
        } else if (body.containsKey("available")) {
            isOnline = Boolean.parseBoolean(body.get("available").toString());
        }

        expert.setAvailable(isOnline);
        expertProfileRepository.save(expert);

        return ResponseEntity.ok(Map.of(
                "success", true,
                "isOnline", expert.isAvailable(),
                "available", expert.isAvailable(),
                "message", "Creator status updated to " + (expert.isAvailable() ? "ONLINE" : "OFFLINE")
        ));
    }

    @GetMapping("/online")
    @Operation(summary = "Get currently online and available experts")
    public ResponseEntity<java.util.List<ExpertProfile>> getOnlineExperts(
            @RequestParam(required = false) String preferredLanguage) {
        return ResponseEntity.ok(expertProfileRepository.findByApprovedTrueAndAvailableTrue(PageRequest.of(0, 50)).getContent());
    }

    @GetMapping
    @Operation(summary = "Browse approved and available experts")
    public ResponseEntity<Page<ExpertProfile>> getExperts(
            @RequestParam(required = false) UUID categoryId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        if (categoryId != null) {
            return ResponseEntity.ok(expertProfileRepository.findByCategoryIdAndApprovedTrueAndAvailableTrue(categoryId, PageRequest.of(page, size)));
        }
        return ResponseEntity.ok(expertProfileRepository.findByApprovedTrueAndAvailableTrue(PageRequest.of(page, size)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get expert profile details")
    public ResponseEntity<ExpertProfile> getExpertById(@PathVariable UUID id) {
        return expertProfileRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/kyc")
    @Operation(summary = "Submit KYC verification documents for creator audit")
    public ResponseEntity<?> submitKyc(@RequestBody Map<String, Object> body) {
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        UUID userId = extractUserId(auth);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        String authName = auth.getName();
        ExpertProfile expert = expertProfileRepository.findAll().stream()
                .filter(e -> e.getUser() != null && (
                        userId.equals(e.getUser().getId()) ||
                        (authName != null && (authName.equalsIgnoreCase(e.getUser().getEmail()) || authName.equalsIgnoreCase(e.getUser().getPhoneNumber())))
                ))
                .findFirst()
                .orElse(null);

        if (expert == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "No creator profile found for this account"));
        }

        String idType = (String) body.getOrDefault("idType", "AADHAAR");
        String idNumber = (String) body.getOrDefault("idNumber", "8923 4512 7890");
        String frontUrl = (String) body.getOrDefault("documentFrontUrl", "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600");
        String backUrl = (String) body.getOrDefault("documentBackUrl", "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600");
        String selfieUrl = (String) body.getOrDefault("selfieUrl", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400");

        // Find existing pending or create new
        KycVerification kyc = kycVerificationRepository.findTopByExpertIdOrderByCreatedAtDesc(expert.getId())
                .filter(k -> k.getStatus() == KycStatus.PENDING)
                .orElseGet(KycVerification::new);

        kyc.setExpert(expert);
        kyc.setIdType(idType);
        kyc.setIdNumber(idNumber);
        kyc.setDocumentFrontUrl(frontUrl);
        kyc.setDocumentBackUrl(backUrl);
        kyc.setSelfieUrl(selfieUrl);
        kyc.setStatus(KycStatus.PENDING);
        kycVerificationRepository.save(kyc);

        expert.setKycStatus(KycStatus.PENDING);
        expertProfileRepository.save(expert);

        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "KYC documents submitted successfully. Pending Admin verification.",
                "kycId", kyc.getId(),
                "idType", idType,
                "idNumber", idNumber,
                "status", KycStatus.PENDING.name()
        ));
    }

    @GetMapping("/kyc")
    @Operation(summary = "Get current authenticated creator KYC status")
    public ResponseEntity<?> getKycStatus() {
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        UUID userId = extractUserId(auth);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        String authName = auth.getName();
        ExpertProfile expert = expertProfileRepository.findAll().stream()
                .filter(e -> e.getUser() != null && (
                        userId.equals(e.getUser().getId()) ||
                        (authName != null && (authName.equalsIgnoreCase(e.getUser().getEmail()) || authName.equalsIgnoreCase(e.getUser().getPhoneNumber())))
                ))
                .findFirst()
                .orElse(null);

        if (expert == null) {
            return ResponseEntity.notFound().build();
        }

        return kycVerificationRepository.findTopByExpertIdOrderByCreatedAtDesc(expert.getId())
                .map(k -> ResponseEntity.ok(Map.of(
                        "kycId", k.getId(),
                        "status", k.getStatus().name(),
                        "idType", k.getIdType(),
                        "idNumber", k.getIdNumber(),
                        "rejectionReason", k.getRejectionReason() != null ? k.getRejectionReason() : "",
                        "reviewedAt", k.getReviewedAt() != null ? k.getReviewedAt().toString() : ""
                )))
                .orElse(ResponseEntity.ok(Map.of(
                        "status", expert.getKycStatus() != null ? expert.getKycStatus().name() : "NOT_SUBMITTED"
                )));
    }

    @PostMapping("/{expertId}/reviews")
    @Operation(summary = "Submit a customer rating and review for a creator")
    public ResponseEntity<?> submitReview(
            @PathVariable UUID expertId,
            @RequestBody Map<String, Object> body) {
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        UUID userId = extractUserId(auth);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        User customer = userRepository.findById(userId)
                .or(() -> auth.getName() != null ? userRepository.findByEmail(auth.getName()) : java.util.Optional.empty())
                .or(() -> auth.getName() != null ? userRepository.findByPhoneNumber(auth.getName()) : java.util.Optional.empty())
                .orElse(null);
        if (customer == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Customer user not found"));
        }

        ExpertProfile expert = expertProfileRepository.findById(expertId)
                .or(() -> expertProfileRepository.findByUserId(expertId))
                .orElse(null);
        if (expert == null) {
            return ResponseEntity.notFound().build();
        }

        int rating = 5;
        if (body.containsKey("rating")) {
            rating = Math.max(1, Math.min(5, ((Number) body.get("rating")).intValue()));
        }

        String comment = "";
        if (body.containsKey("reviewText") && body.get("reviewText") != null) {
            comment = body.get("reviewText").toString();
        } else if (body.containsKey("comment") && body.get("comment") != null) {
            comment = body.get("comment").toString();
        }

        CallSession callSession = null;
        if (body.containsKey("callId") && body.get("callId") != null) {
            callSession = callSessionRepository.findByCallId(body.get("callId").toString()).orElse(null);
        }

        Review review = new Review();
        review.setCustomer(customer);
        review.setExpert(expert);
        review.setRating(rating);
        review.setComment(comment);
        if (callSession != null) {
            review.setCallSession(callSession);
        }
        reviewRepository.save(review);

        // Recalculate Expert Average Rating & Total Reviews
        int currentTotal = expert.getTotalReviews() != null ? expert.getTotalReviews() : 0;
        BigDecimal currentAvg = expert.getRatingAverage() != null ? expert.getRatingAverage() : BigDecimal.valueOf(5.00);

        int newTotal = currentTotal + 1;
        BigDecimal totalScore = currentAvg.multiply(BigDecimal.valueOf(currentTotal)).add(BigDecimal.valueOf(rating));
        BigDecimal newAvg = totalScore.divide(BigDecimal.valueOf(newTotal), 2, java.math.RoundingMode.HALF_UP);

        expert.setTotalReviews(newTotal);
        expert.setRatingAverage(newAvg);
        expertProfileRepository.save(expert);

        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Review submitted successfully",
                "reviewId", review.getId(),
                "rating", rating,
                "comment", comment,
                "ratingAverage", newAvg,
                "totalReviews", newTotal
        ));
    }

    @GetMapping("/{expertId}/reviews")
    @Operation(summary = "Get list of reviews for a creator")
    public ResponseEntity<?> getReviews(
            @PathVariable UUID expertId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        ExpertProfile expert = expertProfileRepository.findById(expertId)
                .or(() -> expertProfileRepository.findByUserId(expertId))
                .orElse(null);
        if (expert == null) {
            return ResponseEntity.notFound().build();
        }

        Page<Review> reviews = reviewRepository.findByExpertId(expert.getId(), PageRequest.of(page, size));
        return ResponseEntity.ok(reviews.map(r -> Map.of(
                "id", r.getId(),
                "customerName", r.getCustomer() != null ? r.getCustomer().getFullName() : "Customer",
                "rating", r.getRating(),
                "comment", r.getComment() != null ? r.getComment() : "",
                "createdAt", r.getCreatedAt().toString()
        )));
    }
}
