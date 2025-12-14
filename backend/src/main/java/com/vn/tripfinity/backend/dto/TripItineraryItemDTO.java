package com.vn.tripfinity.backend.dto;

import java.time.LocalDateTime;
import java.time.LocalTime;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TripItineraryItemDTO {

    private Integer itemId;

    @NotNull(message = "Itinerary ID không được để trống")
    private Integer itineraryId;

    @NotNull(message = "Service type không được để trống")
    private String serviceType; // hotel, restaurant, attraction, tour

    @NotNull(message = "Service ID không được để trống")
    private Integer serviceId;

    private Integer itemOrder;

    private LocalTime startTime;

    private LocalTime endTime;

    private LocalDateTime createdAt;

    // Additional fields for response with service details
    private String serviceName;
    private String serviceThumbnail;
    private String serviceAddress;
    private Double serviceRating;
    private Double servicePrice;
    private String serviceCurrency;
}
