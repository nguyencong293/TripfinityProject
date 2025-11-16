package com.vn.tripfinity.backend.controller;

import java.util.Collections;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/hotel-price-alerts")
@CrossOrigin(origins = "*")
public class HotelPriceAlertController {

    @GetMapping("/provider/{providerId}/active")
    public ResponseEntity<List<Object>> getActivePriceAlerts(@PathVariable Integer providerId) {
        log.info("GET /api/hotel-price-alerts/provider/{}/active - Getting active price alerts", providerId);
        // TODO: Implement this feature later
        // For now, return empty list to avoid 404 error
        return ResponseEntity.ok(Collections.emptyList());
    }
}
