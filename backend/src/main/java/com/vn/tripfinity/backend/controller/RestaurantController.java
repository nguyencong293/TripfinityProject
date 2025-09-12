package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.RestaurantDTO;
import com.vn.tripfinity.backend.sevice.RestaurantService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/restaurants")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class RestaurantController {

    private final RestaurantService restaurantService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    @GetMapping
    public ResponseEntity<List<RestaurantDTO>> getAllRestaurants(@RequestHeader("Authorization") String authorization) {
        requireBearer(authorization);
        return ResponseEntity.ok(restaurantService.getAllRestaurants());
    }

    @GetMapping("/{id}")
    public ResponseEntity<RestaurantDTO> getRestaurantById(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        return ResponseEntity.ok(restaurantService.getRestaurantById(id));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<RestaurantDTO>> getRestaurantsByProvider(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer providerId) {
        requireBearer(authorization);
        return ResponseEntity.ok(restaurantService.getRestaurantsByProviderId(providerId));
    }

    @PostMapping
    public ResponseEntity<RestaurantDTO> createRestaurant(@RequestHeader("Authorization") String authorization,
            @Valid @RequestBody RestaurantDTO dto) {
        requireBearer(authorization);
        RestaurantDTO created = restaurantService.createRestaurant(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<RestaurantDTO> updateRestaurant(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @Valid @RequestBody RestaurantDTO dto) {
        requireBearer(authorization);
        return ResponseEntity.ok(restaurantService.updateRestaurant(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRestaurant(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        restaurantService.deleteRestaurant(id);
        return ResponseEntity.noContent().build();
    }
}
