package com.expertapp.backend.repository;

import com.expertapp.backend.entity.CallSession;
import com.expertapp.backend.entity.CallStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CallSessionRepository extends JpaRepository<CallSession, UUID> {
    Optional<CallSession> findByCallId(String callId);
    Page<CallSession> findByCustomerId(UUID customerId, Pageable pageable);
    Page<CallSession> findByExpertId(UUID expertId, Pageable pageable);
    Page<CallSession> findByStatus(CallStatus status, Pageable pageable);
    long countByStatus(CallStatus status);

    @Query("SELECT COALESCE(SUM(c.totalAmount), 0) FROM CallSession c WHERE c.status = 'ENDED'")
    BigDecimal calculateTotalGrossVolume();

    @Query("SELECT COALESCE(SUM(c.commissionAmount), 0) FROM CallSession c WHERE c.status = 'ENDED'")
    BigDecimal calculateTotalPlatformRevenue();
}
