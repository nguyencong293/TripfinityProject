package com.vn.tripfinity.backend.dto;

import java.time.LocalDateTime;

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
public class ReviewReplyDTO {
    private Integer replyId;

    @NotBlank(message = "Review type is required")
    private String reviewType; // 'hotel', 'restaurant', etc.

    @NotNull(message = "Review ID is required")
    private Integer reviewId;

    @NotNull(message = "Replier ID is required")
    private Integer replierId;

    private String replierName;
    private String replierAvatar;

    @NotBlank(message = "Reply content is required")
    private String content;

    private Boolean isPublic = true;
    private Integer isProvider = 0; // 0 = user, 1 = provider

    private Integer likeCount = 0;
    private Boolean isLikedByCurrentUser = false;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
