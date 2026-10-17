package com.expertapp.backend.service;

import com.expertapp.backend.dto.DashboardStatsResponse;
import com.expertapp.backend.entity.*;
import com.expertapp.backend.repository.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

@Service
public class AdminService {

    private final UserRepository userRepository;
    private final ExpertProfileRepository expertProfileRepository;
    private final CallSessionRepository callSessionRepository;
    private final KycVerificationRepository kycVerificationRepository;
    private final PayoutRequestRepository payoutRequestRepository;
    private final TransactionRepository transactionRepository;
    private final AuditLogRepository auditLogRepository;
    private final PlatformSettingRepository platformSettingRepository;
    private final SafetyReportRepository safetyReportRepository;
    private final PlatformAnnouncementRepository announcementRepository;

    public AdminService(UserRepository userRepository,
                        ExpertProfileRepository expertProfileRepository,
                        CallSessionRepository callSessionRepository,
                        KycVerificationRepository kycVerificationRepository,
                        PayoutRequestRepository payoutRequestRepository,
                        TransactionRepository transactionRepository,
                        AuditLogRepository auditLogRepository,
                        PlatformSettingRepository platformSettingRepository,
                        SafetyReportRepository safetyReportRepository,
                        PlatformAnnouncementRepository announcementRepository) {
        this.userRepository = userRepository;
        this.expertProfileRepository = expertProfileRepository;
        this.callSessionRepository = callSessionRepository;
        this.kycVerificationRepository = kycVerificationRepository;
        this.payoutRequestRepository = payoutRequestRepository;
        this.transactionRepository = transactionRepository;
        this.auditLogRepository = auditLogRepository;
        this.platformSettingRepository = platformSettingRepository;
        this.safetyReportRepository = safetyReportRepository;
        this.announcementRepository = announcementRepository;
    }

    public void logAudit(String action, String details, String adminEmail, String ip) {
        try {
            AuditLog log = new AuditLog(action, details, adminEmail != null ? adminEmail : "admin@expertapp.com", ip);
            auditLogRepository.save(log);
        } catch (Exception e) {
            // Non-blocking for audit failures
        }
    }

    @Transactional(readOnly = true)
    public DashboardStatsResponse getDashboardStats() {
        DashboardStatsResponse stats = new DashboardStatsResponse();
        stats.setTotalCustomers(userRepository.countByRole(Role.ROLE_CUSTOMER));
        stats.setTotalCreators(expertProfileRepository.countByApprovedTrue());
        stats.setActiveCallsCount(callSessionRepository.countByStatus(CallStatus.CONNECTED));
        stats.setCompletedCallsCount(callSessionRepository.countByStatus(CallStatus.ENDED));

        BigDecimal gmv = callSessionRepository.calculateTotalGrossVolume();
        stats.setTotalGrossVolume(gmv != null ? gmv : BigDecimal.ZERO);

        BigDecimal revenue = callSessionRepository.calculateTotalPlatformRevenue();
        stats.setTotalPlatformRevenue(revenue != null ? revenue : BigDecimal.ZERO);

        stats.setPendingKycCount(kycVerificationRepository.countByStatus(KycStatus.PENDING));
        stats.setPendingPayoutsCount(payoutRequestRepository.countByStatus("REQUESTED"));
        stats.setPendingReportsCount(safetyReportRepository.countByStatus("PENDING"));

        return stats;
    }

    // 1. Users
    @Transactional(readOnly = true)
    public Page<User> getUsers(int page, int size, String search) {
        PageRequest pageRequest = PageRequest.of(page, size, Sort.by("createdAt").descending());
        if (search != null && !search.trim().isEmpty()) {
            return userRepository.searchUsers(search.trim(), pageRequest);
        }
        return userRepository.findAll(pageRequest);
    }

    @Transactional
    public void toggleUserStatus(UUID userId, boolean active, String adminEmail, String ip) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        user.setActive(active);
        userRepository.save(user);

