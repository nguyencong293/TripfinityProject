package com.vn.tripfinity.backend.repository;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.Trip;
import com.vn.tripfinity.backend.model.Trip.TripStatus;

@Repository
public interface TripRepository extends JpaRepository<Trip, Integer> {

    /**
     * Find all trips by user ID
     */
    List<Trip> findByUser_UserId(Integer userId);

    /**
     * Find all trips by user ID and status
     */
    List<Trip> findByUser_UserIdAndStatus(Integer userId, TripStatus status);

    /**
     * Find all active trips by user ID (active trips only)
     */
    @Query("SELECT t FROM Trip t WHERE t.user.userId = :userId AND t.status = 'active' ORDER BY t.startDate ASC")
    List<Trip> findActiveTrips(@Param("userId") Integer userId);

    /**
     * Find all completed trips by user ID
     */
    @Query("SELECT t FROM Trip t WHERE t.user.userId = :userId AND t.status = 'completed' ORDER BY t.endDate DESC")
    List<Trip> findCompletedTrips(@Param("userId") Integer userId);

    /**
     * Find trips that should be marked as completed (end date has passed)
     */
    @Query("SELECT t FROM Trip t WHERE t.status = 'active' AND t.endDate < :currentDate")
    List<Trip> findExpiredTrips(@Param("currentDate") LocalDate currentDate);

    /**
     * Check if user has a trip with the same name
     */
    boolean existsByUser_UserIdAndTripName(Integer userId, String tripName);

    /**
     * Count active trips for a user
     */
    long countByUser_UserIdAndStatus(Integer userId, TripStatus status);
}
