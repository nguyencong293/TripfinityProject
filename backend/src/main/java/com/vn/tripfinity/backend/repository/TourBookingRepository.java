package com.vn.tripfinity.backend.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.TourBooking;

@Repository
public interface TourBookingRepository extends JpaRepository<TourBooking, Integer> {

    List<TourBooking> findByUser_UserId(Integer userId);

    List<TourBooking> findByTour_TourId(Integer tourId);

    List<TourBooking> findByProvider_ProviderId(Integer providerId);

    @Query("SELECT b FROM TourBooking b WHERE b.user.userId = :userId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<TourBooking> findByUserAndStatus(@Param("userId") Integer userId,
            @Param("status") TourBooking.BookingStatus status);

    @Query("SELECT b FROM TourBooking b WHERE b.tour.tourId = :tourId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<TourBooking> findByTourAndStatus(@Param("tourId") Integer tourId,
            @Param("status") TourBooking.BookingStatus status);

    @Query("SELECT b FROM TourBooking b WHERE b.provider.providerId = :providerId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<TourBooking> findByProviderAndStatus(@Param("providerId") Integer providerId,
            @Param("status") TourBooking.BookingStatus status);

    @Query("SELECT b FROM TourBooking b WHERE b.provider.providerId = :providerId AND b.providerSeen = :seen ORDER BY b.bookingDate DESC")
    List<TourBooking> findByProviderAndSeen(@Param("providerId") Integer providerId,
            @Param("seen") Boolean seen);

    @Query("SELECT b FROM TourBooking b WHERE b.bookingStatus = 'pending' AND b.holdUntil < :currentTime")
    List<TourBooking> findExpiredPendingBookings(@Param("currentTime") LocalDateTime currentTime);
}
