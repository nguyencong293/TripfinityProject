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
public class TourReviewDTO {

    private Integer reviewId;

    @JsonAlias({ "tour_id" })
    private Integer tourId;

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

    // approved | rejected
    @JsonAlias({ "review_status" })
    private String reviewStatus;

    @Valid
    private TourReviewAspectsDTO aspects;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class TourReviewAspectsDTO {
        @JsonAlias({ "guide_quality" })
        @NotNull
        @Min(1)
        @Max(5)
        private Integer guideQuality;

        @JsonAlias({ "itinerary_quality" })
        @NotNull
        @Min(1)
        @Max(5)
        private Integer itineraryQuality;

        @JsonAlias({ "value_for_money" })
        @NotNull
        @Min(1)
        @Max(5)
        private Integer valueForMoney;

        @JsonAlias({ "organization" })
        @NotNull
        @Min(1)
        @Max(5)
        private Integer organization;

        @JsonAlias({ "safety" })
        @NotNull
        @Min(1)
        @Max(5)
        private Integer safety;
    }
}
