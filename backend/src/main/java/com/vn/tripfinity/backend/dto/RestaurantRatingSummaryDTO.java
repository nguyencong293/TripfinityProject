package com.vn.tripfinity.backend.dto;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RestaurantRatingSummaryDTO {
    private Integer restaurantId;
    private BigDecimal avgRating;
    private Integer totalReviews;
    
    // Phân bổ số lượng theo sao
    private Integer count1;
    private Integer count2;
    private Integer count3;
    private Integer count4;
    private Integer count5;
    
    // Trung bình các aspects (restaurant có 5 aspects khác hotel)
    private BigDecimal avgQuality;
    private BigDecimal avgService;
    private BigDecimal avgPrice;
    private BigDecimal avgLocation;
    private BigDecimal avgAmbience;
}
