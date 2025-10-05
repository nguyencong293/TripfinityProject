package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelVirtualTourDTO {

    private Integer virtualTourId;

    @NotNull(message = "hotelId không được để trống")
    @JsonAlias("hotel_id")
    private Integer hotelId;

    @NotNull(message = "mediaType không được để trống")
    @JsonAlias("media_type")
    private String mediaType; // 360_image, 360_video, ar_model

    @NotBlank(message = "mediaUrl không được để trống")
    @Size(max = 512)
    @JsonAlias("media_url")
    private String mediaUrl;

    @Size(max = 512)
    @JsonAlias("thumbnail_url")
    private String thumbnailUrl;

    @JsonAlias("metadata_json")
    private String metadataJson;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}