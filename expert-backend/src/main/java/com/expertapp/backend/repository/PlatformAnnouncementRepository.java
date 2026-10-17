package com.expertapp.backend.repository;

import com.expertapp.backend.entity.PlatformAnnouncement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PlatformAnnouncementRepository extends JpaRepository<PlatformAnnouncement, UUID> {
    List<PlatformAnnouncement> findByActiveTrueOrderByCreatedAtDesc();
    Page<PlatformAnnouncement> findAllByOrderByCreatedAtDesc(Pageable pageable);
}
