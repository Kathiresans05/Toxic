package com.expertapp.backend.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "safety_reports")
public class SafetyReport {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(name = "reporter_name", nullable = false)
    private String reporterName;

    @Column(name = "reported_user", nullable = false)
    private String reportedUser;

    @Column(name = "reported_user_id")
    private UUID reportedUserId;

    @Column(name = "target_type", nullable = false, length = 20)
    private String targetType = "CREATOR"; // CUSTOMER, CREATOR

    @Column(nullable = false, length = 150)
    private String reason;

    @Column(columnDefinition = "TEXT")
    private String details;

    @Column(nullable = false, length = 30)
    private String status = "PENDING"; // PENDING, RESOLVED, DISMISSED

    @Column(name = "moderator_notes", columnDefinition = "TEXT")
    private String moderatorNotes;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public SafetyReport() {}

    public SafetyReport(String reporterName, String reportedUser, UUID reportedUserId, String targetType, String reason, String details) {
        this.reporterName = reporterName;
        this.reportedUser = reportedUser;
        this.reportedUserId = reportedUserId;
        this.targetType = targetType;
        this.reason = reason;
        this.details = details;
        this.status = "PENDING";
        this.createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }

    public String getReportedUser() { return reportedUser; }
    public void setReportedUser(String reportedUser) { this.reportedUser = reportedUser; }

    public UUID getReportedUserId() { return reportedUserId; }
    public void setReportedUserId(UUID reportedUserId) { this.reportedUserId = reportedUserId; }

    public String getTargetType() { return targetType; }
    public void setTargetType(String targetType) { this.targetType = targetType; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getModeratorNotes() { return moderatorNotes; }
    public void setModeratorNotes(String moderatorNotes) { this.moderatorNotes = moderatorNotes; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
