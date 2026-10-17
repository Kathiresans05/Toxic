package com.expertapp.backend.repository;

import com.expertapp.backend.entity.Role;
import com.expertapp.backend.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    Optional<User> findByPhoneNumber(String phoneNumber);
    boolean existsByEmail(String email);
    boolean existsByPhoneNumber(String phoneNumber);
    Page<User> findByRole(Role role, Pageable pageable);
    long countByRole(Role role);

    @org.springframework.data.jpa.repository.Query("SELECT u FROM User u WHERE LOWER(u.fullName) LIKE LOWER(CONCAT('%', :search, '%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%', :search, '%')) OR u.phoneNumber LIKE CONCAT('%', :search, '%')")
    Page<User> searchUsers(@org.springframework.data.repository.query.Param("search") String search, Pageable pageable);
}
