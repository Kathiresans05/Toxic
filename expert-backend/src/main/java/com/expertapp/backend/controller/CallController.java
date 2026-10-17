package com.expertapp.backend.controller;

import com.expertapp.backend.config.UserPrincipal;
import com.expertapp.backend.dto.CallInitiateRequest;
import com.expertapp.backend.dto.CallSessionResponse;
import com.expertapp.backend.service.CallService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/calls")
@Tag(name = "Calling", description = "Agora RTC Call Initiation, Signaling, and Lifecycle Management")
@SecurityRequirement(name = "bearerAuth")
public class CallController {

    private final CallService callService;

    public CallController(CallService callService) {
        this.callService = callService;
    }

    @PostMapping("/initiate")
    @Operation(summary = "Initiate an Agora audio or video call with a Creator")
    public ResponseEntity<CallSessionResponse> initiateCall(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody CallInitiateRequest request) {
        return ResponseEntity.ok(callService.initiateCall(userPrincipal.getId(), request));
    }

    @PostMapping("/{callId}/accept")
    @Operation(summary = "Creator accepts incoming call")
    public ResponseEntity<CallSessionResponse> acceptCall(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable String callId) {
        return ResponseEntity.ok(callService.acceptCall(callId, userPrincipal.getId()));
    }

    @PostMapping("/{callId}/end")
    @Operation(summary = "End consultation call and calculate billing/commission")
    public ResponseEntity<CallSessionResponse> endCall(@PathVariable String callId) {
        return ResponseEntity.ok(callService.endCall(callId));
    }
}
