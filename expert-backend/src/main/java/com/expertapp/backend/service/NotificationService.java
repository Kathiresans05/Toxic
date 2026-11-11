package com.expertapp.backend.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);

    public void sendPushNotification(String token, String title, String body, Map<String, String> data) {
        if (token == null || token.isBlank()) {
            log.debug("Target notification token is empty, skipping alert: {}", title);
            return;
        }

        // Direct in-app & WebSocket signaling handles real-time delivery
        log.info("[Notification] To: {}, Title: '{}', Body: '{}', Data: {}", token, title, body, data);
    }
}
