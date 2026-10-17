package com.expertapp.backend.service;

import com.expertapp.backend.config.JwtTokenProvider;
import com.expertapp.backend.dto.AuthRequest;
import com.expertapp.backend.dto.AuthResponse;
import com.expertapp.backend.entity.Role;
import com.expertapp.backend.entity.User;
import com.expertapp.backend.repository.ExpertProfileRepository;
import com.expertapp.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private ExpertProfileRepository expertProfileRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtTokenProvider tokenProvider;

    @InjectMocks
    private AuthService authService;

    private User sampleUser;

    @BeforeEach
    void setUp() {
        sampleUser = new User("test@example.com", "+919876543210", "hashed_pwd", "John Doe", Role.ROLE_CUSTOMER);
        sampleUser.setId(UUID.randomUUID());
    }

    @Test
    void testRegisterCustomerSuccess() {
        AuthRequest req = new AuthRequest();
        req.setEmail("test@example.com");
        req.setPassword("Password123!");
        req.setFullName("John Doe");
        req.setRole(Role.ROLE_CUSTOMER);

        when(userRepository.existsByEmail("test@example.com")).thenReturn(false);
        when(passwordEncoder.encode("Password123!")).thenReturn("hashed_pwd");
        when(userRepository.save(any(User.class))).thenReturn(sampleUser);
        when(tokenProvider.generateToken(any(), any(), any())).thenReturn("mock_access_token");
        when(tokenProvider.generateRefreshToken(any())).thenReturn("mock_refresh_token");

        AuthResponse resp = authService.register(req);

        assertNotNull(resp);
        assertEquals("mock_access_token", resp.getAccessToken());
        assertEquals("test@example.com", resp.getEmail());
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    void testLoginInvalidPasswordThrows() {
        AuthRequest req = new AuthRequest();
        req.setEmail("test@example.com");
        req.setPassword("WrongPassword");

        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(sampleUser));
        when(passwordEncoder.matches("WrongPassword", "hashed_pwd")).thenReturn(false);

        assertThrows(BadCredentialsException.class, () -> authService.login(req));
    }
}
