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
        java.net.URI uri = session.getUri();
        if (uri != null && uri.getQuery() != null) {
            for (String param : uri.getQuery().split("&")) {
                String[] pair = param.split("=");
                if (pair.length == 2 && "userId".equalsIgnoreCase(pair[0])) {
                    String userId = pair[1];
                    userSessions.put(userId, session);
                    session.getAttributes().put("userId", userId);
                    log.info("User {} registered via WebSocket URI ({})", userId, session.getId());
                }
            }
        }
        log.info("WebSocket connected: {}", session.getId());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        try {
            Map<String, Object> payload = objectMapper.readValue(message.getPayload(), Map.class);
            String event = (String) payload.get("event");

            if ("PING".equalsIgnoreCase(event)) {
                session.sendMessage(new TextMessage("{\"event\":\"PONG\"}"));
                return;
            }

            if ("REGISTER".equalsIgnoreCase(event)) {
                String userId = (String) payload.get("userId");
                if (userId != null && !userId.isBlank()) {
                    userSessions.put(userId, session);
                    session.getAttributes().put("userId", userId);
                    log.info("User {} registered with WebSocket session {}", userId, session.getId());
                }
                if (payload.containsKey("expertId")) {
                    String expertId = (String) payload.get("expertId");
                    if (expertId != null && !expertId.isBlank()) {
                        userSessions.put(expertId, session);
                        log.info("Expert alias {} mapped to WebSocket session {}", expertId, session.getId());
                    }
                }
                if (payload.containsKey("aliases") && payload.get("aliases") instanceof java.util.List<?> list) {
                    for (Object alias : list) {
                        if (alias != null && !alias.toString().isBlank()) {
                            userSessions.put(alias.toString(), session);
                            log.info("Alias {} mapped to WebSocket session {}", alias, session.getId());
                        }
                    }
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
        if (userId == null || userId.isBlank()) return;
        WebSocketSession targetSession = userSessions.get(userId);
        if (targetSession != null && targetSession.isOpen()) {
            try {
                String json = objectMapper.writeValueAsString(messageObject);
                targetSession.sendMessage(new TextMessage(json));
                log.info("Sent WS message to target {}: {}", userId, json);
            } catch (Exception ex) {
                log.error("Failed to send message to user {}", userId, ex);
            }
        } else {
            log.warn("WebSocket session for target {} not found or closed. Active registered users: {}", userId, userSessions.keySet());
        }
    }

    public void broadcast(Object messageObject) {
        try {
            String json = objectMapper.writeValueAsString(messageObject);
            TextMessage textMessage = new TextMessage(json);
            for (WebSocketSession session : userSessions.values()) {
                if (session != null && session.isOpen()) {
                    try {
                        session.sendMessage(textMessage);
                    } catch (Exception ignored) {}
                }
            }
        } catch (Exception ex) {
            log.error("Failed to broadcast WebSocket message", ex);
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        userSessions.entrySet().removeIf(entry -> entry.getValue() == null || entry.getValue().getId().equals(session.getId()));
        log.info("WebSocket session {} disconnected", session.getId());
    }
}
