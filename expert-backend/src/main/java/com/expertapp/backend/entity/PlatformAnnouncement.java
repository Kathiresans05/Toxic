package com.expertapp.backend.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "platform_announcements")
public class PlatformAnnouncement {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    @Column(name = "target_audience", nullable = false, length = 30)
    private String targetAudience = "ALL"; // ALL, CUSTOMERS, CREATORS

    @Column(nullable = false, length = 20)
    private String priority = "NORMAL"; // NORMAL, URGENT, INFO

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public PlatformAnnouncement() {}

    public PlatformAnnouncement(String title, String message, String targetAudience, String priority) {
        this.title = title;
        this.message = message;
        this.targetAudience = targetAudience != null ? targetAudience : "ALL";
        this.priority = priority != null ? priority : "NORMAL";
        this.active = true;
        this.createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getTargetAudience() { return targetAudience; }
    public void setTargetAudience(String targetAudience) { this.targetAudience = targetAudience; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
