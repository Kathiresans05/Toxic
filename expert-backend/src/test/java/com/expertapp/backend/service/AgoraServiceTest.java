package com.expertapp.backend.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.*;

class AgoraServiceTest {

    private AgoraService agoraService;

    @BeforeEach
    void setUp() {
        agoraService = new AgoraService();
    }

    @Test
    @DisplayName("Test secure RTC token generation with valid Agora credentials")
    void testGenerateRtcTokenWithValidCredentials() {
        // Configure test Agora App ID and Certificate
        ReflectionTestUtils.setField(agoraService, "appId", "test_app_id_1234567890abcdef");
        ReflectionTestUtils.setField(agoraService, "appCertificate", "test_cert_1234567890abcdef");
        ReflectionTestUtils.setField(agoraService, "tokenExpirationSeconds", 3600);

        String channelName = "channel_consultation_sec_99";
        long uid = 123456L;

        String token = agoraService.generateRtcToken(channelName, uid, AgoraService.Role.PUBLISHER);

        assertNotNull(token, "Generated Agora RTC token should not be null");
        assertTrue(token.startsWith("006"), "Agora standard V006 token should start with version 006");
        assertTrue(token.length() > 20, "Token should be a complete cryptographically signed token string");
    }

    @Test
    @DisplayName("Test channel isolation - distinct channels produce distinct cryptographically signed tokens")
    void testChannelIsolationProducesDistinctTokens() {
        ReflectionTestUtils.setField(agoraService, "appId", "test_app_id_1234567890abcdef");
        ReflectionTestUtils.setField(agoraService, "appCertificate", "test_cert_1234567890abcdef");
        ReflectionTestUtils.setField(agoraService, "tokenExpirationSeconds", 3600);

        String token1 = agoraService.generateRtcToken("channel_user_A", 1001L, AgoraService.Role.PUBLISHER);
        String token2 = agoraService.generateRtcToken("channel_user_B", 1002L, AgoraService.Role.PUBLISHER);

        assertNotEquals(token1, token2, "Different consultation channels must generate completely distinct encryption tokens");
    }

    @Test
    @DisplayName("Test fallback mock token when Agora credentials are not configured in local dev")
    void testMockTokenFallbackInDev() {
        ReflectionTestUtils.setField(agoraService, "appId", "dummy_agora_app_id");
        ReflectionTestUtils.setField(agoraService, "appCertificate", "dummy_agora_certificate");

        String token = agoraService.generateRtcToken("private_room_1", 888L, AgoraService.Role.PUBLISHER);

        assertNotNull(token);
        assertTrue(token.startsWith("mock_agora_rtc_token_private_room_1_888_"));
    }
}
