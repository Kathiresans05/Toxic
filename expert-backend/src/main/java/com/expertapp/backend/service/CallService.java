package com.expertapp.backend.service;

import com.expertapp.backend.dto.CallInitiateRequest;
import com.expertapp.backend.dto.CallSessionResponse;
import com.expertapp.backend.entity.*;
import com.expertapp.backend.repository.CallSessionRepository;
import com.expertapp.backend.repository.ExpertProfileRepository;
import com.expertapp.backend.repository.UserRepository;
import com.expertapp.backend.websocket.CallSignalingWebSocketHandler;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class CallService {

    private final CallSessionRepository callSessionRepository;
    private final UserRepository userRepository;
    private final ExpertProfileRepository expertProfileRepository;
    private final AgoraService agoraService;
    private final NotificationService notificationService;
    private final CallSignalingWebSocketHandler webSocketHandler;

    public CallService(CallSessionRepository callSessionRepository,
                       UserRepository userRepository,
                       ExpertProfileRepository expertProfileRepository,
                       AgoraService agoraService,
                       NotificationService notificationService,
                       CallSignalingWebSocketHandler webSocketHandler) {
        this.callSessionRepository = callSessionRepository;
        this.userRepository = userRepository;
        this.expertProfileRepository = expertProfileRepository;
        this.agoraService = agoraService;
        this.notificationService = notificationService;
        this.webSocketHandler = webSocketHandler;
    }

    @Transactional
    public CallSessionResponse initiateCall(UUID customerId, CallInitiateRequest request) {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new IllegalArgumentException("Customer not found"));

        ExpertProfile expert = expertProfileRepository.findById(request.getExpertId())
                .orElseThrow(() -> new IllegalArgumentException("Expert not found"));

        String callId = "CALL_" + UUID.randomUUID().toString().replace("-", "").substring(0, 12);
        String channelName = "channel_" + callId;

        BigDecimal rate = request.getCallType() == CallType.VIDEO ? expert.getVideoRatePerMin() : expert.getAudioRatePerMin();

        // Generate Agora Token for publisher (customer)
        long customerUid = Math.abs(customerId.getMostSignificantBits() % 10000000L);
        String token = agoraService.generateRtcToken(channelName, customerUid, AgoraService.Role.PUBLISHER);

        CallSession session = new CallSession(callId, customer, expert, request.getCallType(), channelName, rate);
        session.setAgoraToken(token);
        session.setStatus(CallStatus.REQUESTED);
        CallSession saved = callSessionRepository.save(session);

        // Notify Creator via WebSocket
        Map<String, Object> wsAlert = new HashMap<>();
        wsAlert.put("event", "INCOMING_CALL");
        wsAlert.put("callId", callId);
        wsAlert.put("channelName", channelName);
        wsAlert.put("callerName", customer.getFullName());
        wsAlert.put("callType", request.getCallType().name());
        webSocketHandler.sendToUser(expert.getUser().getId().toString(), wsAlert);

        // Notify Creator via Push Notification
        Map<String, String> data = new HashMap<>();
        data.put("callId", callId);
        data.put("type", "CALL_ALERT");
        notificationService.sendPushNotification(
                expert.getUser().getFcmToken(),
                "Incoming " + request.getCallType().name() + " Call",
                customer.getFullName() + " is calling you for consultation",
                data
        );

        return toResponse(saved);
    }

    @Transactional
    public CallSessionResponse acceptCall(String callId, UUID creatorUserId) {
        CallSession session = callSessionRepository.findByCallId(callId)
                .orElseThrow(() -> new IllegalArgumentException("Call not found: " + callId));

        session.setStatus(CallStatus.CONNECTED);
        session.setStartTime(Instant.now());

        // Generate Agora Token for Creator
        long creatorUid = Math.abs(creatorUserId.getMostSignificantBits() % 10000000L);
        String token = agoraService.generateRtcToken(session.getAgoraChannelName(), creatorUid, AgoraService.Role.PUBLISHER);
        session.setAgoraToken(token);

        CallSession saved = callSessionRepository.save(session);

        // Notify Customer that creator accepted
        Map<String, Object> wsAlert = new HashMap<>();
        wsAlert.put("event", "CALL_ACCEPTED");
        wsAlert.put("callId", callId);
        webSocketHandler.sendToUser(session.getCustomer().getId().toString(), wsAlert);

        return toResponse(saved);
    }

    @Transactional
    public CallSessionResponse endCall(String callId) {
        CallSession session = callSessionRepository.findByCallId(callId)
                .orElseThrow(() -> new IllegalArgumentException("Call not found: " + callId));

        session.setEndTime(Instant.now());
        session.setStatus(CallStatus.ENDED);

        if (session.getStartTime() != null) {
            long seconds = Duration.between(session.getStartTime(), session.getEndTime()).getSeconds();
            session.setDurationSeconds((int) seconds);

            // Calculation: minutes * ratePerMinute
            BigDecimal minutes = BigDecimal.valueOf(Math.max(1, Math.ceil(seconds / 60.0)));
            BigDecimal totalAmount = minutes.multiply(session.getRatePerMinute());
            BigDecimal platformFee = totalAmount.multiply(BigDecimal.valueOf(0.20)).setScale(2, RoundingMode.HALF_UP); // 20%
            BigDecimal expertEarnings = totalAmount.subtract(platformFee);

            session.setTotalAmount(totalAmount);
            session.setCommissionAmount(platformFee);
            session.setExpertEarnings(expertEarnings);

            // Credit Expert wallet
            ExpertProfile expert = session.getExpert();
            expert.setWalletBalance(expert.getWalletBalance().add(expertEarnings));
            expert.setTotalConsultations(expert.getTotalConsultations() + 1);
            expertProfileRepository.save(expert);
        }

        CallSession saved = callSessionRepository.save(session);

        // Broadcast Call End event
        Map<String, Object> wsAlert = new HashMap<>();
        wsAlert.put("event", "CALL_ENDED");
        wsAlert.put("callId", callId);
        wsAlert.put("durationSeconds", session.getDurationSeconds());
        wsAlert.put("totalAmount", session.getTotalAmount());
        webSocketHandler.sendToUser(session.getCustomer().getId().toString(), wsAlert);
        webSocketHandler.sendToUser(session.getExpert().getUser().getId().toString(), wsAlert);

        return toResponse(saved);
    }

    private CallSessionResponse toResponse(CallSession session) {
        CallSessionResponse resp = new CallSessionResponse();
        resp.setId(session.getId());
        resp.setCallId(session.getCallId());
        resp.setCustomerId(session.getCustomer().getId());
        resp.setCustomerName(session.getCustomer().getFullName());
        resp.setExpertId(session.getExpert().getId());
        resp.setExpertName(session.getExpert().getUser().getFullName());
        resp.setCallType(session.getCallType());
        resp.setStatus(session.getStatus());
        resp.setAgoraChannelName(session.getAgoraChannelName());
        resp.setAgoraToken(session.getAgoraToken());
        resp.setRatePerMinute(session.getRatePerMinute());
        resp.setDurationSeconds(session.getDurationSeconds());
        resp.setTotalAmount(session.getTotalAmount());
        resp.setCreatedAt(session.getCreatedAt());
        return resp;
    }
}
