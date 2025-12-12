package com.vn.tripfinity.backend.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserPointsSummaryDTO {
    private Integer userId;
    private Integer totalPoints;
    private List<PointDTO> recentPoints;
    private List<UserBadgeDTO> unlockedBadges;
    private List<BadgeDTO> availableBadges;
}
