package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.*;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelRatingSummaryDTO {

    private Integer hotelId;

    @JsonAlias("avg_rating")
    private BigDecimal avgRating;

    @JsonAlias("total_reviews")
    private Integer totalReviews;

    @JsonAlias("count_1")
    private Integer count1;

    @JsonAlias("count_2")
    private Integer count2;

    @JsonAlias("count_3")
    private Integer count3;

    @JsonAlias("count_4")
    private Integer count4;

    @JsonAlias("count_5")
    private Integer count5;

    @JsonAlias("avg_cleanliness")
    private BigDecimal avgCleanliness;

    @JsonAlias("avg_service")
    private BigDecimal avgService;

    @JsonAlias("avg_value_for_money")
    private BigDecimal avgValueForMoney;

    @JsonAlias("avg_location")
    private BigDecimal avgLocation;

    @JsonAlias("avg_facilities")
    private BigDecimal avgFacilities;
}