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
public class BadgeDTO {
    private Integer badgeId;
    private String badgeName;
    private String badgeDescription;
    private String iconUrl;
    private Integer requiredPoints;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
