package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.HotelVirtualTour;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HotelVirtualTourRepository extends JpaRepository<HotelVirtualTour, Integer> {

    List<HotelVirtualTour> findByHotel_HotelId(Integer hotelId);

    List<HotelVirtualTour> findByHotel_HotelIdAndMediaType(Integer hotelId, HotelVirtualTour.MediaType mediaType);
}