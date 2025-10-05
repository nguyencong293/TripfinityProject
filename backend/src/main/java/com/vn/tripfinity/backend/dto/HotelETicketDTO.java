package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelETicketDTO {

    private Integer eTicketId;

    @NotNull(message = "bookingId không được để trống")
    @JsonAlias("booking_id")
    private Integer bookingId;

    @NotBlank(message = "ticketCode không được để trống")
    @Size(max = 100)
    @JsonAlias("ticket_code")
    private String ticketCode;

    @NotBlank(message = "qrCodeData không được để trống")
    @JsonAlias("qr_code_data")
    private String qrCodeData;

    @NotBlank(message = "pdfUrl không được để trống")
    @Size(max = 512)
    @JsonAlias("pdf_url")
    private String pdfUrl;

    @JsonAlias("valid_from")
    private LocalDate validFrom;

    @JsonAlias("valid_until")
    private LocalDate validUntil;

    private LocalDateTime createdAt;
}