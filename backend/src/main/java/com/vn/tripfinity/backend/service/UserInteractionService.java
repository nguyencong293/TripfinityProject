package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.model.UserInteraction;
import com.vn.tripfinity.backend.repository.UserInteractionRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserInteractionService {

    private final UserInteractionRepository interactionRepository;
    private final UserRepository userRepository;

    /**
     * Record VIEW action when user views a service detail page
     */
    public void recordView(Integer userId, Integer itemId, UserInteraction.ItemType itemType) {
        log.info("📊 Recording VIEW - userId: {}, itemId: {}, itemType: {}", userId, itemId, itemType);
        
        UserInteraction interaction = createInteraction(
            userId, itemId, itemType, UserInteraction.ActionType.view, 2
        );
        
        interactionRepository.save(interaction);
        log.debug("✅ Saved VIEW interaction ID: {}", interaction.getInteractionId());
    }

    /**
     * Record CLICK action when user clicks on a service card
     */
    public void recordClick(Integer userId, Integer itemId, UserInteraction.ItemType itemType) {
        log.info("📊 Recording CLICK - userId: {}, itemId: {}, itemType: {}", userId, itemId, itemType);
        
        UserInteraction interaction = createInteraction(
            userId, itemId, itemType, UserInteraction.ActionType.click, 3
        );
        
        interactionRepository.save(interaction);
        log.debug("✅ Saved CLICK interaction ID: {}", interaction.getInteractionId());
    }

    /**
     * Record FAVORITE action when user adds/removes favorite
     */
    public void recordFavorite(Integer userId, Integer itemId, UserInteraction.ItemType itemType) {
        log.info("📊 Recording FAVORITE - userId: {}, itemId: {}, itemType: {}", userId, itemId, itemType);
        
        UserInteraction interaction = createInteraction(
            userId, itemId, itemType, UserInteraction.ActionType.favorite, 4
        );
        
        interactionRepository.save(interaction);
        log.debug("✅ Saved FAVORITE interaction ID: {}", interaction.getInteractionId());
    }

    /**
     * Record BOOK action when user completes a booking
     */
    public void recordBook(Integer userId, Integer itemId, UserInteraction.ItemType itemType) {
        log.info("📊 Recording BOOK - userId: {}, itemId: {}, itemType: {}", userId, itemId, itemType);
        
        UserInteraction interaction = createInteraction(
            userId, itemId, itemType, UserInteraction.ActionType.book, 5
        );
        
        interactionRepository.save(interaction);
        log.debug("✅ Saved BOOK interaction ID: {}", interaction.getInteractionId());
    }

    /**
     * Record SEARCH action when user performs a search
     */
    public void recordSearch(Integer userId, UserInteraction.ItemType itemType) {
        log.info("📊 Recording SEARCH - userId: {}, itemType: {}", userId, itemType);
        
        UserInteraction interaction = createInteraction(
            userId, 0, itemType, UserInteraction.ActionType.search, 1
        );
        
        interactionRepository.save(interaction);
        log.debug("✅ Saved SEARCH interaction ID: {}", interaction.getInteractionId());
    }

    /**
     * Get recent interactions by user
     */
    public List<UserInteraction> getRecentInteractionsByUser(Integer userId, int limit) {
        log.debug("Fetching recent {} interactions for userId: {}", limit, userId);
        List<UserInteraction> interactions = interactionRepository.findRecentInteractionsByUserId(userId);
        return interactions.stream().limit(limit).toList();
    }

    /**
     * Get interactions for AI training
     */
    public List<UserInteraction> getInteractionsForAITraining() {
        log.info("📦 Fetching interactions for AI training");
        List<UserInteraction.ActionType> actionTypes = List.of(
            UserInteraction.ActionType.view,
            UserInteraction.ActionType.click,
            UserInteraction.ActionType.favorite,
            UserInteraction.ActionType.book
        );
        return interactionRepository.findForAITraining(actionTypes);
    }

    /**
     * Get user interaction count
     */
    public Long getUserInteractionCount(Integer userId) {
        return interactionRepository.countByUser_UserId(userId);
    }

    /**
     * Helper method to create UserInteraction entity
     */
    private UserInteraction createInteraction(
            Integer userId, 
            Integer itemId, 
            UserInteraction.ItemType itemType,
            UserInteraction.ActionType actionType,
            Integer actionWeight
    ) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        return UserInteraction.builder()
            .user(user)
            .itemId(itemId)
            .itemType(itemType)
            .actionType(actionType)
            .actionWeight(actionWeight)
            .interactionTimestamp(LocalDateTime.now())
            .build();
    }
}
