package com.vn.tripfinity.backend.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.vn.tripfinity.backend.dto.ReviewReplyDTO;
import com.vn.tripfinity.backend.service.ReviewReplyService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/review-replies")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class ReviewReplyController {

    private final ReviewReplyService reviewReplyService;

    @PostMapping
    public ResponseEntity<ReviewReplyDTO> createReply(@Valid @RequestBody ReviewReplyDTO dto) {
        log.info("POST /api/review-replies - Creating reply for review: {} {}", dto.getReviewType(), dto.getReviewId());
        ReviewReplyDTO created = reviewReplyService.createReply(dto);
        return ResponseEntity.ok(created);
    }

    @GetMapping
    public ResponseEntity<List<ReviewReplyDTO>> getReplies(
            @RequestParam String reviewType,
            @RequestParam Integer reviewId,
            @RequestParam(required = false) Integer currentUserId) {
        log.info("GET /api/review-replies - Getting replies for: {} {}", reviewType, reviewId);
        List<ReviewReplyDTO> replies = reviewReplyService.getRepliesByReview(reviewType, reviewId, currentUserId);
        return ResponseEntity.ok(replies);
    }

    @GetMapping("/count")
    public ResponseEntity<Long> getReplyCount(
            @RequestParam String reviewType,
            @RequestParam Integer reviewId) {
        log.info("GET /api/review-replies/count - reviewType: {}, reviewId: {}", reviewType, reviewId);
        Long count = reviewReplyService.getReplyCount(reviewType, reviewId);
        return ResponseEntity.ok(count);
    }

    @PutMapping("/{replyId}")
    public ResponseEntity<ReviewReplyDTO> updateReply(
            @PathVariable Integer replyId,
            @Valid @RequestBody ReviewReplyDTO dto) {
        log.info("PUT /api/review-replies/{} - Updating reply", replyId);
        ReviewReplyDTO updated = reviewReplyService.updateReply(replyId, dto.getContent());
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{replyId}")
    public ResponseEntity<Void> deleteReply(@PathVariable Integer replyId) {
        log.info("DELETE /api/review-replies/{} - Deleting reply", replyId);
        reviewReplyService.deleteReply(replyId);
        return ResponseEntity.noContent().build();
    }
}
