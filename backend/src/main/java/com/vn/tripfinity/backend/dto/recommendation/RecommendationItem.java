package com.vn.tripfinity.backend.dto.recommendation;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecommendationItem {
    @JsonProperty("item_id")
    private Integer itemId;
    
    private String title;
    
    @JsonProperty("item_type")
    private String itemType;
    
    @JsonProperty("price_fmt")
    private String priceFmt;
    
    @JsonProperty("dist_km")
    private Double distKm;
    
    private Double score;
}
