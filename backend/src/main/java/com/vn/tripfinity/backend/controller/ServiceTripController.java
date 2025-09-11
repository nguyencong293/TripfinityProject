package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.ServiceTripDTO;
import com.vn.tripfinity.backend.sevice.ServiceTripService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/services")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class ServiceTripController {

    private final ServiceTripService serviceTripService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    @GetMapping
    public ResponseEntity<List<ServiceTripDTO>> getAllServiceTrips(
            @RequestHeader("Authorization") String authorization) {
        requireBearer(authorization);
        log.info("GET /api/services - Get all services");
        return ResponseEntity.ok(serviceTripService.getAllServiceTrips());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ServiceTripDTO> getServiceTripById(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        log.info("GET /api/services/{} - Get service by id", id);
        return ResponseEntity.ok(serviceTripService.getServiceTripById(id));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<ServiceTripDTO>> getServiceTripsByProvider(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer providerId) {
        requireBearer(authorization);
        log.info("GET /api/services/provider/{} - Get services by provider", providerId);
        return ResponseEntity.ok(serviceTripService.getServiceTripsByProvider(providerId));
    }

    @PostMapping
    public ResponseEntity<ServiceTripDTO> createServiceTrip(
            @RequestHeader("Authorization") String authorization,
            @Valid @RequestBody ServiceTripDTO dto) {
        requireBearer(authorization);
        log.info("POST /api/services - Create service {}", dto.getTitle());
        ServiceTripDTO created = serviceTripService.createServiceTrip(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ServiceTripDTO> updateServiceTrip(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @Valid @RequestBody ServiceTripDTO dto) {
        requireBearer(authorization);
        log.info("PUT /api/services/{} - Update service", id);
        return ResponseEntity.ok(serviceTripService.updateServiceTrip(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteServiceTrip(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        log.info("DELETE /api/services/{} - Delete service", id);
        serviceTripService.deleteServiceTrip(id);
        return ResponseEntity.noContent().build();
    }
}