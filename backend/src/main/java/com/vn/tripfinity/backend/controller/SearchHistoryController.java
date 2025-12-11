package com.vn.tripfinity.backend.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.vn.tripfinity.backend.dto.SearchHistoryDTO;
import com.vn.tripfinity.backend.repository.UserRepository;
import com.vn.tripfinity.backend.service.SearchHistoryService;
import com.vn.tripfinity.backend.service.auth.token.JwtTokenProvider;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/search-history")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class SearchHistoryController {

    private final SearchHistoryService searchHistoryService;
    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;

    /**
     * Extract user ID from JWT token
     */
    private Integer extractUserId(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
        String token = authorization.substring(7);
        try {
            String email = jwtTokenProvider.getUsernameFromToken(token);
            return userRepository.findByEmail(email)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User not found"))
                    .getUserId();
        } catch (Exception e) {
            log.error("Failed to extract user ID from token", e);
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token");
        }
    }

    /**
     * POST /api/search-history/search - Save a search query
     * Request body: { "searchQuery": "...", "searchType": "hotel|restaurant|tour|attraction|general" }
     */
    @PostMapping("/search")
    public ResponseEntity<SearchHistoryDTO> saveSearchQuery(
            @RequestHeader("Authorization") String authorization,
            @RequestBody Map<String, String> request) {

        log.info("POST /api/search-history/search - Saving search query");
        Integer userId = extractUserId(authorization);
        String searchQuery = request.get("searchQuery");
        String searchType = request.getOrDefault("searchType", "general");

        if (searchQuery == null || searchQuery.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "searchQuery is required");
        }

        log.debug("User {} searching: '{}' (type: {})", userId, searchQuery, searchType);
        SearchHistoryDTO result = searchHistoryService.saveSearchQuery(userId, searchQuery.trim(), searchType);
        log.info("Search query saved successfully for user {}", userId);
        return ResponseEntity.ok(result);
    }

    /**
     * POST /api/search-history/click - Save a clicked/viewed item
     * Request body: {
     *   "searchQuery": "...",
     *   "searchType": "...",
     *   "itemType": "hotel|restaurant|tour|attraction|area",
     *   "itemId": 123,
     *   "itemTitle": "...",
     *   "itemLocation": "...",
     *   "itemThumbnailUrl": "..."
     * }
     */
    @PostMapping("/click")
    public ResponseEntity<SearchHistoryDTO> saveClickedItem(
            @RequestHeader("Authorization") String authorization,
            @RequestBody Map<String, Object> request) {

        log.info("POST /api/search-history/click - Saving clicked item");
        Integer userId = extractUserId(authorization);

        String searchQuery = (String) request.get("searchQuery");
        String searchType = (String) request.getOrDefault("searchType", "general");
        String itemType = (String) request.get("itemType");
        Integer itemId = parseInteger(request.get("itemId"));
        String itemTitle = (String) request.get("itemTitle");
        String itemLocation = (String) request.get("itemLocation");
        String itemThumbnailUrl = (String) request.get("itemThumbnailUrl");

        if (searchQuery == null || searchQuery.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "searchQuery is required");
        }
        if (itemType == null || itemType.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "itemType is required");
        }

        log.debug("User {} clicked: '{}' (type: {}, id: {})", userId, itemTitle, itemType, itemId);
        SearchHistoryDTO result = searchHistoryService.saveClickedItem(
                userId, searchQuery.trim(), searchType, itemType, itemId,
                itemTitle, itemLocation, itemThumbnailUrl);
        log.info("Clicked item saved successfully for user {}", userId);
        return ResponseEntity.ok(result);
    }

    /**
     * GET /api/search-history/recent - Get recent search history
     * Query params: limit (optional, default 50)
     */
    @GetMapping("/recent")
    public ResponseEntity<List<SearchHistoryDTO>> getRecentSearchHistory(
            @RequestHeader("Authorization") String authorization,
            @RequestParam(value = "limit", required = false, defaultValue = "50") Integer limit) {

        Integer userId = extractUserId(authorization);
        List<SearchHistoryDTO> history = searchHistoryService.getRecentSearchHistory(userId, limit);
        return ResponseEntity.ok(history);
    }

    /**
     * GET /api/search-history/viewed - Get recently viewed items
     * Query params: limit (optional, default 10)
     */
    @GetMapping("/viewed")
    public ResponseEntity<List<SearchHistoryDTO>> getRecentViewedItems(
            @RequestHeader("Authorization") String authorization,
            @RequestParam(value = "limit", required = false, defaultValue = "10") Integer limit) {

        Integer userId = extractUserId(authorization);
        List<SearchHistoryDTO> viewedItems = searchHistoryService.getRecentViewedItems(userId, limit);
        return ResponseEntity.ok(viewedItems);
    }

    /**
     * GET /api/search-history/suggestions - Get search query suggestions
     * Query params: limit (optional, default 5)
     */
    @GetMapping("/suggestions")
    public ResponseEntity<List<String>> getSearchSuggestions(
            @RequestHeader("Authorization") String authorization,
            @RequestParam(value = "limit", required = false, defaultValue = "5") Integer limit) {

        Integer userId = extractUserId(authorization);
        List<String> suggestions = searchHistoryService.getSearchSuggestions(userId, limit);
        return ResponseEntity.ok(suggestions);
    }

    /**
     * DELETE /api/search-history/clear - Clear all search history
     */
    @DeleteMapping("/clear")
    public ResponseEntity<Map<String, String>> clearSearchHistory(
            @RequestHeader("Authorization") String authorization) {

        Integer userId = extractUserId(authorization);
        searchHistoryService.clearSearchHistory(userId);

        Map<String, String> response = new HashMap<>();
        response.put("message", "Search history cleared successfully");
        return ResponseEntity.ok(response);
    }

    // Helper methods
    private Integer parseInteger(Object value) {
        if (value == null)
            return null;
        if (value instanceof Integer i)
            return i;
        if (value instanceof Number n)
            return n.intValue();
        try {
            return Integer.valueOf(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
