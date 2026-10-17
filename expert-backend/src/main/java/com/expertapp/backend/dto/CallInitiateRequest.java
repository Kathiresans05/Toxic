package com.expertapp.backend.dto;

import com.expertapp.backend.entity.CallType;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public class CallInitiateRequest {

    @NotNull
    private UUID expertId;

    private CallType callType = CallType.VIDEO;

    public CallInitiateRequest() {}

    public UUID getExpertId() { return expertId; }
    public void setExpertId(UUID expertId) { this.expertId = expertId; }

    public CallType getCallType() { return callType; }
    public void setCallType(CallType callType) { this.callType = callType; }
}
