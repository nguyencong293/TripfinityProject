package com.vn.tripfinity.backend.dto;

import java.time.LocalDateTime;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserFavoriteDTO {
    
    private Integer favoriteId;
    
    @NotNull(message = "User ID không được để trống")
    private Integer userId;
    
    @NotNull(message = "Service type không được để trống")
    private String serviceType; // hotel, restaurant, attraction, tour
    
    @NotNull(message = "Service ID không được để trống")
    private Integer serviceId;
    
    private LocalDateTime createdAt;
    
    // Additional fields for response
    private String serviceName;
    private String serviceThumbnail;
    private Double servicePrice;
    private String serviceAddress;
}
