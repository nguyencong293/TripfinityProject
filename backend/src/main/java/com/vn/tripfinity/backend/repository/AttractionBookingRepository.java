package com.vn.tripfinity.backend.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.AttractionBooking;

@Repository
public interface AttractionBookingRepository extends JpaRepository<AttractionBooking, Integer> {

    List<AttractionBooking> findByUser_UserId(Integer userId);

    List<AttractionBooking> findByAttraction_AttractionId(Integer attractionId);

    List<AttractionBooking> findByProvider_ProviderId(Integer providerId);

    @Query("SELECT b FROM AttractionBooking b WHERE b.user.userId = :userId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<AttractionBooking> findByUserAndStatus(@Param("userId") Integer userId,
            @Param("status") AttractionBooking.BookingStatus status);

    @Query("SELECT b FROM AttractionBooking b WHERE b.attraction.attractionId = :attractionId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<AttractionBooking> findByAttractionAndStatus(@Param("attractionId") Integer attractionId,
            @Param("status") AttractionBooking.BookingStatus status);

    @Query("SELECT b FROM AttractionBooking b WHERE b.provider.providerId = :providerId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<AttractionBooking> findByProviderAndStatus(@Param("providerId") Integer providerId,
            @Param("status") AttractionBooking.BookingStatus status);

    @Query("SELECT b FROM AttractionBooking b WHERE b.provider.providerId = :providerId AND b.providerSeen = :seen ORDER BY b.bookingDate DESC")
    List<AttractionBooking> findByProviderAndSeen(@Param("providerId") Integer providerId,
            @Param("seen") Boolean seen);

    @Query("SELECT b FROM AttractionBooking b WHERE b.bookingStatus = 'pending' AND b.holdUntil < :currentTime")
    List<AttractionBooking> findExpiredPendingBookings(@Param("currentTime") LocalDateTime currentTime);

    // Tính tổng số người đã book của 1 attraction (tính TẤT CẢ booking active, không tính cancelled/refunded)
    @Query("SELECT COALESCE(SUM(b.numAdults), 0) FROM AttractionBooking b WHERE b.attraction.attractionId = :attractionId AND b.bookingStatus NOT IN ('cancelled', 'refunded')")
    Integer sumGuestsByAttractionActive(@Param("attractionId") Integer attractionId);
}
