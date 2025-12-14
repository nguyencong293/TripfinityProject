package com.vn.tripfinity.backend.controller;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.vn.tripfinity.backend.dto.TripDTO;
import com.vn.tripfinity.backend.dto.TripItineraryDTO;
import com.vn.tripfinity.backend.dto.TripItineraryItemDTO;
import com.vn.tripfinity.backend.service.TripService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/trips")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class TripController {

    private final TripService tripService;

    /**
     * Create a new trip
     * POST /api/trips
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createTrip(@Valid @RequestBody TripDTO tripDTO) {
        log.info("POST /api/trips - Creating trip");

        try {
            TripDTO createdTrip = tripService.createTrip(tripDTO);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Tạo chuyến đi thành công");
            response.put("data", createdTrip);

            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());

            return ResponseEntity.badRequest().body(errorResponse);
        } catch (Exception e) {
            log.error("Error creating trip", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Lỗi khi tạo chuyến đi");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Get all active trips for a user
     * GET /api/trips/user/{userId}
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getUserTrips(@PathVariable Integer userId) {
        log.info("GET /api/trips/user/{} - Getting user trips", userId);

        try {
            List<TripDTO> trips = tripService.getUserTrips(userId);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", trips);
            response.put("count", trips.size());

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting user trips", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Lỗi khi lấy danh sách chuyến đi");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Get completed trips for a user
     * GET /api/trips/user/{userId}/completed
     */
    @GetMapping("/user/{userId}/completed")
    public ResponseEntity<Map<String, Object>> getUserCompletedTrips(@PathVariable Integer userId) {
        log.info("GET /api/trips/user/{}/completed - Getting completed trips", userId);

        try {
            List<TripDTO> trips = tripService.getUserCompletedTrips(userId);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", trips);
            response.put("count", trips.size());

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting completed trips", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Lỗi khi lấy danh sách chuyến đi đã hoàn thành");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Get trip detail with itineraries
     * GET /api/trips/{tripId}
     */
    @GetMapping("/{tripId}")
    public ResponseEntity<Map<String, Object>> getTripDetail(@PathVariable Integer tripId) {
        log.info("GET /api/trips/{} - Getting trip detail", tripId);

        try {
            TripDTO trip = tripService.getTripDetail(tripId);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", trip);

            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());

            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
        } catch (Exception e) {
            log.error("Error getting trip detail", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Lỗi khi lấy thông tin chuyến đi");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Update trip dates
     * PUT /api/trips/{tripId}/dates
     */
    @PutMapping("/{tripId}/dates")
    public ResponseEntity<Map<String, Object>> updateTripDates(
            @PathVariable Integer tripId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        log.info("PUT /api/trips/{}/dates - Updating trip dates", tripId);

        try {
            TripDTO updatedTrip = tripService.updateTripDates(tripId, startDate, endDate);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Cập nhật thời gian thành công");
            response.put("data", updatedTrip);

            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());

            return ResponseEntity.badRequest().body(errorResponse);
        } catch (Exception e) {
            log.error("Error updating trip dates", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Lỗi khi cập nhật thời gian");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Delete/Cancel a trip
     * DELETE /api/trips/{tripId}
     */
    @DeleteMapping("/{tripId}")
    public ResponseEntity<Map<String, Object>> deleteTrip(@PathVariable Integer tripId) {
        log.info("DELETE /api/trips/{} - Deleting trip", tripId);

        try {
            tripService.deleteTrip(tripId);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Xóa chuyến đi thành công");

            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());

            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
        } catch (Exception e) {
            log.error("Error deleting trip", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Lỗi khi xóa chuyến đi");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Create or get itinerary for a specific date
     * POST /api/trips/{tripId}/itineraries
     */
    @PostMapping("/{tripId}/itineraries")
    public ResponseEntity<Map<String, Object>> createOrGetItinerary(
            @PathVariable Integer tripId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        log.info("POST /api/trips/{}/itineraries - Creating/getting itinerary for date {}", tripId, date);

        try {
            TripItineraryDTO itinerary = tripService.createOrGetItinerary(tripId, date);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", itinerary);

            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());

            return ResponseEntity.badRequest().body(errorResponse);
        } catch (Exception e) {
            log.error("Error creating/getting itinerary", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Lỗi khi tạo hành trình");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Add item to itinerary
     * POST /api/trips/itineraries/items
     */
    @PostMapping("/itineraries/items")
    public ResponseEntity<Map<String, Object>> addItineraryItem(
            @Valid @RequestBody TripItineraryItemDTO itemDTO) {
        log.info("POST /api/trips/itineraries/items - Adding item to itinerary");

        try {
            TripItineraryItemDTO createdItem = tripService.addItineraryItem(itemDTO);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Thêm dịch vụ vào hành trình thành công");
            response.put("data", createdItem);

            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());

            return ResponseEntity.badRequest().body(errorResponse);
        } catch (Exception e) {
            log.error("Error adding itinerary item", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Lỗi khi thêm dịch vụ vào hành trình");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Add item to trip by date (auto-creates itinerary if needed)
     * POST /api/trips/{tripId}/dates/{date}/items
     */
    @PostMapping("/{tripId}/dates/{date}/items")
    public ResponseEntity<Map<String, Object>> addItemByDate(
            @PathVariable Integer tripId,
            @PathVariable String date,
            @RequestBody Map<String, Object> requestBody) {
        log.info("POST /api/trips/{}/dates/{}/items - Adding item with auto-itinerary", tripId, date);

        try {
            LocalDate localDate = LocalDate.parse(date);
            String serviceType = (String) requestBody.get("serviceType");
            Integer serviceId = (Integer) requestBody.get("serviceId");
            String startTime = (String) requestBody.get("startTime");
            String endTime = (String) requestBody.get("endTime");

            TripItineraryItemDTO createdItem = tripService.addItemToTripByDate(
                tripId, localDate, serviceType, serviceId, startTime, endTime
            );

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Thêm dịch vụ vào hành trình thành công");
            response.put("data", createdItem);

            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());

            return ResponseEntity.badRequest().body(errorResponse);
        } catch (Exception e) {
            log.error("Error adding item by date", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Lỗi khi thêm dịch vụ vào hành trình");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Remove item from itinerary
     * DELETE /api/trips/itineraries/items/{itemId}
     */
    @DeleteMapping("/itineraries/items/{itemId}")
    public ResponseEntity<Map<String, Object>> removeItineraryItem(@PathVariable Integer itemId) {
        log.info("DELETE /api/trips/itineraries/items/{} - Removing item", itemId);

        try {
            tripService.removeItineraryItem(itemId);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Xóa dịch vụ khỏi hành trình thành công");

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error removing itinerary item", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Lỗi khi xóa dịch vụ");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Update itinerary notes
     * PATCH /api/trips/itineraries/{itineraryId}
     */
    @PatchMapping("/itineraries/{itineraryId}")
    public ResponseEntity<Map<String, Object>> updateItineraryNotes(
            @PathVariable Integer itineraryId,
            @RequestBody Map<String, Object> requestBody) {
        log.info("PATCH /api/trips/itineraries/{} - Updating notes", itineraryId);

        try {
            String notes = (String) requestBody.get("notes");
            TripItineraryDTO updated = tripService.updateItineraryNotes(itineraryId, notes);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Cập nhật ghi chú thành công");
            response.put("data", updated);

            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        } catch (Exception e) {
            log.error("Error updating itinerary notes", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Lỗi khi cập nhật ghi chú");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}
