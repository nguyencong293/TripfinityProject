package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.HotelPriceAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface HotelPriceAlertRepository extends JpaRepository<HotelPriceAlert, Integer> {

        List<HotelPriceAlert> findByUser_UserId(Integer userId);

        List<HotelPriceAlert> findByHotel_HotelId(Integer hotelId);

        @Query("SELECT a FROM HotelPriceAlert a WHERE a.user.userId = :userId AND a.isActive = :isActive")
        List<HotelPriceAlert> findByUserAndActive(@Param("userId") Integer userId,
                        @Param("isActive") Boolean isActive);

        @Query("SELECT a FROM HotelPriceAlert a WHERE a.hotel.hotelId = :hotelId AND a.isActive = true AND a.targetPrice >= :currentPrice")
        List<HotelPriceAlert> findActiveAlertsTriggered(@Param("hotelId") Integer hotelId,
                        @Param("currentPrice") BigDecimal currentPrice);

        @Query("SELECT a FROM HotelPriceAlert a WHERE a.hotel.provider.providerId = :providerId ORDER BY a.createdAt DESC")
        List<HotelPriceAlert> findByProvider_ProviderId(@Param("providerId") Integer providerId);

        /**
         * Tìm active price alerts của các hotels thuộc một provider
         */
        @Query("SELECT a FROM HotelPriceAlert a WHERE a.hotel.provider.providerId = :providerId AND a.isActive = true ORDER BY a.createdAt DESC")
        List<HotelPriceAlert> findActiveByProvider_ProviderId(@Param("providerId") Integer providerId);
}