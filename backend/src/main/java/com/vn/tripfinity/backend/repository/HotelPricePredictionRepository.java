package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.HotelPricePrediction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface HotelPricePredictionRepository extends JpaRepository<HotelPricePrediction, Integer> {

    List<HotelPricePrediction> findByHotel_HotelId(Integer hotelId);

    Optional<HotelPricePrediction> findByHotel_HotelIdAndPredictedDate(Integer hotelId, LocalDate predictedDate);

    @Query("SELECT p FROM HotelPricePrediction p WHERE p.hotel.hotelId = :hotelId AND p.predictedDate BETWEEN :startDate AND :endDate ORDER BY p.predictedDate")
    List<HotelPricePrediction> findByHotelAndDateRange(@Param("hotelId") Integer hotelId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
}