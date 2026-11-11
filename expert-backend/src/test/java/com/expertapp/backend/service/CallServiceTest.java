package com.expertapp.backend.service;

import com.expertapp.backend.entity.*;
import com.expertapp.backend.repository.CallSessionRepository;
import com.expertapp.backend.repository.ExpertProfileRepository;
import com.expertapp.backend.repository.SafetyReportRepository;
import com.expertapp.backend.repository.UserRepository;
import com.expertapp.backend.websocket.CallSignalingWebSocketHandler;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CallServiceTest {

    @Mock
    private CallSessionRepository callSessionRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ExpertProfileRepository expertProfileRepository;

    @Mock
    private AgoraService agoraService;

    @Mock
    private NotificationService notificationService;

    @Mock
    private CallSignalingWebSocketHandler webSocketHandler;

    @Mock
    private SafetyReportRepository safetyReportRepository;

    @InjectMocks
    private CallService callService;

    @Test
    void testReportCallAsCustomer() {
        String callId = "CALL_123456";
        User customer = new User("cust@test.com", "+919999999991", "pwd", "Ravi Customer", Role.ROLE_CUSTOMER);
        customer.setId(UUID.randomUUID());

        User expertUser = new User("host@test.com", "+919999999992", "pwd", "Priya Host", Role.ROLE_CREATOR);
        expertUser.setId(UUID.randomUUID());

        ExpertProfile expertProfile = new ExpertProfile(expertUser, null, "Relationship Consultant", BigDecimal.valueOf(30), BigDecimal.valueOf(50));
        expertProfile.setId(UUID.randomUUID());

        CallSession session = new CallSession(callId, customer, expertProfile, CallType.AUDIO, "channel_123", BigDecimal.valueOf(30));

        when(callSessionRepository.findByCallId(callId)).thenReturn(Optional.of(session));
        when(safetyReportRepository.save(any(SafetyReport.class))).thenAnswer(i -> i.getArgument(0));

        callService.reportCall(customer.getId(), callId, "Abusive language", "Caller used bad words", "CREATOR");

        ArgumentCaptor<SafetyReport> captor = ArgumentCaptor.forClass(SafetyReport.class);
        verify(safetyReportRepository, times(1)).save(captor.capture());

        SafetyReport saved = captor.getValue();
        assertEquals("Ravi Customer", saved.getReporterName());
        assertEquals("Priya Host", saved.getReportedUser());
        assertEquals("CREATOR", saved.getTargetType());
        assertEquals("Abusive language", saved.getReason());
        assertEquals("PENDING", saved.getStatus());
    }

    @Test
    void testReportCallAsCreator() {
        String callId = "CALL_789012";
        User customer = new User("cust@test.com", "+919999999991", "pwd", "Toxic Caller", Role.ROLE_CUSTOMER);
        customer.setId(UUID.randomUUID());

        User expertUser = new User("host@test.com", "+919999999992", "pwd", "Priya Host", Role.ROLE_CREATOR);
        expertUser.setId(UUID.randomUUID());

        ExpertProfile expertProfile = new ExpertProfile(expertUser, null, "Astrology Expert", BigDecimal.valueOf(25), BigDecimal.valueOf(45));

        CallSession session = new CallSession(callId, customer, expertProfile, CallType.VIDEO, "channel_456", BigDecimal.valueOf(45));

        when(callSessionRepository.findByCallId(callId)).thenReturn(Optional.of(session));
        when(safetyReportRepository.save(any(SafetyReport.class))).thenAnswer(i -> i.getArgument(0));

        callService.reportCall(expertUser.getId(), callId, "Inappropriate video / Vulgar gestures", "Caller misbehaved on camera", "CUSTOMER");

        ArgumentCaptor<SafetyReport> captor = ArgumentCaptor.forClass(SafetyReport.class);
        verify(safetyReportRepository, times(1)).save(captor.capture());

        SafetyReport saved = captor.getValue();
        assertEquals("Priya Host", saved.getReporterName());
        assertEquals("Toxic Caller", saved.getReportedUser());
        assertEquals("CUSTOMER", saved.getTargetType());
        assertEquals("Inappropriate video / Vulgar gestures", saved.getReason());
        assertEquals("PENDING", saved.getStatus());
    }
}
