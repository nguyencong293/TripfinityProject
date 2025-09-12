package com.vn.tripfinity.backend.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelReviewDTO {

    private Integer reviewId;

    // Optional in body. Will be filled from path variable in controller.
    private Integer hotelId;

    @NotNull(message = "userId không được để trống")
    private Integer userId;

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

    // approved | rejected
    private String reviewStatus;

    @Valid
    private HotelReviewAspectsDTO aspects;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class HotelReviewAspectsDTO {
        @NotNull
        @Min(1)
        @Max(5)
        private Integer cleanliness;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer service;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer valueForMoney;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer location;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer facilities;
    }
}
