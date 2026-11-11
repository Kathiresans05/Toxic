package com.expertapp.backend.controller;

import com.expertapp.backend.config.UserPrincipal;
import com.expertapp.backend.dto.DashboardStatsResponse;
import com.expertapp.backend.entity.*;
import com.expertapp.backend.service.AdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin")
@Tag(name = "Admin Operations", description = "Backoffice enterprise APIs for React Admin Dashboard")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService adminService;

    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    private String getClientIp(HttpServletRequest request) {
        String xf = request.getHeader("X-Forwarded-For");
        if (xf != null && !xf.isEmpty()) {
            return xf.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    // 1. Dashboard Overview
    @GetMapping("/stats")
    @Operation(summary = "Get high-level platform statistics and KPIs")
    public ResponseEntity<DashboardStatsResponse> getStats() {
        return ResponseEntity.ok(adminService.getDashboardStats());
    }

    // 2. User Management
    @GetMapping("/users")
    @Operation(summary = "List registered platform users (paginated with search)")
    public ResponseEntity<Page<User>> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search) {
        return ResponseEntity.ok(adminService.getUsers(page, size, search));
    }

    @PutMapping("/users/{userId}/toggle-status")
    @Operation(summary = "Activate or suspend customer account")
    public ResponseEntity<Map<String, String>> toggleUserStatus(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @PathVariable UUID userId,
            @RequestBody Map<String, Boolean> body,
            HttpServletRequest request) {
        boolean active = Boolean.TRUE.equals(body.get("active"));
        adminService.toggleUserStatus(userId, active, adminUser.getEmail(), getClientIp(request));
        return ResponseEntity.ok(Map.of("message", "User status updated to " + (active ? "ACTIVE" : "SUSPENDED")));
    }

    @PutMapping("/users/{userId}/toggle-verification")
    @Operation(summary = "Grant or revoke verified badge for creator or user")
    public ResponseEntity<Map<String, String>> toggleUserVerification(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @PathVariable UUID userId,
            @RequestBody Map<String, Boolean> body,
            HttpServletRequest request) {
        boolean verified = Boolean.TRUE.equals(body.get("verified"));
        adminService.toggleUserVerification(userId, verified, adminUser != null ? adminUser.getEmail() : "admin@expertapp.com", getClientIp(request));
        return ResponseEntity.ok(Map.of("message", "User verification updated to " + verified));
    }

    // 3. Creator Management
    @GetMapping("/creators")
    @Operation(summary = "List creator profiles with rates and ratings")
    public ResponseEntity<Page<ExpertProfile>> getCreators(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String tier) {
        return ResponseEntity.ok(adminService.getCreators(page, size, tier));
    }

    @PutMapping("/creators/{expertId}/approval")
    @Operation(summary = "Approve or revoke creator consultation status")
    public ResponseEntity<Map<String, String>> toggleCreatorApproval(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @PathVariable UUID expertId,
            @RequestBody Map<String, Boolean> body,
            HttpServletRequest request) {
        boolean approved = Boolean.TRUE.equals(body.get("approved"));
        adminService.toggleCreatorApproval(expertId, approved, adminUser.getEmail(), getClientIp(request));
        return ResponseEntity.ok(Map.of("message", "Creator approval set to " + approved));
    }

    @PutMapping("/creators/{expertId}/tier")
    @Operation(summary = "Assign creator to Standard Pro or Elite Expert tier")
    public ResponseEntity<Map<String, String>> updateCreatorTier(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @PathVariable UUID expertId,
            @RequestBody Map<String, String> body,
            HttpServletRequest request) {
        String tierStr = body.getOrDefault("tier", "STANDARD");
        CreatorTier tier = CreatorTier.valueOf(tierStr.toUpperCase());
        adminService.updateCreatorTier(expertId, tier, adminUser.getEmail(), getClientIp(request));
        return ResponseEntity.ok(Map.of("message", "Creator tier updated to " + tier));
    }

    @PutMapping("/pricing/tier-rates")
    @Operation(summary = "Configure universal tariff for Standard Pro or Elite Expert tier")
    public ResponseEntity<Map<String, Object>> updateTierRates(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        String tierStr = body.getOrDefault("tier", "STANDARD").toString();
        CreatorTier tier = CreatorTier.valueOf(tierStr.toUpperCase());
        BigDecimal audioRate = new BigDecimal(body.get("audioRate").toString());
        BigDecimal videoRate = new BigDecimal(body.get("videoRate").toString());
        boolean applyToExisting = Boolean.parseBoolean(String.valueOf(body.getOrDefault("applyToExisting", "true")));

        adminService.updateTierRates(tier, audioRate, videoRate, applyToExisting, adminUser.getEmail(), getClientIp(request));
        return ResponseEntity.ok(Map.of("message", tier + " tier rates updated successfully", "tier", tier.name()));
    }

    @PutMapping("/creators/{expertId}/rates")
    @Operation(summary = "Update creator voice and video rates")
    public ResponseEntity<Map<String, String>> updateCreatorRates(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @PathVariable UUID expertId,
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        BigDecimal audioRate = body.get("audioRate") != null ? new BigDecimal(body.get("audioRate").toString()) : null;
        BigDecimal videoRate = body.get("videoRate") != null ? new BigDecimal(body.get("videoRate").toString()) : null;
        adminService.updateCreatorRates(expertId, audioRate, videoRate, adminUser.getEmail(), getClientIp(request));
        return ResponseEntity.ok(Map.of("message", "Creator rates updated successfully"));
    }

    // 4. KYC Verification
    @GetMapping("/kyc/pending")
    @Operation(summary = "List pending Creator KYC applications")
    public ResponseEntity<Page<KycVerification>> getPendingKyc(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(adminService.getPendingKycVerifications(page, size));
    }

    @PostMapping("/kyc/{kycId}/review")
    @Operation(summary = "Approve or Reject a Creator KYC document with reason")
    public ResponseEntity<Map<String, String>> reviewKyc(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @PathVariable UUID kycId,
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        boolean approved = Boolean.TRUE.equals(body.get("approved"));
        String reason = (String) body.get("reason");
        adminService.reviewKyc(kycId, approved, reason, adminUser.getId(), adminUser.getEmail(), getClientIp(request));
        return ResponseEntity.ok(Map.of("message", "KYC status updated successfully"));
    }

    // 5. Call Management
    @GetMapping("/calls")
    @Operation(summary = "Audit consultation call logs, Agora metrics, and billings")
    public ResponseEntity<Page<CallSession>> getCalls(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(adminService.getCallLogs(page, size));
    }

    // 6. Payments & Ledger
    @GetMapping("/transactions")
    @Operation(summary = "Audit platform transactions, wallet recharges & payment ledger")
    public ResponseEntity<Page<Transaction>> getTransactions(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(adminService.getTransactions(page, size));
    }

    // 7. Creator Earnings & Payouts
    @GetMapping("/payouts")
    @Operation(summary = "List creator withdrawal requests")
    public ResponseEntity<Page<PayoutRequest>> getPayouts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String status) {
        return ResponseEntity.ok(adminService.getPayoutRequests(page, size, status));
    }

    @PostMapping("/payouts/{payoutId}/process")
    @Operation(summary = "Approve/Complete or Reject creator withdrawal payout")
    public ResponseEntity<Map<String, String>> processPayout(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @PathVariable UUID payoutId,
            @RequestBody Map<String, String> body,
            HttpServletRequest request) {
        String status = body.getOrDefault("status", "COMPLETED");
        String ref = body.getOrDefault("transactionReference", "ADMIN-PAYOUT-" + UUID.randomUUID().toString().substring(0, 8));
        adminService.processPayout(payoutId, status, ref, adminUser.getEmail(), getClientIp(request));
        return ResponseEntity.ok(Map.of("message", "Payout marked as " + status));
    }

    // 8. Commission & Platform Settings
    @GetMapping("/settings")
    @Operation(summary = "Get platform configuration and commission rules")
    public ResponseEntity<List<PlatformSetting>> getSettings() {
        return ResponseEntity.ok(adminService.getPlatformSettings());
    }

    @PutMapping("/settings")
    @Operation(summary = "Update platform settings or commission percentages")
    public ResponseEntity<PlatformSetting> updateSetting(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @RequestBody Map<String, String> body,
            HttpServletRequest request) {
        String key = body.get("key");
        String value = body.get("value");
        if (key == null || value == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(adminService.updatePlatformSetting(key, value, adminUser.getEmail(), getClientIp(request)));
    }

    // 9. Safety & Moderation Reports
    @GetMapping("/reports")
    @Operation(summary = "List user/creator safety complaints")
    public ResponseEntity<Page<SafetyReport>> getReports(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String status) {
        return ResponseEntity.ok(adminService.getSafetyReports(page, size, status));
    }

    @PostMapping("/reports/{reportId}/resolve")
    @Operation(summary = "Resolve or dismiss safety complaint")
    public ResponseEntity<Map<String, String>> resolveReport(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @PathVariable UUID reportId,
            @RequestBody Map<String, String> body,
            HttpServletRequest request) {
        String status = body.getOrDefault("status", "RESOLVED");
        String notes = body.getOrDefault("notes", "Reviewed by admin");
        adminService.resolveSafetyReport(reportId, status, notes, adminUser.getEmail(), getClientIp(request));
        return ResponseEntity.ok(Map.of("message", "Safety complaint marked as " + status));
    }

    // 10. Notifications & Announcements
    @GetMapping("/announcements")
    @Operation(summary = "List platform announcements")
    public ResponseEntity<Page<PlatformAnnouncement>> getAnnouncements(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(adminService.getAnnouncements(page, size));
    }

    @PostMapping("/announcements")
    @Operation(summary = "Broadcast a new platform announcement")
    public ResponseEntity<PlatformAnnouncement> createAnnouncement(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @RequestBody Map<String, String> body,
            HttpServletRequest request) {
        String title = body.get("title");
        String message = body.get("message");
        String audience = body.getOrDefault("targetAudience", "ALL");
        String priority = body.getOrDefault("priority", "NORMAL");
        return ResponseEntity.ok(adminService.createAnnouncement(title, message, audience, priority, adminUser.getEmail(), getClientIp(request)));
    }

    @DeleteMapping("/announcements/{id}")
    @Operation(summary = "Delete announcement")
    public ResponseEntity<Map<String, String>> deleteAnnouncement(
            @AuthenticationPrincipal UserPrincipal adminUser,
            @PathVariable UUID id,
            HttpServletRequest request) {
        adminService.deleteAnnouncement(id, adminUser.getEmail(), getClientIp(request));
        return ResponseEntity.ok(Map.of("message", "Announcement deleted"));
    }

    // 11. Immutable Audit Logs
    @GetMapping("/audit-logs")
    @Operation(summary = "View immutable administrative audit trail")
    public ResponseEntity<Page<AuditLog>> getAuditLogs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        return ResponseEntity.ok(adminService.getAuditLogs(page, size));
    }
}
