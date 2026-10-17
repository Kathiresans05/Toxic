package com.expertapp.backend.dto;

import com.expertapp.backend.entity.Role;
import jakarta.validation.constraints.NotBlank;

public class AuthRequest {

    private String email;
    private String phoneNumber;

    @NotBlank
    private String password;

    private String fullName;
    private Role role = Role.ROLE_CUSTOMER;

    public AuthRequest() {}

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }
}
