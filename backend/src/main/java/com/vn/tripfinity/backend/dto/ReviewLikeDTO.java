package com.vn.tripfinity.backend.dto;

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
public class ReviewLikeDTO {
    private Integer likeId;

    @NotNull(message = "User ID is required")
    private Integer userId;

    @NotBlank(message = "Review type is required")
    private String reviewType; // 'hotel', 'restaurant', etc.

    @NotNull(message = "Review ID is required")
    private Integer reviewId;
}
