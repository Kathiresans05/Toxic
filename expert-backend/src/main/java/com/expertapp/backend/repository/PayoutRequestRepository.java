package com.expertapp.backend.repository;

import com.expertapp.backend.entity.PayoutRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface PayoutRequestRepository extends JpaRepository<PayoutRequest, UUID> {
    Page<PayoutRequest> findByExpertId(UUID expertId, Pageable pageable);
    Page<PayoutRequest> findByStatus(String status, Pageable pageable);
    long countByStatus(String status);
}
