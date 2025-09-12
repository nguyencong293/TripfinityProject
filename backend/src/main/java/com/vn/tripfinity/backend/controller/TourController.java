package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.TourDTO;
import com.vn.tripfinity.backend.sevice.TourService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/tours")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class TourController {

    private final TourService tourService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    @GetMapping
    public ResponseEntity<List<TourDTO>> getAllTours(@RequestHeader("Authorization") String authorization) {
        requireBearer(authorization);
        return ResponseEntity.ok(tourService.getAllTours());
    }

    @GetMapping("/{id}")
    public ResponseEntity<TourDTO> getTourById(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        return ResponseEntity.ok(tourService.getTourById(id));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<TourDTO>> getToursByProvider(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer providerId) {
        requireBearer(authorization);
        return ResponseEntity.ok(tourService.getToursByProviderId(providerId));
    }

    @PostMapping
    public ResponseEntity<TourDTO> createTour(@RequestHeader("Authorization") String authorization,
            @Valid @RequestBody TourDTO dto) {
        requireBearer(authorization);
        TourDTO created = tourService.createTour(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TourDTO> updateTour(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @Valid @RequestBody TourDTO dto) {
        requireBearer(authorization);
        return ResponseEntity.ok(tourService.updateTour(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTour(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        tourService.deleteTour(id);
        return ResponseEntity.noContent().build();
    }
}
