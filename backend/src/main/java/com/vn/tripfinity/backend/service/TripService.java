package com.vn.tripfinity.backend.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.TripDTO;
import com.vn.tripfinity.backend.dto.TripItineraryDTO;
import com.vn.tripfinity.backend.dto.TripItineraryItemDTO;
import com.vn.tripfinity.backend.model.Trip;
import com.vn.tripfinity.backend.model.Trip.TripStatus;
import com.vn.tripfinity.backend.model.TripItinerary;
import com.vn.tripfinity.backend.model.TripItineraryItem;
import com.vn.tripfinity.backend.model.TripItineraryItem.ServiceType;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.AttractionRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.RestaurantRepository;
import com.vn.tripfinity.backend.repository.TourRepository;
import com.vn.tripfinity.backend.repository.TripItineraryItemRepository;
import com.vn.tripfinity.backend.repository.TripItineraryRepository;
import com.vn.tripfinity.backend.repository.TripRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class TripService {

    private final TripRepository tripRepository;
    private final TripItineraryRepository tripItineraryRepository;
    private final TripItineraryItemRepository tripItineraryItemRepository;
    private final UserRepository userRepository;
    private final HotelRepository hotelRepository;
    private final RestaurantRepository restaurantRepository;
    private final AttractionRepository attractionRepository;
    private final TourRepository tourRepository;

    /**
     * Create a new trip
     */
    public TripDTO createTrip(TripDTO tripDTO) {
        log.info("Creating trip: {}", tripDTO.getTripName());

        // Validate user
        User user = userRepository.findById(tripDTO.getUserId())
            .orElseThrow(() -> new IllegalArgumentException("User không tồn tại"));

        // Validate dates
        if (tripDTO.getEndDate().isBefore(tripDTO.getStartDate())) {
            throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu");
        }

        // Create trip entity
        Trip trip = new Trip();
        trip.setUser(user);
        trip.setTripName(tripDTO.getTripName());
        trip.setStartDate(tripDTO.getStartDate());
        trip.setEndDate(tripDTO.getEndDate());
        trip.setCoverImage(tripDTO.getCoverImage() != null ? tripDTO.getCoverImage() : "assets/images/onboarding1.png");
        trip.setStatus(TripStatus.active);

        Trip savedTrip = tripRepository.save(trip);
        log.info("Trip created successfully with ID: {}", savedTrip.getTripId());

        return convertToDTO(savedTrip, false);
    }

    /**
     * Get all trips for a user (active trips only, auto-update status)
     */
    public List<TripDTO> getUserTrips(Integer userId) {
        log.info("Getting trips for user: {}", userId);

        // First, update any expired trips
        updateExpiredTrips();

        // Get active trips
        List<Trip> trips = tripRepository.findActiveTrips(userId);
        return trips.stream()
            .map(trip -> convertToDTO(trip, false))
            .collect(Collectors.toList());
    }

    /**
     * Get completed trips for a user
     */
    public List<TripDTO> getUserCompletedTrips(Integer userId) {
        log.info("Getting completed trips for user: {}", userId);

        List<Trip> trips = tripRepository.findCompletedTrips(userId);
        return trips.stream()
            .map(trip -> convertToDTO(trip, false))
            .collect(Collectors.toList());
    }

    /**
     * Get trip detail by ID with full itineraries
     */
    public TripDTO getTripDetail(Integer tripId) {
        log.info("Getting trip detail: {}", tripId);

        Trip trip = tripRepository.findById(tripId)
            .orElseThrow(() -> new IllegalArgumentException("Trip không tồn tại"));

        return convertToDTO(trip, true);
    }

    /**
     * Update trip dates
     */
    public TripDTO updateTripDates(Integer tripId, LocalDate startDate, LocalDate endDate) {
        log.info("Updating trip dates for trip: {}", tripId);

        Trip trip = tripRepository.findById(tripId)
            .orElseThrow(() -> new IllegalArgumentException("Trip không tồn tại"));

        if (endDate.isBefore(startDate)) {
            throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu");
        }

        trip.setStartDate(startDate);
        trip.setEndDate(endDate);

        Trip updatedTrip = tripRepository.save(trip);
        return convertToDTO(updatedTrip, false);
    }

    /**
     * Cancel/Delete a trip
     */
    public void deleteTrip(Integer tripId) {
        log.info("Deleting trip: {}", tripId);

        Trip trip = tripRepository.findById(tripId)
            .orElseThrow(() -> new IllegalArgumentException("Trip không tồn tại"));

        tripRepository.delete(trip);
        log.info("Trip deleted successfully");
    }

    /**
     * Update itinerary notes
     */
    public TripItineraryDTO updateItineraryNotes(Integer itineraryId, String notes) {
        log.info("Updating notes for itinerary: {}", itineraryId);

        TripItinerary itinerary = tripItineraryRepository.findById(itineraryId)
            .orElseThrow(() -> new IllegalArgumentException("Itinerary không tồn tại"));

        itinerary.setNotes(notes);
        TripItinerary updated = tripItineraryRepository.save(itinerary);

        return convertItineraryToDTO(updated, false);
    }

    /**
     * Add item to itinerary (auto-creates itinerary if needed)
     */
    public TripItineraryItemDTO addItineraryItem(TripItineraryItemDTO itemDTO) {
        log.info("Adding item to itinerary: {}", itemDTO);

        // Find itinerary
        TripItinerary itinerary = tripItineraryRepository.findById(itemDTO.getItineraryId())
            .orElseThrow(() -> new IllegalArgumentException("Itinerary không tồn tại"));

        // Validate service exists
        validateServiceExists(itemDTO.getServiceType(), itemDTO.getServiceId());

        // Check if already exists
        ServiceType serviceType = ServiceType.valueOf(itemDTO.getServiceType().toLowerCase());
        boolean exists = tripItineraryItemRepository.existsByItinerary_ItineraryIdAndServiceTypeAndServiceId(
            itemDTO.getItineraryId(), serviceType, itemDTO.getServiceId()
        );

        if (exists) {
            throw new IllegalArgumentException("Dịch vụ này đã có trong hành trình");
        }

        // Get next order
        Integer maxOrder = tripItineraryItemRepository.findMaxOrderByItineraryId(itemDTO.getItineraryId());
        int nextOrder = (maxOrder != null ? maxOrder : 0) + 1;

        // Create item
        TripItineraryItem item = new TripItineraryItem();
        item.setItinerary(itinerary);
        item.setServiceType(serviceType);
        item.setServiceId(itemDTO.getServiceId());
        item.setItemOrder(nextOrder);
        item.setStartTime(itemDTO.getStartTime());
        item.setEndTime(itemDTO.getEndTime());

        TripItineraryItem savedItem = tripItineraryItemRepository.save(item);
        log.info("Itinerary item added successfully");

        return convertItemToDTO(savedItem);
    }

    /**
     * Add item to trip by date (auto-creates itinerary if needed)
     * NO date range validation - services are always available
     */
    public TripItineraryItemDTO addItemToTripByDate(
            Integer tripId, 
            LocalDate date, 
            String serviceType, 
            Integer serviceId,
            String startTime,
            String endTime) {
        log.info("Adding item to trip {} on date {}: {} {}", tripId, date, serviceType, serviceId);

        // Validate required time
        if (startTime == null || startTime.isEmpty() || endTime == null || endTime.isEmpty()) {
            throw new IllegalArgumentException("Thời gian bắt đầu và kết thúc là bắt buộc");
        }

        // Get trip
        Trip trip = tripRepository.findById(tripId)
            .orElseThrow(() -> new IllegalArgumentException("Trip không tồn tại"));

        // Find or create itinerary for this date
        TripItinerary itinerary = tripItineraryRepository
            .findByTrip_TripIdAndItineraryDate(tripId, date)
            .orElseGet(() -> {
                log.info("Creating new itinerary for date: {}", date);
                TripItinerary newItinerary = new TripItinerary();
                newItinerary.setTrip(trip);
                newItinerary.setItineraryDate(date);
                return tripItineraryRepository.save(newItinerary);
            });

        // Validate service exists
        validateServiceExists(serviceType, serviceId);

        // Parse time strings
        java.time.LocalTime startLocalTime = java.time.LocalTime.parse(startTime);
        java.time.LocalTime endLocalTime = java.time.LocalTime.parse(endTime);

        // Validate time range
        if (!endLocalTime.isAfter(startLocalTime)) {
            throw new IllegalArgumentException("Thời gian kết thúc phải sau thời gian bắt đầu");
        }

        // Check if already exists
        ServiceType svcType = ServiceType.valueOf(serviceType.toLowerCase());
        boolean exists = tripItineraryItemRepository.existsByItinerary_ItineraryIdAndServiceTypeAndServiceId(
            itinerary.getItineraryId(), svcType, serviceId
        );

        if (exists) {
            throw new IllegalArgumentException("Dịch vụ này đã có trong hành trình");
        }

        // Get next order
        Integer maxOrder = tripItineraryItemRepository.findMaxOrderByItineraryId(itinerary.getItineraryId());
        int nextOrder = (maxOrder != null ? maxOrder : 0) + 1;

        // Create item
        TripItineraryItem item = new TripItineraryItem();
        item.setItinerary(itinerary);
        item.setServiceType(svcType);
        item.setServiceId(serviceId);
        item.setItemOrder(nextOrder);
        item.setStartTime(startLocalTime);
        item.setEndTime(endLocalTime);

        TripItineraryItem savedItem = tripItineraryItemRepository.save(item);
        log.info("Itinerary item added successfully with ID: {}", savedItem.getItemId());

        return convertItemToDTO(savedItem);
    }

    /**
     * Create or get itinerary for a specific date
     */
    public TripItineraryDTO createOrGetItinerary(Integer tripId, LocalDate date) {
        log.info("Creating or getting itinerary for trip {} on date {}", tripId, date);

        Trip trip = tripRepository.findById(tripId)
            .orElseThrow(() -> new IllegalArgumentException("Trip không tồn tại"));

        // Validate date is within trip range
        if (date.isBefore(trip.getStartDate()) || date.isAfter(trip.getEndDate())) {
            throw new IllegalArgumentException("Ngày không nằm trong khoảng thời gian của chuyến đi");
        }

        // Find or create
        TripItinerary itinerary = tripItineraryRepository
            .findByTrip_TripIdAndItineraryDate(tripId, date)
            .orElseGet(() -> {
                TripItinerary newItinerary = new TripItinerary();
                newItinerary.setTrip(trip);
                newItinerary.setItineraryDate(date);
                return tripItineraryRepository.save(newItinerary);
            });

        return convertItineraryToDTO(itinerary, true);
    }

    /**
     * Remove item from itinerary
     */
    public void removeItineraryItem(Integer itemId) {
        log.info("Removing itinerary item: {}", itemId);

        tripItineraryItemRepository.deleteById(itemId);
        log.info("Itinerary item removed successfully");
    }

    /**
     * Update expired trips (called automatically)
     */
    public void updateExpiredTrips() {
        LocalDate today = LocalDate.now();
        List<Trip> expiredTrips = tripRepository.findExpiredTrips(today);

        if (!expiredTrips.isEmpty()) {
            log.info("Found {} expired trips to update", expiredTrips.size());
            expiredTrips.forEach(trip -> trip.setStatus(TripStatus.completed));
            tripRepository.saveAll(expiredTrips);
        }
    }

    // ===== PRIVATE HELPER METHODS =====

    private TripDTO convertToDTO(Trip trip, boolean includeItineraries) {
        TripDTO dto = TripDTO.builder()
            .tripId(trip.getTripId())
            .userId(trip.getUser().getUserId())
            .userName(trip.getUser().getFullName())
            .tripName(trip.getTripName())
            .startDate(trip.getStartDate())
            .endDate(trip.getEndDate())
            .coverImage(trip.getCoverImage())
            .status(trip.getStatus().name())
            .createdAt(trip.getCreatedAt())
            .updatedAt(trip.getUpdatedAt())
            .totalDays((int) ChronoUnit.DAYS.between(trip.getStartDate(), trip.getEndDate()) + 1)
            .build();

        if (includeItineraries) {
            List<TripItinerary> itineraries = tripItineraryRepository.findByTripIdOrderByDate(trip.getTripId());
            dto.setItineraries(itineraries.stream()
                .map(it -> convertItineraryToDTO(it, true))
                .collect(Collectors.toList()));
            dto.setTotalItineraryItems(itineraries.stream()
                .mapToInt(it -> it.getItems() != null ? it.getItems().size() : 0)
                .sum());
        }

        return dto;
    }

    private TripItineraryDTO convertItineraryToDTO(TripItinerary itinerary, boolean includeItems) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEEE, dd MMM", new Locale("vi"));
        String dayLabel = itinerary.getItineraryDate().format(formatter);

        TripItineraryDTO dto = TripItineraryDTO.builder()
            .itineraryId(itinerary.getItineraryId())
            .tripId(itinerary.getTrip().getTripId())
            .itineraryDate(itinerary.getItineraryDate())
            .notes(itinerary.getNotes())
            .dayLabel(dayLabel)
            .createdAt(itinerary.getCreatedAt())
            .updatedAt(itinerary.getUpdatedAt())
            .build();

        if (includeItems) {
            List<TripItineraryItem> items = tripItineraryItemRepository
                .findByItineraryIdOrderByOrder(itinerary.getItineraryId());
            dto.setItems(items.stream()
                .map(this::convertItemToDTO)
                .collect(Collectors.toList()));
            dto.setTotalItems(items.size());
        }

        return dto;
    }

    private TripItineraryItemDTO convertItemToDTO(TripItineraryItem item) {
        TripItineraryItemDTO dto = TripItineraryItemDTO.builder()
            .itemId(item.getItemId())
            .itineraryId(item.getItinerary().getItineraryId())
            .serviceType(item.getServiceType().name())
            .serviceId(item.getServiceId())
            .itemOrder(item.getItemOrder())
            .startTime(item.getStartTime())
            .endTime(item.getEndTime())
            .createdAt(item.getCreatedAt())
            .build();

        // Add service details
        enrichWithServiceDetails(dto);

        return dto;
    }

    private void enrichWithServiceDetails(TripItineraryItemDTO dto) {
        try {
            ServiceType type = ServiceType.valueOf(dto.getServiceType().toLowerCase());
            switch (type) {
                case hotel -> hotelRepository.findById(dto.getServiceId()).ifPresent(hotel -> {
                    dto.setServiceName(hotel.getTitle());
                    dto.setServiceThumbnail(hotel.getThumbnailUrl());
                    dto.setServiceAddress(hotel.getAddress());
                    dto.setServiceRating(hotel.getStarRating() != null ? hotel.getStarRating().doubleValue() : null);
                    dto.setServicePrice(hotel.getPrice() != null ? hotel.getPrice().doubleValue() : null);
                    dto.setServiceCurrency(hotel.getCurrencyCode());
                });
                case restaurant -> restaurantRepository.findById(dto.getServiceId()).ifPresent(restaurant -> {
                    dto.setServiceName(restaurant.getTitle());
                    dto.setServiceThumbnail(restaurant.getThumbnailUrl());
                    dto.setServiceAddress(restaurant.getAddress());
                    dto.setServiceRating(null); // Rating calculated from reviews
                    dto.setServicePrice(restaurant.getPrice() != null ? restaurant.getPrice().doubleValue() : null);
                    dto.setServiceCurrency(restaurant.getCurrencyCode());
                });
                case attraction -> attractionRepository.findById(dto.getServiceId()).ifPresent(attraction -> {
                    dto.setServiceName(attraction.getTitle());
                    dto.setServiceThumbnail(attraction.getThumbnailUrl());
                    dto.setServiceAddress(attraction.getAddress());
                    dto.setServiceRating(null); // Rating calculated from reviews
                    dto.setServicePrice(attraction.getPrice() != null ? attraction.getPrice().doubleValue() : null);
                    dto.setServiceCurrency(attraction.getCurrencyCode());
                });
                case tour -> tourRepository.findById(dto.getServiceId()).ifPresent(tour -> {
                    dto.setServiceName(tour.getTitle());
                    dto.setServiceThumbnail(tour.getThumbnailUrl());
                    dto.setServiceAddress(tour.getAddress());
                    dto.setServiceRating(null); // Rating calculated from reviews
                    dto.setServicePrice(tour.getPrice() != null ? tour.getPrice().doubleValue() : null);
                    dto.setServiceCurrency(tour.getCurrencyCode());
                });
            }
        } catch (Exception e) {
            log.warn("Failed to enrich service details: {}", e.getMessage());
        }
    }

    private void validateServiceExists(String serviceType, Integer serviceId) {
        try {
            ServiceType type = ServiceType.valueOf(serviceType.toLowerCase());
            boolean exists = switch (type) {
                case hotel -> hotelRepository.existsById(serviceId);
                case restaurant -> restaurantRepository.existsById(serviceId);
                case attraction -> attractionRepository.existsById(serviceId);
                case tour -> tourRepository.existsById(serviceId);
            };

            if (!exists) {
                throw new IllegalArgumentException("Dịch vụ không tồn tại");
            }
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Service type không hợp lệ: " + serviceType);
        }
    }
}
