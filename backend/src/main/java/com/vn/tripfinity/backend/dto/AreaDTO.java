package com.vn.tripfinity.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AreaDTO {

    private Integer areaId;

    @NotBlank(message = "name không được để trống")
    @Size(max = 255)
    private String name;

    @NotBlank(message = "slug không được để trống")
    @Size(max = 255)
    private String slug;

    @Size(max = 32)
    private String areaType;

    @Size(max = 255)
    private String shortDescription;

    @Size(max = 512)
    private String coverImageUrl;

    @DecimalMin(value = "0.00", inclusive = true, message = "avgRating phải >= 0.00")
    @DecimalMax(value = "5.00", inclusive = true, message = "avgRating phải <= 5.00")
    private BigDecimal avgRating;

    @Min(value = 0, message = "ratingsCount phải >= 0")
    private Integer ratingsCount;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
