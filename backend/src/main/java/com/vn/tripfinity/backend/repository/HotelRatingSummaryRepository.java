package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.HotelRatingSummary;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface HotelRatingSummaryRepository extends JpaRepository<HotelRatingSummary, Integer> {
    @Query("SELECT s FROM HotelRatingSummary s WHERE s.hotel.provider.providerId = :providerId ORDER BY s.totalReviews DESC")
    List<HotelRatingSummary> findByProvider_ProviderId(@Param("providerId") Integer providerId);
}