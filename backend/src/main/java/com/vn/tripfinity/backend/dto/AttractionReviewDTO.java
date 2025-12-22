package com.vn.tripfinity.backend.dto;

import java.time.LocalDateTime;
import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttractionReviewDTO {

    private Integer reviewId;

    private Integer attractionId;

    @NotNull(message = "userId không được để trống")
    private Integer userId;

    private String userName; // Tên người dùng để hiển thị

    @NotNull
    @Min(value = 1, message = "rating phải từ 1..5")
    @Max(value = 5, message = "rating phải từ 1..5")
    private Integer rating;

    @Size(max = 255)
    private String title;

    @NotBlank
    private String content;

    private List<@Size(max = 1024) String> imageUrls;

    private Integer likesCount;
    private Integer replyCount;

    private String reviewStatus;

    @Valid
    private AttractionReviewAspectsDTO aspects;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AttractionReviewAspectsDTO {
        @NotNull
        @Min(1)
        @Max(5)
        private Integer beauty;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer culture;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer accessibility;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer price;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer facilities;
    }
}
