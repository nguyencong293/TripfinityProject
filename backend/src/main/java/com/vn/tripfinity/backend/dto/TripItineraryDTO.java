package com.vn.tripfinity.backend.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TripItineraryDTO {

    private Integer itineraryId;

    @NotNull(message = "Trip ID không được để trống")
    private Integer tripId;

    @NotNull(message = "Ngày hành trình không được để trống")
    private LocalDate itineraryDate;

    private String notes;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    // Additional fields for response
    private String dayLabel; // e.g., "Thứ Năm, 12 thg 6"
    private Integer totalItems;
    private List<TripItineraryItemDTO> items;
}
