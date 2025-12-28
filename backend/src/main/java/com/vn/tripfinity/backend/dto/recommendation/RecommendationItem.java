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
    
    @JsonProperty("final_score")
    private Double score;
    
    // ⚡ ENHANCED: Thêm fields để Flutter không cần gọi thêm search API
    @JsonProperty("thumbnail_url")
    private String thumbnailUrl;
    
    @JsonProperty("rating_avg")
    private Double ratingAvg;
    
    private String location;
    
    private String reason;
    
    // Hotel-specific field (cấp sao khách sạn)
    @JsonProperty("hotel_star_class")
    private Integer hotelStarClass;
}
