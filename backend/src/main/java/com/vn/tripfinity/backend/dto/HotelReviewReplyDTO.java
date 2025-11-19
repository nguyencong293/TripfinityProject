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
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelReviewReplyDTO {
    private Integer replyId;

    private Integer reviewId;

    @NotNull(message = "replierId không được để trống")
    @JsonAlias({ "replier_id" })
    private Integer replierId;

    @NotBlank
    private String content;

    @JsonAlias({ "is_public" })
    private Boolean isPublic;

    @JsonAlias({ "is_provider" })
    private Integer isProvider; // 0 = user, 1 = provider/business account

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
