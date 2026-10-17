package com.expertapp.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "call_sessions")
public class CallSession {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(name = "call_id", nullable = false, unique = true)
    private String callId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "expert_id", nullable = false)
    private ExpertProfile expert;

    @Enumerated(EnumType.STRING)
    @Column(name = "call_type", nullable = false)
    private CallType callType = CallType.VIDEO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CallStatus status = CallStatus.REQUESTED;

    @Column(name = "agora_channel_name", nullable = false)
    private String agoraChannelName;

    @Column(name = "agora_token", columnDefinition = "TEXT")
    private String agoraToken;

    @Column(name = "start_time")
    private Instant startTime;

    @Column(name = "end_time")
    private Instant endTime;

    @Column(name = "duration_seconds")
    private Integer durationSeconds = 0;

    @Column(name = "rate_per_minute", precision = 10, scale = 2, nullable = false)
    private BigDecimal ratePerMinute = BigDecimal.ZERO;

    @Column(name = "total_amount", precision = 10, scale = 2)
    private BigDecimal totalAmount = BigDecimal.ZERO;

    @Column(name = "commission_amount", precision = 10, scale = 2)
    private BigDecimal commissionAmount = BigDecimal.ZERO;

    @Column(name = "expert_earnings", precision = 10, scale = 2)
    private BigDecimal expertEarnings = BigDecimal.ZERO;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at")
    private Instant updatedAt = Instant.now();

    public CallSession() {}

    public CallSession(String callId, User customer, ExpertProfile expert, CallType callType, String agoraChannelName, BigDecimal ratePerMinute) {
        this.callId = callId;
        this.customer = customer;
        this.expert = expert;
        this.callType = callType;
        this.agoraChannelName = agoraChannelName;
        this.ratePerMinute = ratePerMinute;
    }

    @PreUpdate
    public void onUpdate() {
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getCallId() { return callId; }
    public void setCallId(String callId) { this.callId = callId; }

    public User getCustomer() { return customer; }
    public void setCustomer(User customer) { this.customer = customer; }

    public ExpertProfile getExpert() { return expert; }
    public void setExpert(ExpertProfile expert) { this.expert = expert; }

    public CallType getCallType() { return callType; }
    public void setCallType(CallType callType) { this.callType = callType; }

    public CallStatus getStatus() { return status; }
    public void setStatus(CallStatus status) { this.status = status; }

    public String getAgoraChannelName() { return agoraChannelName; }
    public void setAgoraChannelName(String agoraChannelName) { this.agoraChannelName = agoraChannelName; }

    public String getAgoraToken() { return agoraToken; }
    public void setAgoraToken(String agoraToken) { this.agoraToken = agoraToken; }

    public Instant getStartTime() { return startTime; }
    public void setStartTime(Instant startTime) { this.startTime = startTime; }

    public Instant getEndTime() { return endTime; }
    public void setEndTime(Instant endTime) { this.endTime = endTime; }

    public Integer getDurationSeconds() { return durationSeconds; }
    public void setDurationSeconds(Integer durationSeconds) { this.durationSeconds = durationSeconds; }

    public BigDecimal getRatePerMinute() { return ratePerMinute; }
    public void setRatePerMinute(BigDecimal ratePerMinute) { this.ratePerMinute = ratePerMinute; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public BigDecimal getCommissionAmount() { return commissionAmount; }
    public void setCommissionAmount(BigDecimal commissionAmount) { this.commissionAmount = commissionAmount; }

    public BigDecimal getExpertEarnings() { return expertEarnings; }
    public void setExpertEarnings(BigDecimal expertEarnings) { this.expertEarnings = expertEarnings; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