        logAudit("USER_STATUS_UPDATE",
                "User " + user.getEmail() + " status set to: " + (active ? "ACTIVE" : "SUSPENDED"),
                adminEmail, ip);
    }

    // 2. Creators
    @Transactional(readOnly = true)
    public Page<ExpertProfile> getCreators(int page, int size) {
        return expertProfileRepository.findAll(PageRequest.of(page, size, Sort.by("createdAt").descending()));
    }

    @Transactional
    public void toggleCreatorApproval(UUID expertId, boolean approved, String adminEmail, String ip) {
        ExpertProfile expert = expertProfileRepository.findById(expertId)
                .orElseThrow(() -> new IllegalArgumentException("Creator not found: " + expertId));
        expert.setApproved(approved);
        expertProfileRepository.save(expert);

        logAudit("CREATOR_APPROVAL_TOGGLE",
                "Creator " + (expert.getUser() != null ? expert.getUser().getFullName() : expertId) + " approval set to: " + approved,
                adminEmail, ip);
    }

    @Transactional
    public void updateCreatorRates(UUID expertId, BigDecimal audioRate, BigDecimal videoRate, String adminEmail, String ip) {
        ExpertProfile expert = expertProfileRepository.findById(expertId)
                .orElseThrow(() -> new IllegalArgumentException("Creator not found: " + expertId));
        if (audioRate != null) expert.setAudioRatePerMin(audioRate);
        if (videoRate != null) expert.setVideoRatePerMin(videoRate);
        expertProfileRepository.save(expert);

        logAudit("CREATOR_RATES_UPDATED",
                "Creator " + (expert.getUser() != null ? expert.getUser().getFullName() : expertId) + " rates updated: Audio ₹" + audioRate + "/m, Video ₹" + videoRate + "/m",
                adminEmail, ip);
    }

    // 3. KYC Verification
    @Transactional(readOnly = true)
    public Page<KycVerification> getPendingKycVerifications(int page, int size) {
        return kycVerificationRepository.findByStatus(KycStatus.PENDING, PageRequest.of(page, size, Sort.by("createdAt").ascending()));
    }

    @Transactional
    public void reviewKyc(UUID kycId, boolean approved, String reason, UUID adminUserId, String adminEmail, String ip) {
        KycVerification kyc = kycVerificationRepository.findById(kycId)
                .orElseThrow(() -> new IllegalArgumentException("KYC record not found"));

        User admin = adminUserId != null ? userRepository.findById(adminUserId).orElse(null) : null;

        kyc.setStatus(approved ? KycStatus.APPROVED : KycStatus.REJECTED);
        kyc.setRejectionReason(approved ? null : reason);
        kyc.setReviewedBy(admin);
        kyc.setReviewedAt(Instant.now());
        kycVerificationRepository.save(kyc);

        ExpertProfile expert = kyc.getExpert();
        expert.setKycStatus(kyc.getStatus());
        if (approved) {
            expert.setApproved(true);
        }
        expertProfileRepository.save(expert);

        logAudit("KYC_REVIEW",
                "KYC application " + kycId + " for " + (expert.getUser() != null ? expert.getUser().getFullName() : "Creator") + " was " + (approved ? "APPROVED" : "REJECTED. Reason: " + reason),
                adminEmail, ip);
    }

    // 4. Calls
    @Transactional(readOnly = true)
    public Page<CallSession> getCallLogs(int page, int size) {
        return callSessionRepository.findAll(PageRequest.of(page, size, Sort.by("createdAt").descending()));
    }

    // 5. Transactions
    @Transactional(readOnly = true)
    public Page<Transaction> getTransactions(int page, int size) {
        return transactionRepository.findAll(PageRequest.of(page, size, Sort.by("createdAt").descending()));
    }

    // 6. Creator Payouts
    @Transactional(readOnly = true)
    public Page<PayoutRequest> getPayoutRequests(int page, int size, String status) {
        PageRequest pageRequest = PageRequest.of(page, size, Sort.by("createdAt").descending());
        if (status != null && !status.equalsIgnoreCase("ALL")) {
            return payoutRequestRepository.findByStatus(status.toUpperCase(), pageRequest);
        }
        return payoutRequestRepository.findAll(pageRequest);
    }

    @Transactional
    public void processPayout(UUID payoutId, String status, String transactionReference, String adminEmail, String ip) {
        PayoutRequest payout = payoutRequestRepository.findById(payoutId)
                .orElseThrow(() -> new IllegalArgumentException("Payout request not found: " + payoutId));

        payout.setStatus(status.toUpperCase());
        payout.setTransactionReference(transactionReference);
        payout.setProcessedAt(Instant.now());
        payoutRequestRepository.save(payout);

        // If completed or rejected, handle expert wallet adjustments if applicable
        ExpertProfile expert = payout.getExpert();
        if ("REJECTED".equalsIgnoreCase(status) && expert != null) {
            // Refund to wallet balance
            expert.setWalletBalance(expert.getWalletBalance().add(payout.getAmount()));
            expertProfileRepository.save(expert);
        }

        logAudit("PAYOUT_PROCESSED",
                "Payout " + payoutId + " of ₹" + payout.getAmount() + " status set to " + status.toUpperCase() + ". Ref: " + transactionReference,
                adminEmail, ip);
    }

    // 7. Platform Settings
    @Transactional(readOnly = true)
    public List<PlatformSetting> getPlatformSettings() {
        List<PlatformSetting> settings = platformSettingRepository.findAll();
        if (settings.isEmpty()) {
            // Seed defaults
            List<PlatformSetting> defaults = Arrays.asList(
                    new PlatformSetting("platform_commission_pct", "20", "Platform commission deduction percentage (e.g. 20%)"),
                    new PlatformSetting("min_audio_rate", "10", "Minimum permissible audio call rate per minute in INR"),
                    new PlatformSetting("max_audio_rate", "500", "Maximum permissible audio call rate per minute in INR"),
                    new PlatformSetting("min_video_rate", "20", "Minimum permissible video call rate per minute in INR"),
                    new PlatformSetting("max_video_rate", "1000", "Maximum permissible video call rate per minute in INR"),
                    new PlatformSetting("min_payout_amount", "500", "Minimum creator withdrawal request threshold in INR"),
                    new PlatformSetting("auto_approve_kyc", "false", "Automatically approve creator KYC verification without manual review"),
                    new PlatformSetting("support_email", "support@expertapp.com", "Platform support email visible to customers and creators")
            );
            return platformSettingRepository.saveAll(defaults);
        }
        return settings;
    }

    @Transactional
    public PlatformSetting updatePlatformSetting(String key, String value, String adminEmail, String ip) {
        PlatformSetting setting = platformSettingRepository.findByKey(key)
                .orElse(new PlatformSetting(key, value, "Platform setting for " + key));
        setting.setValue(value);
        setting.setUpdatedAt(Instant.now());
        PlatformSetting saved = platformSettingRepository.save(setting);

        logAudit("SETTING_UPDATE",
                "Setting " + key + " updated to: " + value,
                adminEmail, ip);
        return saved;
    }

    // 8. Safety & Moderation Reports
    @Transactional(readOnly = true)
    public Page<SafetyReport> getSafetyReports(int page, int size, String status) {
        PageRequest pageRequest = PageRequest.of(page, size, Sort.by("createdAt").descending());
        if (status != null && !status.equalsIgnoreCase("ALL")) {
            return safetyReportRepository.findByStatus(status.toUpperCase(), pageRequest);
        }
        return safetyReportRepository.findAll(pageRequest);
    }

    @Transactional
    public void resolveSafetyReport(UUID reportId, String status, String notes, String adminEmail, String ip) {
        SafetyReport report = safetyReportRepository.findById(reportId)
                .orElseThrow(() -> new IllegalArgumentException("Report not found: " + reportId));
        report.setStatus(status.toUpperCase());
        report.setModeratorNotes(notes);
        safetyReportRepository.save(report);

        logAudit("SAFETY_REPORT_RESOLVED",
                "Safety complaint " + reportId + " marked as " + status + ". Notes: " + notes,
                adminEmail, ip);
    }

    // 9. Platform Announcements
    @Transactional(readOnly = true)
    public Page<PlatformAnnouncement> getAnnouncements(int page, int size) {
        return announcementRepository.findAllByOrderByCreatedAtDesc(PageRequest.of(page, size));
    }

    @Transactional
    public PlatformAnnouncement createAnnouncement(String title, String message, String audience, String priority, String adminEmail, String ip) {
        PlatformAnnouncement announcement = new PlatformAnnouncement(title, message, audience, priority);
        PlatformAnnouncement saved = announcementRepository.save(announcement);

        logAudit("ANNOUNCEMENT_CREATED",
                "Created announcement: " + title + " (Audience: " + audience + ", Priority: " + priority + ")",
                adminEmail, ip);
        return saved;
    }

    @Transactional
    public void deleteAnnouncement(UUID id, String adminEmail, String ip) {
        announcementRepository.deleteById(id);
        logAudit("ANNOUNCEMENT_DELETED", "Deleted announcement " + id, adminEmail, ip);
    }

    // 10. Audit Logs
    @Transactional(readOnly = true)
    public Page<AuditLog> getAuditLogs(int page, int size) {
        return auditLogRepository.findAllByOrderByCreatedAtDesc(PageRequest.of(page, size));
    }
}
