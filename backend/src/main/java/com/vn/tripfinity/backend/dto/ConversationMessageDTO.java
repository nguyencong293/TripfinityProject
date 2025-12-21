package com.vn.tripfinity.backend.dto;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonAlias;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConversationMessageDTO {

    @JsonAlias({"message_id"})
    private Integer messageId;

    @NotNull(message = "Conversation ID là bắt buộc")
    @JsonAlias({"conversation_id"})
    private Integer conversationId;

    @NotBlank(message = "Sender type là bắt buộc")
    @JsonAlias({"sender_type"})
    private String senderType; // "user" hoặc "provider"

    @NotNull(message = "Sender ID là bắt buộc")
    @JsonAlias({"sender_id"})
    private Integer senderId;

    @NotBlank(message = "Nội dung tin nhắn là bắt buộc")
    @JsonAlias({"content"})
    private String content;

    @JsonAlias({"message_type"})
    private String messageType; // "text", "image", "file", "system"

    @JsonAlias({"image_url"})
    private String imageUrl;

    @JsonAlias({"is_read"})
    private Boolean isRead;

    @JsonAlias({"read_at"})
    private LocalDateTime readAt;

    @JsonAlias({"created_at"})
    private LocalDateTime createdAt;

    // Thông tin bổ sung cho hiển thị
    @JsonAlias({"sender_name"})
    private String senderName;

    @JsonAlias({"sender_avatar"})
    private String senderAvatar;
}
