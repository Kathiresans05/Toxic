package com.expertapp.backend.dto;

import com.expertapp.backend.entity.CallStatus;
import com.expertapp.backend.entity.CallType;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public class CallSessionResponse {

    private UUID id;
    private String callId;
    private UUID customerId;
    private String customerName;
    private UUID expertId;
    private String expertName;
    private CallType callType;
    private CallStatus status;
    private String agoraChannelName;
    private String agoraToken;
    private BigDecimal ratePerMinute;
    private Integer durationSeconds;
    private BigDecimal totalAmount;
    private Instant createdAt;

    public CallSessionResponse() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getCallId() { return callId; }
    public void setCallId(String callId) { this.callId = callId; }

    public UUID getCustomerId() { return customerId; }
    public void setCustomerId(UUID customerId) { this.customerId = customerId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public UUID getExpertId() { return expertId; }
    public void setExpertId(UUID expertId) { this.expertId = expertId; }

    public String getExpertName() { return expertName; }
    public void setExpertName(String expertName) { this.expertName = expertName; }

    public CallType getCallType() { return callType; }
    public void setCallType(CallType callType) { this.callType = callType; }

    public CallStatus getStatus() { return status; }
    public void setStatus(CallStatus status) { this.status = status; }

    public String getAgoraChannelName() { return agoraChannelName; }
    public void setAgoraChannelName(String agoraChannelName) { this.agoraChannelName = agoraChannelName; }

    public String getAgoraToken() { return agoraToken; }
    public void setAgoraToken(String agoraToken) { this.agoraToken = agoraToken; }

    public BigDecimal getRatePerMinute() { return ratePerMinute; }
    public void setRatePerMinute(BigDecimal ratePerMinute) { this.ratePerMinute = ratePerMinute; }

    public Integer getDurationSeconds() { return durationSeconds; }
    public void setDurationSeconds(Integer durationSeconds) { this.durationSeconds = durationSeconds; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
