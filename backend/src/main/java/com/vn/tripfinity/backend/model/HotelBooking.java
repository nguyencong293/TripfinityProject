package com.vn.tripfinity.backend.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "hotel_bookings")
public class HotelBooking {

    public enum BookingStatus {
        pending, confirmed, cancelled, completed, refunded, checked_out
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "booking_id")
    private Integer bookingId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hotel_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Hotel hotel;

    @Column(name = "booking_date", nullable = false)
    private LocalDateTime bookingDate;

    @Column(name = "start_date")
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column(name = "num_adults", nullable = false)
    private Integer numAdults;

    @Column(name = "rooms", nullable = false)
    private Integer rooms;

    @Column(name = "total_price", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalPrice;

    @Column(name = "currency_code", nullable = false, length = 3)
    private String currencyCode;

    @Enumerated(EnumType.STRING)
    @Column(name = "booking_status", nullable = false, length = 32)
    private BookingStatus bookingStatus;

    @Column(name = "e_ticket_url", length = 512)
    private String eTicketUrl;

    @Column(name = "qr_code_data", columnDefinition = "TEXT")
    private String qrCodeData;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Provider provider;

    @Column(name = "channel", length = 100)
    private String channel;

    @Column(name = "hold_until")
    private LocalDateTime holdUntil;

    @Column(name = "provider_seen", nullable = false)
    private boolean providerSeen;

    @Column(name = "provider_notes", columnDefinition = "TEXT")
    private String providerNotes;

    @Column(name = "provider_confirmed", nullable = false)
    private Integer providerConfirmed; // 0=pending, 1=confirmed, 2=cancelled

    @Column(name = "provider_confirmed_at")
    private LocalDateTime providerConfirmedAt;

    @PrePersist
    public void prePersist() {
        if (bookingDate == null)
            bookingDate = LocalDateTime.now();
        if (numAdults == null)
            numAdults = 1;
        if (rooms == null)
            rooms = 1;
        if (bookingStatus == null)
            bookingStatus = BookingStatus.pending;
        if (currencyCode == null)
            currencyCode = "VND";
        if (providerConfirmed == null)
            providerConfirmed = 0;
    }
}