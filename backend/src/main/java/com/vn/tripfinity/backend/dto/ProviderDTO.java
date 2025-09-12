package com.vn.tripfinity.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProviderDTO {

    private Integer providerId;

    @NotNull(message = "userId không được để trống")
    private Integer userId;

    @NotBlank(message = "companyName không được để trống")
    @Size(max = 255)
    private String companyName;

    @Size(max = 100)
    private String taxCode;

    @Size(max = 512)
    private String address;

    @Email(message = "contactEmail không đúng định dạng")
    @Size(max = 255)
    private String contactEmail;

    @Size(max = 20)
    private String contactPhone;

    @Size(max = 100)
    private String bankAccountNumber;

    @Size(max = 255)
    private String bankName;

    @Size(max = 512)
    private String logoUrl;

    private String providerDescription;

    @DecimalMin(value = "0.00", inclusive = true, message = "ratingOverall phải >= 0.00")
    @DecimalMax(value = "5.00", inclusive = true, message = "ratingOverall phải <= 5.00")
    private BigDecimal ratingOverall;

    // pending/approved/rejected/suspended
    @Size(max = 32)
    private String providerStatus;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}