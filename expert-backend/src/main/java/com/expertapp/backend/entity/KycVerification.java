package com.expertapp.backend.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "kyc_verifications")
public class KycVerification {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "expert_id", nullable = false)
    private ExpertProfile expert;

    @Column(name = "id_type", nullable = false, length = 50)
    private String idType;

    @Column(name = "id_number", nullable = false, length = 100)
    private String idNumber;

    @Column(name = "document_front_url", nullable = false)
    private String documentFrontUrl;

    @Column(name = "document_back_url")
    private String documentBackUrl;

    @Column(name = "selfie_url")
    private String selfieUrl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private KycStatus status = KycStatus.PENDING;

    @Column(name = "rejection_reason", columnDefinition = "TEXT")
    private String rejectionReason;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewed_by")
    private User reviewedBy;

    @Column(name = "reviewed_at")
    private Instant reviewedAt;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt = Instant.now();

    public KycVerification() {}

    public KycVerification(ExpertProfile expert, String idType, String idNumber, String documentFrontUrl) {
        this.expert = expert;
        this.idType = idType;
        this.idNumber = idNumber;
        this.documentFrontUrl = documentFrontUrl;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public ExpertProfile getExpert() { return expert; }
    public void setExpert(ExpertProfile expert) { this.expert = expert; }

    public String getIdType() { return idType; }
    public void setIdType(String idType) { this.idType = idType; }

    public String getIdNumber() { return idNumber; }
    public void setIdNumber(String idNumber) { this.idNumber = idNumber; }

    public String getDocumentFrontUrl() { return documentFrontUrl; }
    public void setDocumentFrontUrl(String documentFrontUrl) { this.documentFrontUrl = documentFrontUrl; }

    public String getDocumentBackUrl() { return documentBackUrl; }
    public void setDocumentBackUrl(String documentBackUrl) { this.documentBackUrl = documentBackUrl; }

    public String getSelfieUrl() { return selfieUrl; }
    public void setSelfieUrl(String selfieUrl) { this.selfieUrl = selfieUrl; }

    public KycStatus getStatus() { return status; }
    public void setStatus(KycStatus status) { this.status = status; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    public User getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(User reviewedBy) { this.reviewedBy = reviewedBy; }

    public Instant getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Instant reviewedAt) { this.reviewedAt = reviewedAt; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
