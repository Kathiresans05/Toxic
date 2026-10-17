package com.expertapp.backend.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "reviews")
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "call_session_id", nullable = false, unique = true)
    private CallSession callSession;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "expert_id", nullable = false)
    private ExpertProfile expert;

    @Column(nullable = false)
    private int rating;

    @Column(columnDefinition = "TEXT")
    private String comment;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt = Instant.now();

    public Review() {}

    public Review(CallSession callSession, User customer, ExpertProfile expert, int rating, String comment) {
        this.callSession = callSession;
        this.customer = customer;
        this.expert = expert;
        this.rating = rating;
        this.comment = comment;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public CallSession getCallSession() { return callSession; }
    public void setCallSession(CallSession callSession) { this.callSession = callSession; }

    public User getCustomer() { return customer; }
    public void setCustomer(User customer) { this.customer = customer; }

    public ExpertProfile getExpert() { return expert; }
    public void setExpert(ExpertProfile expert) { this.expert = expert; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
