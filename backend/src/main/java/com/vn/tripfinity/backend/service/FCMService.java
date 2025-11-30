package com.vn.tripfinity.backend.service;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class FCMService {

    /**
     * Gửi push notification đến một thiết bị cụ thể
     * 
     * @param fcmToken FCM token của thiết bị
     * @param title Tiêu đề notification
     * @param body Nội dung notification
     * @param data Data payload (optional)
     */
    @Async
    public void sendNotificationToDevice(String fcmToken, String title, String body, 
                                         java.util.Map<String, String> data) {
        try {
            if (fcmToken == null || fcmToken.isEmpty()) {
                log.warn("FCM token is empty, skip sending notification");
                return;
            }

            // QUAN TRỌNG: Chỉ gửi DATA-ONLY message (không dùng notification)
            // Lý do: Android có bug khi gửi cả notification + data trong background
            // Nếu gửi cả 2, notification tự động hiển thị nhưng data bị bỏ qua
            
            // Tạo data payload bắt buộc phải có
            java.util.Map<String, String> dataPayload = new java.util.HashMap<>();
            dataPayload.put("title", title);
            dataPayload.put("body", body);
            
            // Merge custom data nếu có
            if (data != null && !data.isEmpty()) {
                dataPayload.putAll(data);
            }

            // Build message CHỈ với data payload
            Message message = Message.builder()
                    .setToken(fcmToken)
                    .putAllData(dataPayload)
                    // KHÔNG set notification - Android sẽ tự tạo từ data
                    .build();

            // Send message
            String response = FirebaseMessaging.getInstance().send(message);
            log.info("✅ Successfully sent FCM notification: {}", response);

        } catch (Exception e) {
            log.error("❌ Error sending FCM notification: {}", e.getMessage(), e);
        }
    }

    /**
     * Gửi notification đến nhiều thiết bị
     * 
     * @param fcmTokens Danh sách FCM tokens
     * @param title Tiêu đề notification
     * @param body Nội dung notification
     */
    @Async
    public void sendNotificationToMultipleDevices(java.util.List<String> fcmTokens, 
                                                   String title, String body) {
        if (fcmTokens == null || fcmTokens.isEmpty()) {
            log.warn("FCM tokens list is empty, skip sending notification");
            return;
        }

        for (String token : fcmTokens) {
            sendNotificationToDevice(token, title, body, null);
        }
    }
}
