package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO để tạo conversation mới hoặc lấy conversation đã tồn tại
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateConversationRequest {

    @NotNull(message = "User ID là bắt buộc")
    @JsonAlias({"user_id"})
    private Integer userId;

    @NotNull(message = "Provider ID là bắt buộc")
    @JsonAlias({"provider_id"})
    private Integer providerId;

    @JsonAlias({"subject"})
    private String subject;
}
