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
public class HotelRatingSummaryDTO {
    private Integer hotelId;
    private BigDecimal avgRating;
    private Integer totalReviews;
    
    // Phân bổ số lượng theo sao
    private Integer count1;
    private Integer count2;
    private Integer count3;
    private Integer count4;
    private Integer count5;
    
    // Trung bình các aspects
    private BigDecimal avgCleanliness;
    private BigDecimal avgService;
    private BigDecimal avgValueForMoney;
    private BigDecimal avgLocation;
    private BigDecimal avgFacilities;
}
