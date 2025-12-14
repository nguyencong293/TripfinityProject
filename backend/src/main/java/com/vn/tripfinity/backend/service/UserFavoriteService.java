package com.vn.tripfinity.backend.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.UserFavoriteDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Attraction;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.Restaurant;
import com.vn.tripfinity.backend.model.Tour;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.model.UserFavorite;
import com.vn.tripfinity.backend.model.UserFavorite.ServiceType;
import com.vn.tripfinity.backend.repository.AttractionRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.HotelReviewRepository;
import com.vn.tripfinity.backend.repository.RestaurantRepository;
import com.vn.tripfinity.backend.repository.RestaurantReviewRepository;
import com.vn.tripfinity.backend.repository.TourRepository;
import com.vn.tripfinity.backend.repository.TourReviewRepository;
import com.vn.tripfinity.backend.repository.UserFavoriteRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserFavoriteService {
    
    private final UserFavoriteRepository userFavoriteRepository;
    private final UserRepository userRepository;
    private final HotelRepository hotelRepository;
    private final RestaurantRepository restaurantRepository;
    private final AttractionRepository attractionRepository;
    private final TourRepository tourRepository;
    private final HotelReviewRepository hotelReviewRepository;
    private final RestaurantReviewRepository restaurantReviewRepository;
    private final TourReviewRepository tourReviewRepository;
    
    /**
     * Add service to favorites
     */
    public UserFavoriteDTO addFavorite(Integer userId, String serviceType, Integer serviceId) {
        log.info("Adding favorite: userId={}, serviceType={}, serviceId={}", userId, serviceType, serviceId);
        
        // Validate user exists
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
        
        // Parse service type
        ServiceType type;
        try {
            type = ServiceType.valueOf(serviceType.toLowerCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid service type: " + serviceType + 
                ". Must be one of: hotel, restaurant, attraction, tour");
        }
        
        // Validate service exists
        validateServiceExists(type, serviceId);
        
        // Check if already favorited - idempotent operation
        Optional<UserFavorite> existing = userFavoriteRepository
            .findByUser_UserIdAndServiceTypeAndServiceId(userId, type, serviceId);
        
        if (existing.isPresent()) {
            log.info("Favorite already exists, returning existing record: {}", existing.get().getFavoriteId());
            return convertToDTO(existing.get());
        }
        
        // Create favorite
        UserFavorite favorite = new UserFavorite();
        favorite.setUser(user);
        favorite.setServiceType(type);
        favorite.setServiceId(serviceId);
        
        UserFavorite saved = userFavoriteRepository.save(favorite);
        log.info("Favorite added successfully: {}", saved.getFavoriteId());
        
        return convertToDTO(saved);
    }
    
    /**
     * Remove service from favorites
     */
    public void removeFavorite(Integer userId, String serviceType, Integer serviceId) {
        log.info("Removing favorite: userId={}, serviceType={}, serviceId={}", userId, serviceType, serviceId);
        
        ServiceType type;
        try {
            type = ServiceType.valueOf(serviceType.toLowerCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid service type: " + serviceType);
        }
        
        UserFavorite favorite = userFavoriteRepository
            .findByUser_UserIdAndServiceTypeAndServiceId(userId, type, serviceId)
            .orElseThrow(() -> new ResourceNotFoundException("Favorite not found"));
        
        userFavoriteRepository.delete(favorite);
        log.info("Favorite removed successfully");
    }
    
    /**
     * Get all favorites for a user
     */
    public List<UserFavoriteDTO> getUserFavorites(Integer userId) {
        log.info("Getting all favorites for user: {}", userId);
        
        List<UserFavorite> favorites = userFavoriteRepository.findByUser_UserId(userId);
        
        return favorites.stream()
            .map(this::convertToDTOWithDetails)
            .collect(Collectors.toList());
    }
    
    /**
     * Get favorites by service type
     */
    public List<UserFavoriteDTO> getUserFavoritesByType(Integer userId, String serviceType) {
        log.info("Getting favorites for user: {}, type: {}", userId, serviceType);
        
        ServiceType type;
        try {
            type = ServiceType.valueOf(serviceType.toLowerCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid service type: " + serviceType);
        }
        
        List<UserFavorite> favorites = userFavoriteRepository
            .findByUser_UserIdAndServiceType(userId, type);
        
        return favorites.stream()
            .map(this::convertToDTOWithDetails)
            .collect(Collectors.toList());
    }
    
    /**
     * Check if service is favorited
     */
    public boolean isFavorite(Integer userId, String serviceType, Integer serviceId) {
        ServiceType type;
        try {
            type = ServiceType.valueOf(serviceType.toLowerCase());
        } catch (IllegalArgumentException e) {
            return false;
        }
        
        return userFavoriteRepository.existsByUser_UserIdAndServiceTypeAndServiceId(userId, type, serviceId);
    }
    
    /**
     * Get list of favorite service IDs for a specific type
     */
    public List<Integer> getFavoriteServiceIds(Integer userId, String serviceType) {
        ServiceType type;
        try {
            type = ServiceType.valueOf(serviceType.toLowerCase());
        } catch (IllegalArgumentException e) {
            return new ArrayList<>();
        }
        
        return userFavoriteRepository.findServiceIdsByUserIdAndServiceType(userId, type);
    }
    
    /**
     * Get favorite count for a service
     */
    public Long getFavoriteCount(String serviceType, Integer serviceId) {
        ServiceType type;
        try {
            type = ServiceType.valueOf(serviceType.toLowerCase());
        } catch (IllegalArgumentException e) {
            return 0L;
        }
        
        return userFavoriteRepository.countByServiceTypeAndServiceId(type, serviceId);
    }
    
    // Private helper methods
    
    private void validateServiceExists(ServiceType type, Integer serviceId) {
        boolean exists = switch (type) {
            case hotel -> hotelRepository.existsById(serviceId);
            case restaurant -> restaurantRepository.existsById(serviceId);
            case attraction -> attractionRepository.existsById(serviceId);
            case tour -> tourRepository.existsById(serviceId);
        };
        
        if (!exists) {
            throw new ResourceNotFoundException(type + " not found with id: " + serviceId);
        }
    }
    
    private UserFavoriteDTO convertToDTO(UserFavorite favorite) {
        return UserFavoriteDTO.builder()
            .favoriteId(favorite.getFavoriteId())
            .userId(favorite.getUser().getUserId())
            .serviceType(favorite.getServiceType().name())
            .serviceId(favorite.getServiceId())
            .createdAt(favorite.getCreatedAt())
            .build();
    }
    
    private UserFavoriteDTO convertToDTOWithDetails(UserFavorite favorite) {
        UserFavoriteDTO dto = convertToDTO(favorite);
        
        // Add service details based on type
        try {
            switch (favorite.getServiceType()) {
                case hotel -> {
                    Hotel hotel = hotelRepository.findById(favorite.getServiceId()).orElse(null);
                    if (hotel != null) {
                        dto.setServiceName(hotel.getTitle());
                        dto.setServiceThumbnail(hotel.getThumbnailUrl());
                        dto.setServicePrice(hotel.getPricePerNight() != null ? hotel.getPricePerNight().doubleValue() : null);
                        dto.setServiceAddress(hotel.getAddress());
                        
                        Double avgRating = hotelReviewRepository.calculateAverageRating(hotel.getHotelId());
                        dto.setAverageRating(avgRating != null ? avgRating : 0.0);
                        
                        List<com.vn.tripfinity.backend.model.HotelReview> reviews = hotelReviewRepository.findByHotel_HotelId(hotel.getHotelId());
                        dto.setTotalReviews(reviews.size());
                    }
                }
                case restaurant -> {
                    Restaurant restaurant = restaurantRepository.findById(favorite.getServiceId()).orElse(null);
                    if (restaurant != null) {
                        dto.setServiceName(restaurant.getTitle());
                        dto.setServiceThumbnail(restaurant.getThumbnailUrl());
                        dto.setServicePrice(restaurant.getPrice() != null ? restaurant.getPrice().doubleValue() : null);
                        dto.setServiceAddress(restaurant.getAddress());
                        
                        Double avgRating = restaurantReviewRepository.calculateAverageRating(restaurant.getRestaurantId());
                        dto.setAverageRating(avgRating != null ? avgRating : 0.0);
                        
                        List<com.vn.tripfinity.backend.model.RestaurantReview> reviews = restaurantReviewRepository.findByRestaurant_RestaurantId(restaurant.getRestaurantId());
                        dto.setTotalReviews(reviews.size());
                    }
                }
                case attraction -> {
                    Attraction attraction = attractionRepository.findById(favorite.getServiceId()).orElse(null);
                    if (attraction != null) {
                        dto.setServiceName(attraction.getTitle());
                        dto.setServiceThumbnail(attraction.getThumbnailUrl());
                        dto.setServicePrice(attraction.getPrice() != null ? attraction.getPrice().doubleValue() : null);
                        dto.setServiceAddress(attraction.getAddress());
                        dto.setAverageRating(0.0);
                        dto.setTotalReviews(0);
                    }
                }
                case tour -> {
                    Tour tour = tourRepository.findById(favorite.getServiceId()).orElse(null);
                    if (tour != null) {
                        dto.setServiceName(tour.getTitle());
                        dto.setServiceThumbnail(tour.getThumbnailUrl());
                        dto.setServicePrice(tour.getPrice() != null ? tour.getPrice().doubleValue() : null);
                        dto.setServiceAddress(tour.getAddress());
                        
                        Double avgRating = tourReviewRepository.calculateAverageRating(tour.getTourId());
                        dto.setAverageRating(avgRating != null ? avgRating : 0.0);
                        
                        List<com.vn.tripfinity.backend.model.TourReview> reviews = tourReviewRepository.findByTour_TourId(tour.getTourId());
                        dto.setTotalReviews(reviews.size());
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Error loading service details for favorite {}: {}", favorite.getFavoriteId(), e.getMessage());
        }
        
        return dto;
    }
}
