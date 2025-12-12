package com.vn.tripfinity.backend.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserBadgeDTO {
    private Integer userBadgeId;
    private Integer userId;
    private BadgeDTO badge;
    private LocalDateTime unlockedAt;
}
