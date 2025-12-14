package com.vn.tripfinity.backend.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.vn.tripfinity.backend.dto.UserFavoriteDTO;
import com.vn.tripfinity.backend.service.UserFavoriteService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class UserFavoriteController {
    
    private final UserFavoriteService userFavoriteService;
    
    /**
     * Add service to favorites
     * POST /api/favorites
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> addFavorite(@Valid @RequestBody UserFavoriteDTO request) {
        log.info("POST /api/favorites - Adding favorite");
        
        try {
            UserFavoriteDTO favorite = userFavoriteService.addFavorite(
                request.getUserId(), 
                request.getServiceType(), 
                request.getServiceId()
            );
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Đã thêm vào yêu thích");
            response.put("data", favorite);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
    
    /**
     * Remove service from favorites
     * DELETE /api/favorites/{userId}/{serviceType}/{serviceId}
     */
    @DeleteMapping("/{userId}/{serviceType}/{serviceId}")
    public ResponseEntity<Map<String, Object>> removeFavorite(
            @PathVariable Integer userId,
            @PathVariable String serviceType,
            @PathVariable Integer serviceId) {
        log.info("DELETE /api/favorites/{}/{}/{} - Removing favorite", userId, serviceType, serviceId);
        
        try {
            userFavoriteService.removeFavorite(userId, serviceType, serviceId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Đã xóa khỏi yêu thích");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
    
    /**
     * Get all favorites for a user
     * GET /api/favorites/user/{userId}
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getUserFavorites(@PathVariable Integer userId) {
        log.info("GET /api/favorites/user/{} - Getting all favorites", userId);
        
        List<UserFavoriteDTO> favorites = userFavoriteService.getUserFavorites(userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", favorites);
        response.put("total", favorites.size());
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get favorites by service type
     * GET /api/favorites/user/{userId}?type={serviceType}
     */
    @GetMapping("/user/{userId}/type")
    public ResponseEntity<Map<String, Object>> getUserFavoritesByType(
            @PathVariable Integer userId,
            @RequestParam String type) {
        log.info("GET /api/favorites/user/{}/type?type={} - Getting favorites by type", userId, type);
        
        List<UserFavoriteDTO> favorites = userFavoriteService.getUserFavoritesByType(userId, type);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", favorites);
        response.put("total", favorites.size());
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Check if service is favorited
     * GET /api/favorites/check?userId={userId}&serviceType={serviceType}&serviceId={serviceId}
     */
    @GetMapping("/check")
    public ResponseEntity<Map<String, Object>> checkFavorite(
            @RequestParam Integer userId,
            @RequestParam String serviceType,
            @RequestParam Integer serviceId) {
        log.info("GET /api/favorites/check - userId={}, serviceType={}, serviceId={}", userId, serviceType, serviceId);
        
        boolean isFavorite = userFavoriteService.isFavorite(userId, serviceType, serviceId);
        
        log.info("Favorite check result: {}", isFavorite);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("isFavorite", isFavorite);
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get list of favorite service IDs for a specific type
     * GET /api/favorites/user/{userId}/ids?type={serviceType}
     */
    @GetMapping("/user/{userId}/ids")
    public ResponseEntity<Map<String, Object>> getFavoriteServiceIds(
            @PathVariable Integer userId,
            @RequestParam String type) {
        log.info("GET /api/favorites/user/{}/ids?type={} - Getting favorite service IDs", userId, type);
        
        List<Integer> serviceIds = userFavoriteService.getFavoriteServiceIds(userId, type);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", serviceIds);
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get favorite count for a service
     * GET /api/favorites/count?serviceType={serviceType}&serviceId={serviceId}
     */
    @GetMapping("/count")
    public ResponseEntity<Map<String, Object>> getFavoriteCount(
            @RequestParam String serviceType,
            @RequestParam Integer serviceId) {
        log.info("GET /api/favorites/count?serviceType={}&serviceId={}", serviceType, serviceId);
        
        Long count = userFavoriteService.getFavoriteCount(serviceType, serviceId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("count", count);
        
        return ResponseEntity.ok(response);
    }
}
