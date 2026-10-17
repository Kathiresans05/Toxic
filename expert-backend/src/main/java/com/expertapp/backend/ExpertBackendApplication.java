package com.expertapp.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

import com.expertapp.backend.entity.Role;
import com.expertapp.backend.entity.User;
import com.expertapp.backend.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
@EnableCaching
@EnableScheduling
@EntityScan(basePackages = "com.expertapp.backend.entity")
@EnableJpaRepositories(basePackages = "com.expertapp.backend.repository")
public class ExpertBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(ExpertBackendApplication.class, args);
    }

    @Bean
    public CommandLineRunner initDefaultAdmin(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            userRepository.findByEmail("admin@expertapp.com").ifPresentOrElse(
                    user -> {
                        user.setPasswordHash(passwordEncoder.encode("Admin@123"));
                        user.setRole(Role.ROLE_ADMIN);
                        user.setActive(true);
                        user.setVerified(true);
                        userRepository.save(user);
                    },
                    () -> {
                        User admin = new User(
                                "admin@expertapp.com",
                                "+919876543210",
                                passwordEncoder.encode("Admin@123"),
                                "System Administrator",
                                Role.ROLE_ADMIN
                        );
                        admin.setActive(true);
                        admin.setVerified(true);
                        userRepository.save(admin);
                    }
            );
        };
    }
}
