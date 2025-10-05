package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.HotelPriceOption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HotelPriceOptionRepository extends JpaRepository<HotelPriceOption, Integer> {

    List<HotelPriceOption> findByHotel_HotelId(Integer hotelId);

    Optional<HotelPriceOption> findByHotel_HotelIdAndOptionName(Integer hotelId, String optionName);

    boolean existsByHotel_HotelIdAndOptionName(Integer hotelId, String optionName);
}