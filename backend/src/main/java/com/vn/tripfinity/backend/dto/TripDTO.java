package com.vn.tripfinity.backend.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TripDTO {

    private Integer tripId;

    @NotNull(message = "User ID không được để trống")
    private Integer userId;

    @NotBlank(message = "Tên chuyến đi không được để trống")
    private String tripName;

    @NotNull(message = "Ngày bắt đầu không được để trống")
    private LocalDate startDate;

    @NotNull(message = "Ngày kết thúc không được để trống")
    private LocalDate endDate;

    private String coverImage;

    private String status; // active, completed, cancelled

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    // Additional fields for response
    private String userName;
    private Integer totalDays;
    private Integer totalItineraryItems;
    private List<TripItineraryDTO> itineraries;
}
