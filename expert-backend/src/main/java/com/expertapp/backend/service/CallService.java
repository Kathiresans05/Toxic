package com.expertapp.backend.service;

import com.expertapp.backend.dto.CallInitiateRequest;
import com.expertapp.backend.dto.CallSessionResponse;
import com.expertapp.backend.entity.*;
import com.expertapp.backend.repository.CallSessionRepository;
import com.expertapp.backend.repository.ExpertProfileRepository;
import com.expertapp.backend.repository.SafetyReportRepository;
import com.expertapp.backend.repository.UserRepository;
import com.expertapp.backend.websocket.CallSignalingWebSocketHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class CallService {

    private static final Logger log = LoggerFactory.getLogger(CallService.class);

    private final CallSessionRepository callSessionRepository;
    private final UserRepository userRepository;
    private final ExpertProfileRepository expertProfileRepository;
    private final AgoraService agoraService;
    private final NotificationService notificationService;
    private final CallSignalingWebSocketHandler webSocketHandler;
    private final SafetyReportRepository safetyReportRepository;

    private final Set<String> warnedCalls = ConcurrentHashMap.newKeySet();

    public CallService(CallSessionRepository callSessionRepository,
                       UserRepository userRepository,
                       ExpertProfileRepository expertProfileRepository,
                       AgoraService agoraService,
                       NotificationService notificationService,
                       CallSignalingWebSocketHandler webSocketHandler,
                       SafetyReportRepository safetyReportRepository) {
        this.callSessionRepository = callSessionRepository;
        this.userRepository = userRepository;
        this.expertProfileRepository = expertProfileRepository;
        this.agoraService = agoraService;
        this.notificationService = notificationService;
        this.webSocketHandler = webSocketHandler;
        this.safetyReportRepository = safetyReportRepository;
    }

    @Transactional
    public CallSessionResponse initiateCall(UUID customerId, CallInitiateRequest request) {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new IllegalArgumentException("Customer not found"));

        ExpertProfile expert = expertProfileRepository.findById(request.getExpertId())
                .or(() -> expertProfileRepository.findByUserId(request.getExpertId()))
                .orElseThrow(() -> new IllegalArgumentException("Expert not found"));

        String callId = "CALL_" + UUID.randomUUID().toString().replace("-", "").substring(0, 12);
        String channelName = "channel_" + callId;

        BigDecimal rate = request.getCallType() == CallType.VIDEO ? expert.getVideoRatePerMin() : expert.getAudioRatePerMin();

        // 1. Availability check
        if (!expert.isAvailable()) {
            throw new IllegalArgumentException("Creator is currently offline or unavailable for calls.");
        }

        // 2. Minimum Wallet Balance Guard: Customer must have at least 1 minute consultation fee
        BigDecimal customerBalance = customer.getWalletBalance() != null ? customer.getWalletBalance() : BigDecimal.ZERO;
        if (customerBalance.compareTo(rate) < 0) {
            throw new IllegalArgumentException("Insufficient wallet balance. Minimum ₹" + rate + " required for a 1-minute consultation. Current balance: ₹" + customerBalance);
        }

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
        wsAlert.put("callerId", customer.getId().toString());
        wsAlert.put("callType", request.getCallType().name());
        wsAlert.put("pricePerMinute", rate);
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
        wsAlert.put("channelName", session.getAgoraChannelName());
        webSocketHandler.sendToUser(session.getCustomer().getId().toString(), wsAlert);

        return toResponse(saved);
    }

    @Transactional
    public void rejectCall(String callId) {
        CallSession session = callSessionRepository.findByCallId(callId)
                .orElseThrow(() -> new IllegalArgumentException("Call not found: " + callId));

        session.setStatus(CallStatus.REJECTED);
        session.setEndTime(Instant.now());
        callSessionRepository.save(session);

        // Notify Customer that creator rejected / declined via WebSocket
        Map<String, Object> wsAlert = new HashMap<>();
        wsAlert.put("event", "CALL_REJECTED");
        wsAlert.put("callId", callId);
        webSocketHandler.sendToUser(session.getCustomer().getId().toString(), wsAlert);
    }

    @Transactional
    public CallSessionResponse endCall(String callId) {
        return endCall(callId, null);
    }

    @Transactional
    public CallSessionResponse endCall(String callId, String reason) {
        CallSession session = callSessionRepository.findByCallId(callId)
                .orElseThrow(() -> new IllegalArgumentException("Call not found: " + callId));

        warnedCalls.remove(callId);

        // Idempotency Protection: If already ended, return existing response without re-calculating or duplicate crediting
        if (session.getStatus() == CallStatus.ENDED) {
            return toResponse(session);
        }

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

            // 1. Deduct Customer Wallet in Atomic Transaction
            User customer = session.getCustomer();
            if (customer != null) {
                BigDecimal currentCustBalance = customer.getWalletBalance() != null ? customer.getWalletBalance() : BigDecimal.ZERO;
                BigDecimal newCustBalance = currentCustBalance.subtract(totalAmount);
                if (newCustBalance.compareTo(BigDecimal.ZERO) < 0) {
                    newCustBalance = BigDecimal.ZERO;
                }
                customer.setWalletBalance(newCustBalance);
                userRepository.save(customer);
            }

            // 2. Credit Expert wallet
            ExpertProfile expert = session.getExpert();
            if (expert != null) {
                BigDecimal currentExpBalance = expert.getWalletBalance() != null ? expert.getWalletBalance() : BigDecimal.ZERO;
                expert.setWalletBalance(currentExpBalance.add(expertEarnings));
                expert.setTotalConsultations(expert.getTotalConsultations() + 1);
                expertProfileRepository.save(expert);
            }
        }

        CallSession saved = callSessionRepository.save(session);

        // Broadcast Call End event with optional termination reason
        Map<String, Object> wsAlert = new HashMap<>();
        wsAlert.put("event", "CALL_ENDED");
        wsAlert.put("callId", callId);
        wsAlert.put("durationSeconds", session.getDurationSeconds());
        wsAlert.put("totalAmount", session.getTotalAmount());
        if (reason != null && !reason.isBlank()) {
            wsAlert.put("reason", reason);
        }
        webSocketHandler.sendToUser(session.getCustomer().getId().toString(), wsAlert);
        webSocketHandler.sendToUser(session.getExpert().getUser().getId().toString(), wsAlert);

        return toResponse(saved);
    }

    /**
     * Periodic background check (every 5 seconds) to monitor active calls.
     * Automatically disconnects calls if customer wallet runs out,
     * and sends real-time low-balance warnings before disconnection.
     */
    @Scheduled(fixedRate = 5000)
    @Transactional
    public void monitorActiveCallBalances() {
        List<CallSession> activeCalls = callSessionRepository.findByStatus(CallStatus.CONNECTED);
        if (activeCalls == null || activeCalls.isEmpty()) {
            return;
        }

        Instant now = Instant.now();
        for (CallSession session : activeCalls) {
            try {
                if (session.getStartTime() == null || session.getCustomer() == null) {
                    continue;
                }

                User customer = userRepository.findById(session.getCustomer().getId()).orElse(null);
                if (customer == null) continue;

                BigDecimal walletBalance = customer.getWalletBalance() != null ? customer.getWalletBalance() : BigDecimal.ZERO;
                BigDecimal ratePerMin = session.getRatePerMinute() != null ? session.getRatePerMinute() : BigDecimal.ZERO;

                if (ratePerMin.compareTo(BigDecimal.ZERO) <= 0) {
                    continue; // Complimentary / zero rate
                }

                long secondsElapsed = Duration.between(session.getStartTime(), now).getSeconds();
                // Max allowed duration in seconds before wallet drops below zero
                long maxAllowedSeconds = walletBalance.divide(ratePerMin, 4, RoundingMode.FLOOR)
                        .multiply(BigDecimal.valueOf(60)).longValue();

                long remainingSeconds = maxAllowedSeconds - secondsElapsed;

                // 1. AUTO-DISCONNECT: Wallet balance exhausted
                if (remainingSeconds <= 0) {
                    log.info("Auto-disconnecting call {} due to exhausted customer balance (Elapsed: {}s, MaxAllowed: {}s)",
                            session.getCallId(), secondsElapsed, maxAllowedSeconds);
                    endCall(session.getCallId(), "INSUFFICIENT_BALANCE");
                    continue;
                }

                // 2. LOW BALANCE WARNING: Less than 60 seconds remaining
                if (remainingSeconds <= 60 && !warnedCalls.contains(session.getCallId())) {
                    warnedCalls.add(session.getCallId());
                    Map<String, Object> warningAlert = new HashMap<>();
                    warningAlert.put("event", "LOW_BALANCE_WARNING");
                    warningAlert.put("callId", session.getCallId());
                    warningAlert.put("remainingSeconds", remainingSeconds);
                    warningAlert.put("message", "Low balance warning: Less than 1 minute remaining. Please recharge your wallet soon.");
                    webSocketHandler.sendToUser(customer.getId().toString(), warningAlert);
                }
            } catch (Exception ex) {
                log.error("Error monitoring active call session {}", session.getCallId(), ex);
            }
        }
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

    @Transactional
    public void reportCall(UUID reporterUserId, String callId, String reason, String details, String targetType) {
        Optional<CallSession> sessionOpt = callSessionRepository.findByCallId(callId);
        String reporterName = "Anonymous Caller";
        String reportedUser = "Reported User";
        UUID reportedUserId = null;

        if (sessionOpt.isPresent()) {
            CallSession session = sessionOpt.get();
            if ("CREATOR".equalsIgnoreCase(targetType)) {
                reporterName = session.getCustomer() != null ? session.getCustomer().getFullName() : "Customer";
                reportedUser = session.getExpert() != null && session.getExpert().getUser() != null
                        ? session.getExpert().getUser().getFullName() : "Creator";
                reportedUserId = session.getExpert() != null && session.getExpert().getUser() != null
                        ? session.getExpert().getUser().getId() : null;
            } else {
                reporterName = session.getExpert() != null && session.getExpert().getUser() != null
                        ? session.getExpert().getUser().getFullName() : "Creator";
                reportedUser = session.getCustomer() != null ? session.getCustomer().getFullName() : "Customer";
                reportedUserId = session.getCustomer() != null ? session.getCustomer().getId() : null;
            }
        } else if (reporterUserId != null) {
            userRepository.findById(reporterUserId).ifPresent(u -> {
                // Keep default or set name if available
            });
        }

        SafetyReport report = new SafetyReport(
                reporterName,
                reportedUser,
                reportedUserId,
                targetType != null ? targetType.toUpperCase() : "CREATOR",
                reason != null ? reason : "Safety violation reported in call",
                details != null && !details.isBlank() ? details : "Call incident logged for session " + callId
        );
        safetyReportRepository.save(report);
    }

    @Transactional(readOnly = true)
    public List<CallSessionResponse> getCustomerCallHistory(UUID customerId) {
        org.springframework.data.domain.Pageable pageable =
                org.springframework.data.domain.PageRequest.of(0, 50, org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC, "createdAt"));
        return callSessionRepository.findByCustomerId(customerId, pageable)
                .getContent()
                .stream()
                .map(this::toResponse)
                .toList();
    }
}

