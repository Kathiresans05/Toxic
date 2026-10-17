package com.expertapp.backend.service;

import com.expertapp.backend.entity.PaymentStatus;
import com.expertapp.backend.entity.Role;
import com.expertapp.backend.entity.Transaction;
import com.expertapp.backend.entity.User;
import com.expertapp.backend.repository.TransactionRepository;
import com.expertapp.backend.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PaymentServiceTest {

    @Mock
    private TransactionRepository transactionRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private PaymentService paymentService;

    @Test
    void testCreateOrder() {
        UUID userId = UUID.randomUUID();
        User user = new User("user@test.com", "+919999999999", "pwd", "Test User", Role.ROLE_CUSTOMER);
        user.setId(userId);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(transactionRepository.save(any(Transaction.class))).thenAnswer(i -> i.getArgument(0));

        Map<String, Object> order = paymentService.createOrder(userId, BigDecimal.valueOf(500.00), "INR");

        assertNotNull(order);
        assertTrue(order.containsKey("orderId"));
        assertEquals(BigDecimal.valueOf(500.00), order.get("amount"));
        verify(transactionRepository, times(1)).save(any(Transaction.class));
    }
}
