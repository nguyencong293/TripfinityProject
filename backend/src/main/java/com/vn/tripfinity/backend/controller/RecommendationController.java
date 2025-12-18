package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.recommendation.RecommendationResponse;
import com.vn.tripfinity.backend.service.RecommendationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/recommendations")
@CrossOrigin(origins = "*")
public class RecommendationController {

    private final RecommendationService recommendationService;

    public RecommendationController(RecommendationService recommendationService) {
        this.recommendationService = recommendationService;
    }

    /**
     * API endpoint để lấy gợi ý cho user
     * @param userId ID của user
     * @return ResponseEntity chứa RecommendationResponse
     */
    @GetMapping("/{userId}")
    public Mono<ResponseEntity<RecommendationResponse>> getRecommendations(@PathVariable Long userId) {
        System.out.println("📞 Backend API Request - Getting recommendations for User ID: " + userId);
        
        return recommendationService.getRecommendations(userId)
                .map(response -> {
                    if (response.getSuccess()) {
                        System.out.println("✅ Successfully fetched " + 
                            (response.getData() != null ? response.getData().size() : 0) + 
                            " recommendations for User " + userId);
                    } else {
                        System.out.println("⚠️ No recommendations for User " + userId + ": " + response.getMessage());
                    }
                    return ResponseEntity.ok(response);
                })
                .onErrorResume(error -> {
                    System.err.println("❌ Error in RecommendationController: " + error.getMessage());
                    RecommendationResponse errorResponse = new RecommendationResponse();
                    errorResponse.setSuccess(false);
                    errorResponse.setMessage("Internal server error");
                    errorResponse.setStatus("ERROR");
                    errorResponse.setDescription(error.getMessage());
                    errorResponse.setData(null);
                    return Mono.just(ResponseEntity.internalServerError().body(errorResponse));
                });
    }
}
