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
public class PointDTO {
    private Integer pointId;
    private Integer userId;
    private Integer points;
    private String reason;
    private Integer relatedId;
    private LocalDateTime createdAt;
}
