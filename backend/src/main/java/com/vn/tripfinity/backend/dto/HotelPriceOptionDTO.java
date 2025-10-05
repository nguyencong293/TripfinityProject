package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelPriceOptionDTO {

    private Integer optionId;

    @NotNull(message = "hotelId không được để trống")
    @JsonAlias("hotel_id")
    private Integer hotelId;

    @NotBlank(message = "optionName không được để trống")
    @Size(max = 100)
    @JsonAlias("option_name")
    private String optionName;

    @NotNull(message = "price không được để trống")
    @DecimalMin(value = "0.00", message = "price phải >= 0")
    private BigDecimal price;

    @Size(max = 3)
    @JsonAlias("currency_code")
    private String currencyCode;

    @JsonAlias("per_person")
    private Boolean perPerson;

    @JsonAlias("min_age")
    private Short minAge;

    @JsonAlias("max_age")
    private Short maxAge;

    @Size(max = 255)
    private String description;

    @JsonAlias("includes_json")
    private List<String> includesJson; // JSON array of strings

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}