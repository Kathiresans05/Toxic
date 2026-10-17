package com.expertapp.backend.controller;

import com.expertapp.backend.entity.ExpertProfile;
import com.expertapp.backend.repository.ExpertProfileRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/experts")
@Tag(name = "Creators & Experts", description = "Discovery and Profiles of Consultants")
public class ExpertController {

    private final ExpertProfileRepository expertProfileRepository;

    public ExpertController(ExpertProfileRepository expertProfileRepository) {
        this.expertProfileRepository = expertProfileRepository;
    }

    @GetMapping("/profile")
    @Operation(summary = "Get current authenticated expert profile")
    public ResponseEntity<?> getMyProfile() {
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return ResponseEntity.status(401).body(java.util.Map.of("error", "Unauthorized"));
        }
        String principal = (String) auth.getPrincipal();
        return expertProfileRepository.findAll().stream()
                .filter(e -> e.getUser() != null && (principal.equalsIgnoreCase(e.getUser().getEmail()) || principal.equalsIgnoreCase(e.getUser().getPhoneNumber()) || principal.equalsIgnoreCase(e.getUser().getId().toString())))
                .findFirst()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
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
}
