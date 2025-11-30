package com.vn.tripfinity.backend.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/fcm")
@RequiredArgsConstructor
public class FCMController {

    private final UserRepository userRepository;

    /**
     * Update FCM token cho user
     */
    @PutMapping("/token")
    public ResponseEntity<Map<String, String>> updateFCMToken(@RequestBody UpdateFCMTokenRequest request) {
        log.info("📱 Received FCM token update request for userId: {}", request.getUserId());
        log.info("🔑 Token preview: {}...", request.getFcmToken().substring(0, 20));
        
        try {
            User user = userRepository.findById(request.getUserId())
                    .orElseThrow(() -> new RuntimeException("User not found"));

            user.setFcmToken(request.getFcmToken());
            userRepository.save(user);
            
            log.info("✅ FCM token updated successfully for user: {}", user.getEmail());

            Map<String, String> response = new HashMap<>();
            response.put("message", "FCM token updated successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("❌ Failed to update FCM token: {}", e.getMessage(), e);
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * Xóa FCM token (khi user logout)
     */
    @DeleteMapping("/token/{userId}")
    public ResponseEntity<Map<String, String>> deleteFCMToken(@PathVariable Integer userId) {
        try {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            user.setFcmToken(null);
            userRepository.save(user);

            Map<String, String> response = new HashMap<>();
            response.put("message", "FCM token deleted successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
}

@Data
class UpdateFCMTokenRequest {
    private Integer userId;
    private String fcmToken;
}
