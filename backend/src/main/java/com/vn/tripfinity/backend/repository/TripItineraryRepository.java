package com.vn.tripfinity.backend.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.TripItinerary;

@Repository
public interface TripItineraryRepository extends JpaRepository<TripItinerary, Integer> {

    /**
     * Find all itineraries for a trip
     */
    List<TripItinerary> findByTrip_TripId(Integer tripId);

    /**
     * Find all itineraries for a trip, ordered by date
     */
    @Query("SELECT ti FROM TripItinerary ti WHERE ti.trip.tripId = :tripId ORDER BY ti.itineraryDate ASC")
    List<TripItinerary> findByTripIdOrderByDate(@Param("tripId") Integer tripId);

    /**
     * Find itinerary by trip ID and date
     */
    Optional<TripItinerary> findByTrip_TripIdAndItineraryDate(Integer tripId, LocalDate itineraryDate);

    /**
     * Check if itinerary exists for a specific date in a trip
     */
    boolean existsByTrip_TripIdAndItineraryDate(Integer tripId, LocalDate itineraryDate);

    /**
     * Delete all itineraries for a trip
     */
    void deleteByTrip_TripId(Integer tripId);
}
