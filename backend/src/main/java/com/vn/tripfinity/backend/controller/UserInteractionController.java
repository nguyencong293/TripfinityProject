package com.vn.tripfinity.backend.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.vn.tripfinity.backend.model.UserInteraction;
import com.vn.tripfinity.backend.service.UserInteractionService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/user-interactions")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class UserInteractionController {

    private final UserInteractionService interactionService;

    /**
     * Record VIEW action
     * POST /api/user-interactions/view
     */
    @PostMapping("/view")
    public ResponseEntity<Map<String, String>> recordView(@RequestBody Map<String, Object> request) {
        try {
            Integer userId = (Integer) request.get("userId");
            Integer itemId = (Integer) request.get("itemId");
            String itemTypeStr = (String) request.get("itemType");

            UserInteraction.ItemType itemType = UserInteraction.ItemType.valueOf(itemTypeStr);
            
            interactionService.recordView(userId, itemId, itemType);
            
            log.info("✅ Recorded VIEW - userId: {}, itemId: {}, itemType: {}", userId, itemId, itemType);
            return ResponseEntity.ok(Map.of("message", "View recorded successfully"));
        } catch (Exception e) {
            log.error("❌ Error recording VIEW: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Record CLICK action
     * POST /api/user-interactions/click
     */
    @PostMapping("/click")
    public ResponseEntity<Map<String, String>> recordClick(@RequestBody Map<String, Object> request) {
        try {
            Integer userId = (Integer) request.get("userId");
            Integer itemId = (Integer) request.get("itemId");
            String itemTypeStr = (String) request.get("itemType");

            UserInteraction.ItemType itemType = UserInteraction.ItemType.valueOf(itemTypeStr);
            
            interactionService.recordClick(userId, itemId, itemType);
            
            log.info("✅ Recorded CLICK - userId: {}, itemId: {}, itemType: {}", userId, itemId, itemType);
            return ResponseEntity.ok(Map.of("message", "Click recorded successfully"));
        } catch (Exception e) {
            log.error("❌ Error recording CLICK: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Record FAVORITE action
     * POST /api/user-interactions/favorite
     */
    @PostMapping("/favorite")
    public ResponseEntity<Map<String, String>> recordFavorite(@RequestBody Map<String, Object> request) {
        try {
            Integer userId = (Integer) request.get("userId");
            Integer itemId = (Integer) request.get("itemId");
            String itemTypeStr = (String) request.get("itemType");

            UserInteraction.ItemType itemType = UserInteraction.ItemType.valueOf(itemTypeStr);
            
            interactionService.recordFavorite(userId, itemId, itemType);
            
            log.info("✅ Recorded FAVORITE - userId: {}, itemId: {}, itemType: {}", userId, itemId, itemType);
            return ResponseEntity.ok(Map.of("message", "Favorite recorded successfully"));
        } catch (Exception e) {
            log.error("❌ Error recording FAVORITE: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Record BOOK action
     * POST /api/user-interactions/book
     */
    @PostMapping("/book")
    public ResponseEntity<Map<String, String>> recordBook(@RequestBody Map<String, Object> request) {
        try {
            Integer userId = (Integer) request.get("userId");
            Integer itemId = (Integer) request.get("itemId");
            String itemTypeStr = (String) request.get("itemType");

            UserInteraction.ItemType itemType = UserInteraction.ItemType.valueOf(itemTypeStr);
            
            interactionService.recordBook(userId, itemId, itemType);
            
            log.info("✅ Recorded BOOK - userId: {}, itemId: {}, itemType: {}", userId, itemId, itemType);
            return ResponseEntity.ok(Map.of("message", "Book recorded successfully"));
        } catch (Exception e) {
            log.error("❌ Error recording BOOK: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Record SEARCH action
     * POST /api/user-interactions/search
     */
    @PostMapping("/search")
    public ResponseEntity<Map<String, String>> recordSearch(@RequestBody Map<String, Object> request) {
        try {
            Integer userId = (Integer) request.get("userId");
            String itemTypeStr = (String) request.get("itemType");

            UserInteraction.ItemType itemType = UserInteraction.ItemType.valueOf(itemTypeStr);
            interactionService.recordSearch(userId, itemType);
            
            log.info("✅ Recorded SEARCH - userId: {}, itemType: {}", userId, itemType);
            return ResponseEntity.ok(Map.of("message", "Search recorded successfully"));
        } catch (Exception e) {
            log.error("❌ Error recording SEARCH: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Get recent interactions by user
     * GET /api/user-interactions/user/{userId}/recent
     */
    @GetMapping("/user/{userId}/recent")
    public ResponseEntity<List<UserInteraction>> getRecentInteractions(
            @PathVariable Integer userId,
            @RequestParam(defaultValue = "20") int limit) {
        try {
            List<UserInteraction> interactions = interactionService.getRecentInteractionsByUser(userId, limit);
            return ResponseEntity.ok(interactions);
        } catch (Exception e) {
            log.error("❌ Error fetching recent interactions for userId {}: {}", userId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get user interaction count
     * GET /api/user-interactions/user/{userId}/count
     */
    @GetMapping("/user/{userId}/count")
    public ResponseEntity<Map<String, Long>> getUserInteractionCount(@PathVariable Integer userId) {
        try {
            Long count = interactionService.getUserInteractionCount(userId);
            return ResponseEntity.ok(Map.of("count", count));
        } catch (Exception e) {
            log.error("❌ Error fetching interaction count for userId {}: {}", userId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get interactions for AI training (Admin only)
     * GET /api/user-interactions/ai-training
     */
    @GetMapping("/ai-training")
    public ResponseEntity<List<UserInteraction>> getInteractionsForAITraining() {
        try {
            List<UserInteraction> interactions = interactionService.getInteractionsForAITraining();
            log.info("📦 Exported {} interactions for AI training", interactions.size());
            return ResponseEntity.ok(interactions);
        } catch (Exception e) {
            log.error("❌ Error fetching AI training data: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
