package com.vn.tripfinity.backend.dto;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonAlias;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConversationDTO {

    @JsonAlias({"conversation_id"})
    private Integer conversationId;

    @NotNull(message = "User ID là bắt buộc")
    @JsonAlias({"user_id"})
    private Integer userId;

    @NotNull(message = "Provider ID là bắt buộc")
    @JsonAlias({"provider_id"})
    private Integer providerId;

    @JsonAlias({"subject"})
    private String subject;

    @JsonAlias({"conversation_status"})
    private String conversationStatus;

    @JsonAlias({"last_message_at"})
    private LocalDateTime lastMessageAt;

    @JsonAlias({"last_message_content"})
    private String lastMessageContent;

    @JsonAlias({"user_unread_count"})
    private Integer userUnreadCount;

    @JsonAlias({"provider_unread_count"})
    private Integer providerUnreadCount;

    @JsonAlias({"created_at"})
    private LocalDateTime createdAt;

    @JsonAlias({"updated_at"})
    private LocalDateTime updatedAt;

    // Thông tin bổ sung cho hiển thị
    @JsonAlias({"user_name"})
    private String userName;

    @JsonAlias({"user_avatar"})
    private String userAvatar;

    @JsonAlias({"provider_name"})
    private String providerName;

    @JsonAlias({"provider_logo"})
    private String providerLogo;

    @JsonAlias({"provider_type"})
    private String providerType;
}
