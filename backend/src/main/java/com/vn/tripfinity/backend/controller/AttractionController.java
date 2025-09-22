package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.AttractionDTO;
import com.vn.tripfinity.backend.service.AttractionService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/attractions")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class AttractionController {

    private final AttractionService attractionService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    @GetMapping
    public ResponseEntity<List<AttractionDTO>> getAll(@RequestHeader("Authorization") String authorization) {
        requireBearer(authorization);
        return ResponseEntity.ok(attractionService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AttractionDTO> getById(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        return ResponseEntity.ok(attractionService.getById(id));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<AttractionDTO>> getByProvider(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer providerId) {
        requireBearer(authorization);
        return ResponseEntity.ok(attractionService.getByProviderId(providerId));
    }

    @PostMapping
    public ResponseEntity<AttractionDTO> create(@RequestHeader("Authorization") String authorization,
            @Valid @RequestBody AttractionDTO dto) {
        requireBearer(authorization);
        AttractionDTO created = attractionService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AttractionDTO> update(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @Valid @RequestBody AttractionDTO dto) {
        requireBearer(authorization);
        return ResponseEntity.ok(attractionService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        attractionService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
