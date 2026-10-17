package com.expertapp.backend.repository;

import com.expertapp.backend.entity.KycStatus;
import com.expertapp.backend.entity.KycVerification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface KycVerificationRepository extends JpaRepository<KycVerification, UUID> {
    Optional<KycVerification> findTopByExpertIdOrderByCreatedAtDesc(UUID expertId);
    Page<KycVerification> findByStatus(KycStatus status, Pageable pageable);
    long countByStatus(KycStatus status);
}
