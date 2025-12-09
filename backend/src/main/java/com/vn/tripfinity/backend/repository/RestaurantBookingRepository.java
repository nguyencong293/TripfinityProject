package com.vn.tripfinity.backend.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.RestaurantBooking;

@Repository
public interface RestaurantBookingRepository extends JpaRepository<RestaurantBooking, Integer> {

    List<RestaurantBooking> findByUser_UserId(Integer userId);

    List<RestaurantBooking> findByRestaurant_RestaurantId(Integer restaurantId);

    List<RestaurantBooking> findByProvider_ProviderId(Integer providerId);

    @Query("SELECT b FROM RestaurantBooking b WHERE b.user.userId = :userId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<RestaurantBooking> findByUserAndStatus(@Param("userId") Integer userId,
            @Param("status") RestaurantBooking.BookingStatus status);

    @Query("SELECT b FROM RestaurantBooking b WHERE b.restaurant.restaurantId = :restaurantId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<RestaurantBooking> findByRestaurantAndStatus(@Param("restaurantId") Integer restaurantId,
            @Param("status") RestaurantBooking.BookingStatus status);

    @Query("SELECT b FROM RestaurantBooking b WHERE b.provider.providerId = :providerId AND b.bookingStatus = :status ORDER BY b.bookingDate DESC")
    List<RestaurantBooking> findByProviderAndStatus(@Param("providerId") Integer providerId,
            @Param("status") RestaurantBooking.BookingStatus status);

    @Query("SELECT b FROM RestaurantBooking b WHERE b.provider.providerId = :providerId AND b.providerSeen = :seen ORDER BY b.bookingDate DESC")
    List<RestaurantBooking> findByProviderAndSeen(@Param("providerId") Integer providerId,
            @Param("seen") Boolean seen);

    @Query("SELECT b FROM RestaurantBooking b WHERE b.bookingStatus = 'pending' AND b.holdUntil < :currentTime")
    List<RestaurantBooking> findExpiredPendingBookings(@Param("currentTime") LocalDateTime currentTime);
}
