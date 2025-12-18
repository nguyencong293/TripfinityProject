package com.vn.tripfinity.backend.dto.recommendation;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecommendationResponse {
    private Boolean success;
    private String message;
    private String status;
    private String description;
    private List<RecommendationItem> data;
}
