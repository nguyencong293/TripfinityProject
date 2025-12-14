package com.vn.tripfinity.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.TripItineraryItem;
import com.vn.tripfinity.backend.model.TripItineraryItem.ServiceType;

@Repository
public interface TripItineraryItemRepository extends JpaRepository<TripItineraryItem, Integer> {

    /**
     * Find all items for an itinerary
     */
    @Query("SELECT tii FROM TripItineraryItem tii WHERE tii.itinerary.itineraryId = :itineraryId ORDER BY tii.itemOrder ASC, tii.startTime ASC")
    List<TripItineraryItem> findByItineraryIdOrderByOrder(@Param("itineraryId") Integer itineraryId);

    /**
     * Find all items for an itinerary
     */
    List<TripItineraryItem> findByItinerary_ItineraryId(Integer itineraryId);

    /**
     * Find items by service type and service ID across all itineraries
     */
    List<TripItineraryItem> findByServiceTypeAndServiceId(ServiceType serviceType, Integer serviceId);

    /**
     * Check if a service is already in an itinerary
     */
    boolean existsByItinerary_ItineraryIdAndServiceTypeAndServiceId(
        Integer itineraryId, 
        ServiceType serviceType, 
        Integer serviceId
    );

    /**
     * Count items in an itinerary
     */
    long countByItinerary_ItineraryId(Integer itineraryId);

    /**
     * Delete all items for an itinerary
     */
    void deleteByItinerary_ItineraryId(Integer itineraryId);

    /**
     * Get maximum order for items in an itinerary
     */
    @Query("SELECT COALESCE(MAX(tii.itemOrder), 0) FROM TripItineraryItem tii WHERE tii.itinerary.itineraryId = :itineraryId")
    Integer findMaxOrderByItineraryId(@Param("itineraryId") Integer itineraryId);
}
