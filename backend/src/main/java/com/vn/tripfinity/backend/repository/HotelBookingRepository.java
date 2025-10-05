package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.HotelBooking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

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
}