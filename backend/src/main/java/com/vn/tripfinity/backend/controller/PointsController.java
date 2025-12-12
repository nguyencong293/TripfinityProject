package com.vn.tripfinity.backend.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.vn.tripfinity.backend.dto.BadgeDTO;
import com.vn.tripfinity.backend.dto.PointDTO;
import com.vn.tripfinity.backend.dto.UserBadgeDTO;
import com.vn.tripfinity.backend.dto.UserPointsSummaryDTO;
import com.vn.tripfinity.backend.service.PointsService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/points")
@RequiredArgsConstructor
@Slf4j
public class PointsController {
    
    private final PointsService pointsService;
    
    /**
     * Get user's total points
     */
    @GetMapping("/user/{userId}/total")
    public ResponseEntity<Integer> getTotalPoints(@PathVariable Integer userId) {
        log.debug("Get total points for user: {}", userId);
        Integer total = pointsService.getTotalPoints(userId);
        return ResponseEntity.ok(total);
    }
    
    /**
     * Get user's points history
     */
    @GetMapping("/user/{userId}/history")
    public ResponseEntity<List<PointDTO>> getPointsHistory(@PathVariable Integer userId) {
        log.debug("Get points history for user: {}", userId);
        List<PointDTO> history = pointsService.getPointsHistory(userId);
        return ResponseEntity.ok(history);
    }
    
    /**
     * Get user's unlocked badges
     */
    @GetMapping("/user/{userId}/badges")
    public ResponseEntity<List<UserBadgeDTO>> getUnlockedBadges(@PathVariable Integer userId) {
        log.debug("Get unlocked badges for user: {}", userId);
        List<UserBadgeDTO> badges = pointsService.getUnlockedBadges(userId);
        return ResponseEntity.ok(badges);
    }
    
    /**
     * Get all available badges
     */
    @GetMapping("/badges")
    public ResponseEntity<List<BadgeDTO>> getAllBadges() {
        log.debug("Get all badges");
        List<BadgeDTO> badges = pointsService.getAllBadges();
        return ResponseEntity.ok(badges);
    }
    
    /**
     * Get complete user points summary
     */
    @GetMapping("/user/{userId}/summary")
    public ResponseEntity<UserPointsSummaryDTO> getUserPointsSummary(@PathVariable Integer userId) {
        log.debug("Get points summary for user: {}", userId);
        UserPointsSummaryDTO summary = pointsService.getUserPointsSummary(userId);
        return ResponseEntity.ok(summary);
    }
    
    /**
     * Initialize default badges (admin endpoint)
     */
    @PostMapping("/admin/init-badges")
    public ResponseEntity<String> initializeBadges() {
        log.info("Initializing default badges");
        pointsService.initializeDefaultBadges();
        return ResponseEntity.ok("Badges initialized successfully");
    }
}
