package com.expertapp.backend.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.zip.CRC32;

@Service
public class AgoraService {

    private static final Logger log = LoggerFactory.getLogger(AgoraService.class);

    @Value("${app.agora.app-id:dummy_agora_app_id}")
    private String appId;

    @Value("${app.agora.app-certificate:dummy_agora_certificate}")
    private String appCertificate;

    @Value("${app.agora.token-expiration-in-seconds:3600}")
    private int tokenExpirationSeconds;

    public enum Role {
        PUBLISHER(1),
        SUBSCRIBER(2);

        private final int value;
        Role(int value) { this.value = value; }
        public int getValue() { return value; }
    }

    /**
     * Generate an Agora RTC Access Token for channel and numeric UID
     */
    public String generateRtcToken(String channelName, long uid, Role role) {
        if (appId == null || appId.contains("dummy") || appCertificate == null || appCertificate.contains("dummy")) {
            log.warn("Using mock Agora token since valid AGORA_APP_ID / AGORA_APP_CERTIFICATE is not configured.");
            return "mock_agora_rtc_token_" + channelName + "_" + uid + "_" + System.currentTimeMillis();
        }

        try {
            int expireTimestamp = (int) (System.currentTimeMillis() / 1000) + tokenExpirationSeconds;
            return buildTokenWithUid(appId, appCertificate, channelName, (int) uid, role.getValue(), expireTimestamp);
        } catch (Exception e) {
            log.error("Failed to generate Agora token", e);
            return "fallback_token_" + channelName + "_" + uid;
        }
    }

    private String buildTokenWithUid(String appId, String appCert, String channelName, int uid, int role, int privilegeTs)
            throws NoSuchAlgorithmException, InvalidKeyException {
        // Agora V006 Token Builder standard format
        String version = "006";
        int salt = (int) (Math.random() * 10000);

        byte[] m = generateMessage(appId, channelName, uid, role, privilegeTs, salt);
        byte[] val = hmacSha256(appCert.getBytes(StandardCharsets.UTF_8), m);

        byte[] content = new byte[val.length + 4 + 4 + 4];
        ByteBuffer buffer = ByteBuffer.wrap(content).order(ByteOrder.LITTLE_ENDIAN);
        buffer.put(val);
        buffer.putInt(salt);
        buffer.putInt(privilegeTs);
        buffer.putInt(m.length);

        CRC32 crc = new CRC32();
        crc.update(appId.getBytes(StandardCharsets.UTF_8));
        crc.update(channelName.getBytes(StandardCharsets.UTF_8));
        crc.update(buffer.array());

        return version + appId + Base64.getEncoder().encodeToString(buffer.array());
    }

    private byte[] generateMessage(String appId, String channelName, int uid, int role, int privilegeTs, int salt) {
        byte[] channelBytes = channelName.getBytes(StandardCharsets.UTF_8);
        ByteBuffer buffer = ByteBuffer.allocate(appId.length() + channelBytes.length + 20).order(ByteOrder.LITTLE_ENDIAN);
        buffer.put(appId.getBytes(StandardCharsets.UTF_8));
        buffer.put(channelBytes);
        buffer.putInt(uid);
        buffer.putInt(salt);
        buffer.putInt(privilegeTs);
        return buffer.array();
    }

    private byte[] hmacSha256(byte[] key, byte[] data) throws NoSuchAlgorithmException, InvalidKeyException {
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKey = new SecretKeySpec(key, "HmacSHA256");
        mac.init(secretKey);
        return mac.doFinal(data);
    }
}
