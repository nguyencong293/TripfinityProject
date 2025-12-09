package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TourPaymentDTO {

    private Integer paymentId;

    @NotNull(message = "bookingId không được để trống")
    @JsonAlias("booking_id")
    private Integer bookingId;

    @NotNull(message = "userId không được để trống")
    @JsonAlias("user_id")
    private Integer userId;

    @NotNull(message = "amount không được để trống")
    @DecimalMin(value = "0.00", message = "amount phải >= 0")
    private BigDecimal amount;

    @Size(max = 3)
    @JsonAlias("currency_code")
    private String currencyCode;

    @NotNull(message = "paymentMethod không được để trống")
    @JsonAlias("payment_method")
    private String paymentMethod; // vnpay, momo, visa, mastercard, paypal, other, zalopay, counter

    @NotBlank(message = "transactionId không được để trống")
    @Size(max = 255)
    @JsonAlias("transaction_id")
    private String transactionId;

    @JsonAlias("payment_status")
    private String paymentStatus; // pending, success, failed, refunded

    @JsonAlias("payment_date")
    private LocalDateTime paymentDate;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
