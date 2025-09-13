package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties(ignoreUnknown = true)
public class RestaurantReviewDTO {

    private Integer reviewId;

    @JsonAlias({ "restaurant_id" })
    private Integer restaurantId; // will be set from path

    @NotNull(message = "userId không được để trống")
    @JsonAlias({ "user_id" })
    private Integer userId;

    @NotNull
    @Min(value = 1, message = "rating phải từ 1..5")
    @Max(value = 5, message = "rating phải từ 1..5")
    private Integer rating;

    @Size(max = 255)
    private String title;

    @NotBlank
    private String content;

    @JsonAlias({ "image_urls" })
    private List<@Size(max = 1024) String> imageUrls;

    private Integer likesCount;
    private Integer replyCount;

    @JsonAlias({ "review_status" })
    private String reviewStatus; // approved | rejected

    @Valid
    private RestaurantReviewAspectsDTO aspects;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RestaurantReviewAspectsDTO {
        @NotNull
        @Min(1)
        @Max(5)
        private Integer quality;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer service;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer price;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer location;
        @NotNull
        @Min(1)
        @Max(5)
        private Integer ambience;
    }
}
