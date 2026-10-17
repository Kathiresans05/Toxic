package com.expertapp.backend.repository;

import com.expertapp.backend.entity.SafetyReport;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface SafetyReportRepository extends JpaRepository<SafetyReport, UUID> {
    Page<SafetyReport> findByStatus(String status, Pageable pageable);
    long countByStatus(String status);
}
