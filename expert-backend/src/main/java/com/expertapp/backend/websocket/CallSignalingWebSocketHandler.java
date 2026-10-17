package com.expertapp.backend.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class CallSignalingWebSocketHandler extends TextWebSocketHandler {

    private static final Logger log = LoggerFactory.getLogger(CallSignalingWebSocketHandler.class);
    private final ObjectMapper objectMapper = new ObjectMapper();

    // Map userId -> WebSocketSession
    private final Map<String, WebSocketSession> userSessions = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        log.info("WebSocket connected: {}", session.getId());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        try {
            Map<String, Object> payload = objectMapper.readValue(message.getPayload(), Map.class);
            String event = (String) payload.get("event");

            if ("REGISTER".equalsIgnoreCase(event)) {
                String userId = (String) payload.get("userId");
                if (userId != null) {
                    userSessions.put(userId, session);
                    session.getAttributes().put("userId", userId);
                    log.info("User {} registered with WebSocket session {}", userId, session.getId());
                }
            } else if ("CALL_INVITE".equalsIgnoreCase(event) || "CALL_ACCEPT".equalsIgnoreCase(event) ||
                       "CALL_REJECT".equalsIgnoreCase(event) || "CALL_END".equalsIgnoreCase(event)) {
                String targetUserId = (String) payload.get("targetUserId");
                if (targetUserId != null) {
                    sendToUser(targetUserId, payload);
                }
            }
        } catch (Exception ex) {
            log.error("Error processing websocket message", ex);
        }
    }

    public void sendToUser(String userId, Object messageObject) {
        WebSocketSession targetSession = userSessions.get(userId);
        if (targetSession != null && targetSession.isOpen()) {
            try {
                String json = objectMapper.writeValueAsString(messageObject);
                targetSession.sendMessage(new TextMessage(json));
            } catch (Exception ex) {
                log.error("Failed to send message to user {}", userId, ex);
            }
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        String userId = (String) session.getAttributes().get("userId");
        if (userId != null) {
            userSessions.remove(userId);
            log.info("User {} disconnected from WebSocket", userId);
        }
    }
}
