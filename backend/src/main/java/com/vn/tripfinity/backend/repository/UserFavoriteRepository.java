package com.vn.tripfinity.backend.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.UserFavorite;
import com.vn.tripfinity.backend.model.UserFavorite.ServiceType;

@Repository
public interface UserFavoriteRepository extends JpaRepository<UserFavorite, Integer> {
    
    /**
     * Find all favorites by user
     */
    List<UserFavorite> findByUser_UserId(Integer userId);
    
    /**
     * Find all favorites by user and service type
     */
    List<UserFavorite> findByUser_UserIdAndServiceType(Integer userId, ServiceType serviceType);
    
    /**
     * Check if a service is favorited by user
     */
    boolean existsByUser_UserIdAndServiceTypeAndServiceId(
        Integer userId, 
        ServiceType serviceType, 
        Integer serviceId
    );
    
    /**
     * Find specific favorite
     */
    Optional<UserFavorite> findByUser_UserIdAndServiceTypeAndServiceId(
        Integer userId, 
        ServiceType serviceType, 
        Integer serviceId
    );
    
    /**
     * Delete favorite
     */
    void deleteByUser_UserIdAndServiceTypeAndServiceId(
        Integer userId, 
        ServiceType serviceType, 
        Integer serviceId
    );
    
    /**
     * Count favorites by service
     */
    @Query("SELECT COUNT(f) FROM UserFavorite f WHERE f.serviceType = :serviceType AND f.serviceId = :serviceId")
    Long countByServiceTypeAndServiceId(
        @Param("serviceType") ServiceType serviceType, 
        @Param("serviceId") Integer serviceId
    );
    
    /**
     * Get list of service IDs that user favorited for a specific service type
     */
    @Query("SELECT f.serviceId FROM UserFavorite f WHERE f.user.userId = :userId AND f.serviceType = :serviceType")
    List<Integer> findServiceIdsByUserIdAndServiceType(
        @Param("userId") Integer userId, 
        @Param("serviceType") ServiceType serviceType
    );
}
