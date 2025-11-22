package com.vn.tripfinity.backend.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.vn.tripfinity.backend.dto.ReviewLikeDTO;
import com.vn.tripfinity.backend.service.ReviewLikeService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/review-likes")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class ReviewLikeController {

    private final ReviewLikeService reviewLikeService;

    @PostMapping("/toggle")
    public ResponseEntity<Map<String, Object>> toggleLike(@Valid @RequestBody ReviewLikeDTO dto) {
        log.info("POST /api/review-likes/toggle - user: {}, review: {} {}",
                dto.getUserId(), dto.getReviewType(), dto.getReviewId());

        boolean isLiked = reviewLikeService.toggleLike(dto);
        Long likeCount = reviewLikeService.getLikeCount(dto.getReviewType(), dto.getReviewId(), dto.getReplyId());

        Map<String, Object> response = new HashMap<>();
        response.put("isLiked", isLiked);
        response.put("likeCount", likeCount);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/count")
    public ResponseEntity<Long> getLikeCount(
            @RequestParam String reviewType,
            @RequestParam Integer reviewId,
            @RequestParam(required = false) Integer replyId) {
        log.info("GET /api/review-likes/count - reviewType: {}, reviewId: {}, replyId: {}",
                reviewType, reviewId, replyId);
        Long count = reviewLikeService.getLikeCount(reviewType, reviewId, replyId);
        return ResponseEntity.ok(count);
    }

    @GetMapping("/check")
    public ResponseEntity<Boolean> checkLiked(
            @RequestParam Integer userId,
            @RequestParam String reviewType,
            @RequestParam Integer reviewId,
            @RequestParam(required = false) Integer replyId) {
        log.info("GET /api/review-likes/check - userId: {}, reviewType: {}, reviewId: {}, replyId: {}",
                userId, reviewType, reviewId, replyId);
        boolean isLiked = reviewLikeService.isLiked(userId, reviewType, reviewId, replyId);
        return ResponseEntity.ok(isLiked);
    }
}
