package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.ProviderDTO;
import com.vn.tripfinity.backend.service.ProviderService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/providers")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class ProviderController {

    private final ProviderService providerService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    @GetMapping
    public ResponseEntity<List<ProviderDTO>> getAllProviders(
            @RequestHeader("Authorization") String authorization) {
        requireBearer(authorization);
        return ResponseEntity.ok(providerService.getAllProviders());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProviderDTO> getProviderById(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        return ResponseEntity.ok(providerService.getProviderById(id));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ProviderDTO>> getProvidersByUser(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer userId) {
        requireBearer(authorization);
        return ResponseEntity.ok(providerService.getProvidersByUserId(userId));
    }

    @PostMapping
    public ResponseEntity<ProviderDTO> createProvider(
            @RequestHeader("Authorization") String authorization,
            @Valid @RequestBody ProviderDTO dto) {
        requireBearer(authorization);
        ProviderDTO created = providerService.createProvider(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProviderDTO> updateProvider(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @Valid @RequestBody ProviderDTO dto) {
        requireBearer(authorization);
        return ResponseEntity.ok(providerService.updateProvider(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProvider(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        providerService.deleteProvider(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{providerId}/logo")
    public ResponseEntity<ProviderDTO> uploadLogo(
            @PathVariable Integer providerId,
            @RequestParam("file") MultipartFile file) {
        log.info("Post /api/providers/{}/logo - Uploading logo", providerId);
        try {
            ProviderDTO updatedProvider = providerService.uploadLogo(providerId, file);
            return ResponseEntity.ok(updatedProvider);
        } catch (Exception e) {
            log.error("Error uploading logo for provider {}: {}", providerId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{providerId}/logo")
    public ResponseEntity<ProviderDTO> deleteLogo(@PathVariable Integer providerId) {
        log.info("Delete /api/providers/{}/logo - Deleting logo", providerId);
        try {
            ProviderDTO updatedProvider = providerService.deleteLogo(providerId);
            return ResponseEntity.ok(updatedProvider);
        } catch (Exception e) {
            log.error("Error deleting logo for provider {}: {}", providerId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}