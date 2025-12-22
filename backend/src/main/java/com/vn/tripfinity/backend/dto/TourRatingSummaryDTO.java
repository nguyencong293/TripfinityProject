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
public class TourRatingSummaryDTO {
    private Integer tourId;
    private BigDecimal avgRating;
    private Integer totalReviews;
    
    // Phân bổ số lượng theo sao
    private Integer count1;
    private Integer count2;
    private Integer count3;
    private Integer count4;
    private Integer count5;
    
    // Trung bình các aspects
    private BigDecimal avgGuideQuality;
    private BigDecimal avgItineraryQuality;
    private BigDecimal avgValueForMoney;
    private BigDecimal avgOrganization;
    private BigDecimal avgSafety;
}
