package com.expertapp.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "expert_profiles")
public class ExpertProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "category_id")
    private Category category;

    private String headline;

    @Column(columnDefinition = "TEXT")
    private String bio;

    @Column(name = "experience_years")
    private Integer experienceYears = 0;

    @Column(name = "audio_rate_per_min", precision = 10, scale = 2)
    private BigDecimal audioRatePerMin = BigDecimal.ZERO;

    @Column(name = "video_rate_per_min", precision = 10, scale = 2)
    private BigDecimal videoRatePerMin = BigDecimal.ZERO;

    @Column(name = "is_available", nullable = false)
    private boolean available = true;

    @Column(name = "is_approved", nullable = false)
    private boolean approved = false;

    @Column(name = "rating_average", precision = 3, scale = 2)
    private BigDecimal ratingAverage = BigDecimal.valueOf(5.00);

    @Column(name = "total_reviews")
    private Integer totalReviews = 0;

    @Column(name = "total_consultations")
    private Integer totalConsultations = 0;

    @Column(name = "agora_uid")
    private Long agoraUid;

    @Enumerated(EnumType.STRING)
    @Column(name = "kyc_status", nullable = false)
    private KycStatus kycStatus = KycStatus.NOT_SUBMITTED;

    @Column(name = "wallet_balance", precision = 12, scale = 2)
    private BigDecimal walletBalance = BigDecimal.ZERO;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at")
    private Instant updatedAt = Instant.now();

    public ExpertProfile() {}

    public ExpertProfile(User user, Category category, String headline, BigDecimal audioRatePerMin, BigDecimal videoRatePerMin) {
        this.user = user;
        this.category = category;
        this.headline = headline;
        this.audioRatePerMin = audioRatePerMin;
        this.videoRatePerMin = videoRatePerMin;
    }

    @PreUpdate
    public void onUpdate() {
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }

    public String getHeadline() { return headline; }
    public void setHeadline(String headline) { this.headline = headline; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public Integer getExperienceYears() { return experienceYears; }
    public void setExperienceYears(Integer experienceYears) { this.experienceYears = experienceYears; }

    public BigDecimal getAudioRatePerMin() { return audioRatePerMin; }
    public void setAudioRatePerMin(BigDecimal audioRatePerMin) { this.audioRatePerMin = audioRatePerMin; }

    public BigDecimal getVideoRatePerMin() { return videoRatePerMin; }
    public void setVideoRatePerMin(BigDecimal videoRatePerMin) { this.videoRatePerMin = videoRatePerMin; }

    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }

    public boolean isApproved() { return approved; }
    public void setApproved(boolean approved) { this.approved = approved; }

    public BigDecimal getRatingAverage() { return ratingAverage; }
    public void setRatingAverage(BigDecimal ratingAverage) { this.ratingAverage = ratingAverage; }

    public Integer getTotalReviews() { return totalReviews; }
    public void setTotalReviews(Integer totalReviews) { this.totalReviews = totalReviews; }

    public Integer getTotalConsultations() { return totalConsultations; }
    public void setTotalConsultations(Integer totalConsultations) { this.totalConsultations = totalConsultations; }

    public Long getAgoraUid() { return agoraUid; }
    public void setAgoraUid(Long agoraUid) { this.agoraUid = agoraUid; }

    public KycStatus getKycStatus() { return kycStatus; }
    public void setKycStatus(KycStatus kycStatus) { this.kycStatus = kycStatus; }

    public BigDecimal getWalletBalance() { return walletBalance; }
    public void setWalletBalance(BigDecimal walletBalance) { this.walletBalance = walletBalance; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
