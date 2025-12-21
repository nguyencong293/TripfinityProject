package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO để gửi tin nhắn mới
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SendMessageRequest {

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
    private String messageType; // "text", "image", "file" - default "text"

    @JsonAlias({"image_url"})
    private String imageUrl; // URL Cloudinary nếu gửi hình ảnh
}
