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
public class AttractionRatingSummaryDTO {
    private Integer attractionId;
    private BigDecimal avgRating;
    private Integer totalReviews;
    
    // Phân bổ số lượng theo sao
    private Integer count1;
    private Integer count2;
    private Integer count3;
    private Integer count4;
    private Integer count5;
    
    // Trung bình các aspects (attraction uses different aspects than hotel)
    private BigDecimal avgExperience;      // maps to beauty
    private BigDecimal avgValueForMoney;   // maps to price
    private BigDecimal avgAccessibility;   // maps to accessibility
    private BigDecimal avgFacilities;      // maps to facilities
    private BigDecimal avgStaff;           // maps to culture
}
