package com.expertapp.backend.service;

import com.expertapp.backend.config.JwtTokenProvider;
import com.expertapp.backend.dto.AuthRequest;
import com.expertapp.backend.dto.AuthResponse;
import com.expertapp.backend.entity.ExpertProfile;
import com.expertapp.backend.entity.Role;
import com.expertapp.backend.entity.User;
import com.expertapp.backend.repository.ExpertProfileRepository;
import com.expertapp.backend.repository.UserRepository;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final ExpertProfileRepository expertProfileRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;

    public AuthService(UserRepository userRepository,
                       ExpertProfileRepository expertProfileRepository,
                       PasswordEncoder passwordEncoder,
                       JwtTokenProvider tokenProvider) {
        this.userRepository = userRepository;
        this.expertProfileRepository = expertProfileRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
    }

    @Transactional
    public AuthResponse register(AuthRequest request) {
        if (request.getEmail() != null && userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already in use");
        }
        if (request.getPhoneNumber() != null && userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
            throw new IllegalArgumentException("Phone number already in use");
        }

        Role role = request.getRole() != null ? request.getRole() : Role.ROLE_CUSTOMER;
        User user = new User(
                request.getEmail(),
                request.getPhoneNumber(),
                passwordEncoder.encode(request.getPassword()),
                request.getFullName() != null ? request.getFullName() : "User",
                role
        );
        User savedUser = userRepository.save(user);

        // If creator, automatically initialize an expert profile
        if (role == Role.ROLE_CREATOR) {
            ExpertProfile profile = new ExpertProfile();
            profile.setUser(savedUser);
            profile.setHeadline("Creator & Consultant");
            profile.setAudioRatePerMin(BigDecimal.valueOf(10.00));
            profile.setVideoRatePerMin(BigDecimal.valueOf(20.00));
            profile.setAgoraUid(Math.abs(savedUser.getId().getMostSignificantBits() % 10000000L));
            expertProfileRepository.save(profile);
        }

        String accessToken = tokenProvider.generateToken(savedUser.getId(), savedUser.getEmail(), savedUser.getRole().name());
        String refreshToken = tokenProvider.generateRefreshToken(savedUser.getId());

        return new AuthResponse(accessToken, refreshToken, savedUser.getId(), savedUser.getEmail(), savedUser.getFullName(), savedUser.getRole().name());
    }

    @Transactional(readOnly = true)
    public AuthResponse login(AuthRequest request) {
        String identifier = request.getEmail() != null ? request.getEmail() : request.getPhoneNumber();
        User user = userRepository.findByEmail(identifier)
                .or(() -> userRepository.findByPhoneNumber(identifier))
                .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BadCredentialsException("Invalid credentials");
        }

        String accessToken = tokenProvider.generateToken(user.getId(), user.getEmail(), user.getRole().name());
        String refreshToken = tokenProvider.generateRefreshToken(user.getId());

        return new AuthResponse(accessToken, refreshToken, user.getId(), user.getEmail(), user.getFullName(), user.getRole().name());
    }
}
