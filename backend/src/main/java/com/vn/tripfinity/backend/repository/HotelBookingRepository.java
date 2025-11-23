package com.vn.tripfinity.backend.repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.HotelBooking;

@Repository
public interface HotelBookingRepository extends JpaRepository<HotelBooking, Integer> {

    List<HotelBooking> findByUser_UserId(Integer userId);

    List<HotelBooking> findByHotel_HotelId(Integer hotelId);

    List<HotelBooking> findByProvider_ProviderId(Integer providerId);

    @Query("SELECT b FROM HotelBooking b WHERE b.user.userId = :userId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<HotelBooking> findByUserAndStatus(@Param("userId") Integer userId,
            @Param("status") HotelBooking.BookingStatus status);

    @Query("SELECT b FROM HotelBooking b WHERE b.hotel.hotelId = :hotelId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<HotelBooking> findByHotelAndStatus(@Param("hotelId") Integer hotelId,
            @Param("status") HotelBooking.BookingStatus status);

    @Query("SELECT b FROM HotelBooking b WHERE b.provider.providerId = :providerId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<HotelBooking> findByProviderAndStatus(@Param("providerId") Integer providerId,
            @Param("status") HotelBooking.BookingStatus status);

    @Query("SELECT b FROM HotelBooking b WHERE b.provider.providerId = :providerId AND b.providerSeen = :seen ORDER BY b.bookingDate DESC")
    List<HotelBooking> findByProviderAndSeen(@Param("providerId") Integer providerId,
            @Param("seen") Boolean seen);

    @Query("SELECT b FROM HotelBooking b WHERE b.bookingStatus = 'pending' AND b.holdUntil < :currentTime")
    List<HotelBooking> findExpiredPendingBookings(@Param("currentTime") LocalDateTime currentTime);

    // Tìm booking cần check-out (đã completed và quá end_date + 1 ngày)
    @Query("SELECT b FROM HotelBooking b WHERE b.bookingStatus = 'completed' AND b.endDate < :cutoffDate")
    List<HotelBooking> findBookingsToCheckOut(@Param("cutoffDate") LocalDate cutoffDate);

    // Tính tổng số phòng đã book của 1 hotel (chỉ tính booking đã confirmed)
    @Query("SELECT COALESCE(SUM(b.rooms), 0) FROM HotelBooking b WHERE b.hotel.hotelId = :hotelId AND b.providerConfirmed = 1")
    Integer sumRoomsByHotelAndConfirmed(@Param("hotelId") Integer hotelId);

    // Tính tổng số người đã book của 1 hotel (chỉ tính booking đã confirmed)
    @Query("SELECT COALESCE(SUM(b.numAdults), 0) FROM HotelBooking b WHERE b.hotel.hotelId = :hotelId AND b.providerConfirmed = 1")
    Integer sumGuestsByHotelAndConfirmed(@Param("hotelId") Integer hotelId);

    // Tính tổng số phòng đã book của 1 hotel (tính TẤT CẢ booking active, không tính cancelled/refunded/checked_out)
    @Query("SELECT COALESCE(SUM(b.rooms), 0) FROM HotelBooking b WHERE b.hotel.hotelId = :hotelId AND b.bookingStatus NOT IN ('cancelled', 'refunded', 'checked_out')")
    Integer sumRoomsByHotelActive(@Param("hotelId") Integer hotelId);

    // Tính tổng số người đã book của 1 hotel (tính TẤT CẢ booking active, không tính cancelled/refunded/checked_out)
    @Query("SELECT COALESCE(SUM(b.numAdults), 0) FROM HotelBooking b WHERE b.hotel.hotelId = :hotelId AND b.bookingStatus NOT IN ('cancelled', 'refunded', 'checked_out')")
    Integer sumGuestsByHotelActive(@Param("hotelId") Integer hotelId);
}