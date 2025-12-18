package com.vn.tripfinity.backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import com.vn.tripfinity.backend.dto.recommendation.RecommendationResponse;

import reactor.core.publisher.Mono;

@Service
public class RecommendationService {

    private final WebClient webClient;

    public RecommendationService(
            @Value("${recommendation.api.url:http://localhost:5000}") String recommendationApiUrl) {
        this.webClient = WebClient.builder()
                .baseUrl(recommendationApiUrl)
                .build();
    }

    /**
     * Lấy gợi ý từ AI model cho user
     * @param userId ID của user
     * @return RecommendationResponse chứa danh sách items được gợi ý
     */
    public Mono<RecommendationResponse> getRecommendations(Long userId) {
        return webClient
                .get()
                .uri("/api/recommendations/{userId}", userId)
                .retrieve()
                .bodyToMono(RecommendationResponse.class)
                .doOnError(error -> {
                    System.err.println("❌ Error calling Recommendation API: " + error.getMessage());
                })
                .onErrorReturn(createErrorResponse("Failed to fetch recommendations"));
    }

    private RecommendationResponse createErrorResponse(String message) {
        RecommendationResponse response = new RecommendationResponse();
        response.setSuccess(false);
        response.setMessage(message);
        response.setStatus("ERROR");
        response.setDescription("Unable to connect to recommendation service");
        response.setData(null);
        return response;
    }
}
