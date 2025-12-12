package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vn.tripfinity.backend.dto.BadgeDTO;
import com.vn.tripfinity.backend.dto.PointDTO;
import com.vn.tripfinity.backend.dto.UserBadgeDTO;
import com.vn.tripfinity.backend.dto.UserPointsSummaryDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Badge;
import com.vn.tripfinity.backend.model.Point;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.model.UserBadge;
import com.vn.tripfinity.backend.repository.BadgeRepository;
import com.vn.tripfinity.backend.repository.PointRepository;
import com.vn.tripfinity.backend.repository.UserBadgeRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class PointsService {
    
    private final PointRepository pointRepository;
    private final BadgeRepository badgeRepository;
    private final UserBadgeRepository userBadgeRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;
    
    private static final int BOOKING_SUCCESS_POINTS = 50;
    
    /**
     * Add points to user and check for badge unlocks
     */
    public PointDTO addPoints(Integer userId, Integer points, String reason, Integer relatedId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        
        Point point = Point.builder()
                .user(user)
                .points(points)
                .reason(reason)
                .relatedId(relatedId)
                .createdAt(LocalDateTime.now())
                .build();
        
        Point saved = pointRepository.save(point);
        log.info("✅ Added {} points to user {} for reason: {}", points, userId, reason);
        
        // Check and unlock badges
        checkAndUnlockBadges(userId);
        
        return toPointDTO(saved);
    }
    
    /**
     * Award points for successful booking
     */
    public PointDTO awardBookingPoints(Integer userId, String bookingType, Integer bookingId) {
        String reason = String.format("Booking %s thành công", bookingType);
        return addPoints(userId, BOOKING_SUCCESS_POINTS, reason, bookingId);
    }
    
    /**
     * Get user's total points
     */
    public Integer getTotalPoints(Integer userId) {
        return pointRepository.getTotalPointsByUserId(userId);
    }
    
    /**
     * Get user's points history
     */
    public List<PointDTO> getPointsHistory(Integer userId) {
        return pointRepository.findByUser_UserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toPointDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Get user's unlocked badges
     */
    public List<UserBadgeDTO> getUnlockedBadges(Integer userId) {
        return userBadgeRepository.findByUser_UserIdOrderByUnlockedAtDesc(userId).stream()
                .map(this::toUserBadgeDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Get all available badges
     */
    public List<BadgeDTO> getAllBadges() {
        return badgeRepository.findAllByOrderByBadgeIdAsc().stream()
                .map(this::toBadgeDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Get complete user points summary
     */
    public UserPointsSummaryDTO getUserPointsSummary(Integer userId) {
        Integer totalPoints = getTotalPoints(userId);
        List<PointDTO> recentPoints = getPointsHistory(userId);
        List<UserBadgeDTO> unlockedBadges = getUnlockedBadges(userId);
        List<BadgeDTO> allBadges = getAllBadges();
        
        return UserPointsSummaryDTO.builder()
                .userId(userId)
                .totalPoints(totalPoints)
                .recentPoints(recentPoints)
                .unlockedBadges(unlockedBadges)
                .availableBadges(allBadges)
                .build();
    }
    
    /**
     * Check user's points and unlock badges if threshold met
     */
    private void checkAndUnlockBadges(Integer userId) {
        Integer totalPoints = getTotalPoints(userId);
        List<Badge> allBadges = badgeRepository.findAllByOrderByBadgeIdAsc();
        
        for (Badge badge : allBadges) {
            try {
                // Parse required points from criteria_json
                BadgeCriteria criteria = objectMapper.readValue(badge.getCriteriaJson(), BadgeCriteria.class);
                
                // Check if user has enough points and doesn't already have this badge
                if (totalPoints >= criteria.getRequiredPoints() &&
                    !userBadgeRepository.existsByUser_UserIdAndBadge_BadgeId(userId, badge.getBadgeId())) {
                    
                    User user = userRepository.findById(userId).orElseThrow();
                    UserBadge userBadge = UserBadge.builder()
                            .user(user)
                            .badge(badge)
                            .unlockedAt(LocalDateTime.now())
                            .build();
                    
                    userBadgeRepository.save(userBadge);
                    log.info("🎖️ User {} unlocked badge: {} ({})", userId, badge.getBadgeName(), totalPoints);
                }
            } catch (JsonProcessingException e) {
                log.error("Failed to parse badge criteria for badgeId {}: {}", badge.getBadgeId(), e.getMessage());
            }
        }
    }
    
    /**
     * Initialize default badges (call once on startup or via admin endpoint)
     */
    public void initializeDefaultBadges() {
        if (badgeRepository.count() > 0) {
            log.info("Badges already initialized, skipping...");
            return;
        }
        
        List<Badge> defaultBadges = new ArrayList<>();
        
        defaultBadges.add(createBadge("Đồng", "Du khách mới - Bắt đầu hành trình khám phá", "🥉", 200));
        defaultBadges.add(createBadge("Bạc", "Nhà thám hiểm - Đã có nhiều trải nghiệm", "🥈", 500));
        defaultBadges.add(createBadge("Vàng", "Du lịch chuyên nghiệp - Người đi nhiều nơi", "🥇", 1000));
        defaultBadges.add(createBadge("Kim cương", "Huyền thoại du lịch - Bậc thầy khám phá", "💎", 2000));
        defaultBadges.add(createBadge("Huyền thoại", "Bậc thầy du lịch - Đỉnh cao của du lịch", "👑", 5000));
        
        badgeRepository.saveAll(defaultBadges);
        log.info("✅ Initialized {} default badges", defaultBadges.size());
    }
    
    private Badge createBadge(String name, String description, String icon, int requiredPoints) {
        BadgeCriteria criteria = new BadgeCriteria();
        criteria.setRequiredPoints(requiredPoints);
        
        try {
            String criteriaJson = objectMapper.writeValueAsString(criteria);
            return Badge.builder()
                    .badgeName(name)
                    .badgeDescription(description)
                    .iconUrl(icon)
                    .criteriaJson(criteriaJson)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build();
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to create badge criteria JSON", e);
        }
    }
    
    // DTOs conversion
    private PointDTO toPointDTO(Point point) {
        return PointDTO.builder()
                .pointId(point.getPointId())
                .userId(point.getUser().getUserId())
                .points(point.getPoints())
                .reason(point.getReason())
                .relatedId(point.getRelatedId())
                .createdAt(point.getCreatedAt())
                .build();
    }
    
    private BadgeDTO toBadgeDTO(Badge badge) {
        Integer requiredPoints = 0;
        try {
            BadgeCriteria criteria = objectMapper.readValue(badge.getCriteriaJson(), BadgeCriteria.class);
            requiredPoints = criteria.getRequiredPoints();
        } catch (JsonProcessingException e) {
            log.error("Failed to parse badge criteria: {}", e.getMessage());
        }
        
        return BadgeDTO.builder()
                .badgeId(badge.getBadgeId())
                .badgeName(badge.getBadgeName())
                .badgeDescription(badge.getBadgeDescription())
                .iconUrl(badge.getIconUrl())
                .requiredPoints(requiredPoints)
                .createdAt(badge.getCreatedAt())
                .updatedAt(badge.getUpdatedAt())
                .build();
    }
    
    private UserBadgeDTO toUserBadgeDTO(UserBadge userBadge) {
        return UserBadgeDTO.builder()
                .userBadgeId(userBadge.getUserBadgeId())
                .userId(userBadge.getUser().getUserId())
                .badge(toBadgeDTO(userBadge.getBadge()))
                .unlockedAt(userBadge.getUnlockedAt())
                .build();
    }
    
    // Inner class for badge criteria
    @Data
    public static class BadgeCriteria {
        private Integer requiredPoints;
    }
}
