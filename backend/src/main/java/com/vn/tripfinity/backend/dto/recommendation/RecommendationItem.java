package com.vn.tripfinity.backend.dto.recommendation;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecommendationItem {
    private String title;
    private String itemType;
    private String priceFmt;
    private Double distKm;
    private Double score;
}
