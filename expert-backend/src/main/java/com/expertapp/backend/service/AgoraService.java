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
import java.util.Map;
import java.util.TreeMap;
import java.util.zip.CRC32;

@Service
public class AgoraService {

    private static final Logger log = LoggerFactory.getLogger(AgoraService.class);

    @Value("${app.agora.app-id:c9afe369772c48659610c8b6368df693}")
    private String appId;

    @Value("${app.agora.app-certificate:dbc1ada8600e4541b18e42cd8542eddc}")
    private String appCertificate;

    @Value("${app.agora.token-expiration-in-seconds:86400}")
    private int tokenExpirationSeconds;

    public enum Role {
        PUBLISHER(1),
        SUBSCRIBER(2);

        private final int value;
        Role(int value) { this.value = value; }
        public int getValue() { return value; }
    }

    private static class ByteBuf {
        private final ByteBuffer buffer = ByteBuffer.allocate(2048).order(ByteOrder.LITTLE_ENDIAN);

        public ByteBuf putUint16(int v) {
            buffer.putShort((short) (v & 0xFFFF));
            return this;
        }

        public ByteBuf putUint32(long v) {
            buffer.putInt((int) (v & 0xFFFFFFFFL));
            return this;
        }

        public ByteBuf putBytes(byte[] bytes) {
            putUint16(bytes.length);
            buffer.put(bytes);
            return this;
        }

        public ByteBuf putTreeMapUInt32(Map<Short, Integer> map) {
            if (map == null) {
                putUint16(0);
                return this;
            }
            putUint16(map.size());
            for (Map.Entry<Short, Integer> entry : new TreeMap<>(map).entrySet()) {
                putUint16(entry.getKey());
                putUint32(entry.getValue());
            }
            return this;
        }

        public byte[] pack() {
            byte[] out = new byte[buffer.position()];
            System.arraycopy(buffer.array(), 0, out, 0, out.length);
            return out;
        }
    }

    /**
     * Generate an Agora RTC Access Token for channel and numeric UID using official V006 format
     */
    public String generateRtcToken(String channelName, long uid, Role role) {
        if (appId == null || appId.isBlank() || appId.contains("dummy") ||
            appCertificate == null || appCertificate.isBlank() || appCertificate.contains("dummy")) {
            log.warn("Agora App ID or Certificate not configured. Falling back to mock token.");
            return "mock_agora_rtc_token_" + channelName + "_" + uid + "_" + System.currentTimeMillis();
        }

        try {
            int now = (int) (System.currentTimeMillis() / 1000);
            int expireTs = now + (tokenExpirationSeconds > 0 ? tokenExpirationSeconds : 86400);
            int salt = (int) (Math.random() * 0xFFFFFFF);

            Map<Short, Integer> messages = new TreeMap<>();
            messages.put((short) 1, expireTs); // kJoinChannel
            if (role == Role.PUBLISHER) {
                messages.put((short) 2, expireTs); // kPublishAudioStream
                messages.put((short) 3, expireTs); // kPublishVideoStream
                messages.put((short) 4, expireTs); // kPublishDataStream
            }

            ByteBuf mBuf = new ByteBuf();
            mBuf.putUint32(salt);
            mBuf.putUint32(expireTs);
            mBuf.putTreeMapUInt32(messages);
            byte[] m = mBuf.pack();

            byte[] appIdBytes = appId.getBytes(StandardCharsets.UTF_8);
            byte[] channelBytes = channelName.getBytes(StandardCharsets.UTF_8);
            byte[] uidBytes = (uid == 0 ? "" : String.valueOf(uid)).getBytes(StandardCharsets.UTF_8);

            byte[] toSign = new byte[appIdBytes.length + channelBytes.length + uidBytes.length + m.length];
            int pos = 0;
            System.arraycopy(appIdBytes, 0, toSign, pos, appIdBytes.length); pos += appIdBytes.length;
            System.arraycopy(channelBytes, 0, toSign, pos, channelBytes.length); pos += channelBytes.length;
            System.arraycopy(uidBytes, 0, toSign, pos, uidBytes.length); pos += uidBytes.length;
            System.arraycopy(m, 0, toSign, pos, m.length);

            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(appCertificate.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] signature = mac.doFinal(toSign);

            CRC32 crcChannel = new CRC32();
            crcChannel.update(channelBytes);
            long crc_channel = crcChannel.getValue() & 0xFFFFFFFFL;

            CRC32 crcUid = new CRC32();
            crcUid.update(uidBytes);
            long crc_uid = crcUid.getValue() & 0xFFFFFFFFL;

            ByteBuf contentBuf = new ByteBuf();
            contentBuf.putBytes(signature);
            contentBuf.putUint32(crc_channel);
            contentBuf.putUint32(crc_uid);
            contentBuf.putBytes(m);
            byte[] content = contentBuf.pack();

            return "006" + appId + Base64.getEncoder().encodeToString(content);
        } catch (Exception e) {
            log.error("Failed to generate Agora token for channel: " + channelName, e);
            return "";
        }
    }
}
