package com.expertapp.backend.repository;

import com.expertapp.backend.entity.ExpertProfile;
import com.expertapp.backend.entity.KycStatus;
import com.expertapp.backend.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ExpertProfileRepository extends JpaRepository<ExpertProfile, UUID> {
    Optional<ExpertProfile> findByUser(User user);
    Optional<ExpertProfile> findByUserId(UUID userId);
    Page<ExpertProfile> findByApprovedTrueAndAvailableTrue(Pageable pageable);
    Page<ExpertProfile> findByCategoryIdAndApprovedTrueAndAvailableTrue(UUID categoryId, Pageable pageable);
    Page<ExpertProfile> findByKycStatus(KycStatus kycStatus, Pageable pageable);
    long countByApprovedTrue();
    long countByKycStatus(KycStatus kycStatus);
}
