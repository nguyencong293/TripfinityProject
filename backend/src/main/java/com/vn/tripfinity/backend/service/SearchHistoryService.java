package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.SearchHistoryDTO;
import com.vn.tripfinity.backend.model.SearchHistory;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.SearchHistoryRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class SearchHistoryService {

    private final SearchHistoryRepository searchHistoryRepository;
    private final UserRepository userRepository;

    /**
     * Save a search query (without item details)
     */
    @Transactional
    public SearchHistoryDTO saveSearchQuery(Integer userId, String searchQuery, String searchType) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        SearchHistory.SearchType type = parseSearchType(searchType);

        SearchHistory searchHistory = SearchHistory.builder()
                .user(user)
                .searchQuery(searchQuery)
                .searchType(type)
                .clicked(false)
                .build();

        SearchHistory saved = searchHistoryRepository.save(searchHistory);
        log.info("Saved search query for user {}: {}", userId, searchQuery);

        return toDTO(saved);
    }

    /**
     * Save a clicked item (viewed item in search results)
     */
    @Transactional
    public SearchHistoryDTO saveClickedItem(Integer userId, String searchQuery, String searchType,
            String itemType, Integer itemId, String itemTitle, String itemLocation,
            String itemThumbnailUrl) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        SearchHistory.SearchType sType = parseSearchType(searchType);
        SearchHistory.ItemType iType = parseItemType(itemType);

        SearchHistory searchHistory = SearchHistory.builder()
                .user(user)
                .searchQuery(searchQuery)
                .searchType(sType)
                .itemType(iType)
                .itemId(itemId)
                .itemTitle(itemTitle)
                .itemLocation(itemLocation)
                .itemThumbnailUrl(itemThumbnailUrl)
                .clicked(true)
                .clickTimestamp(LocalDateTime.now())
                .build();

        SearchHistory saved = searchHistoryRepository.save(searchHistory);
        log.info("Saved clicked item for user {}: {} ({})", userId, itemTitle, itemType);

        return toDTO(saved);
    }

    /**
     * Get recent search history for a user (limit to recent N entries)
     */
    public List<SearchHistoryDTO> getRecentSearchHistory(Integer userId, Integer limit) {
        List<SearchHistory> history = searchHistoryRepository
                .findByUserIdOrderBySearchTimestampDesc(userId);

        if (limit != null && limit > 0 && history.size() > limit) {
            history = history.subList(0, limit);
        }

        return history.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get recent clicked items (viewed history) for a user
     */
    public List<SearchHistoryDTO> getRecentViewedItems(Integer userId, Integer limit) {
        List<SearchHistory> viewedItems = searchHistoryRepository
                .findClickedByUserIdOrderByClickTimestampDesc(userId);

        if (limit != null && limit > 0 && viewedItems.size() > limit) {
            viewedItems = viewedItems.subList(0, limit);
        }

        return viewedItems.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get unique search queries for suggestions
     */
    public List<String> getSearchSuggestions(Integer userId, Integer limit) {
        List<String> queries = searchHistoryRepository.findDistinctSearchQueriesByUserId(userId);

        if (limit != null && limit > 0 && queries.size() > limit) {
            queries = queries.subList(0, limit);
        }

        return queries;
    }

    /**
     * Clear all search history for a user
     */
    @Transactional
    public void clearSearchHistory(Integer userId) {
        searchHistoryRepository.deleteByUser_UserId(userId);
        log.info("Cleared search history for user {}", userId);
    }

    /**
     * Convert entity to DTO
     */
    private SearchHistoryDTO toDTO(SearchHistory entity) {
        return SearchHistoryDTO.builder()
                .searchHistoryId(entity.getSearchHistoryId())
                .userId(entity.getUser() != null ? entity.getUser().getUserId() : null)
                .searchQuery(entity.getSearchQuery())
                .searchType(entity.getSearchType() != null ? entity.getSearchType().name() : null)
                .itemType(entity.getItemType() != null ? entity.getItemType().name() : null)
                .itemId(entity.getItemId())
                .itemTitle(entity.getItemTitle())
                .itemLocation(entity.getItemLocation())
                .itemThumbnailUrl(entity.getItemThumbnailUrl())
                .searchTimestamp(entity.getSearchTimestamp())
                .clicked(entity.getClicked())
                .clickTimestamp(entity.getClickTimestamp())
                .build();
    }

    private SearchHistory.SearchType parseSearchType(String type) {
        if (type == null || type.isBlank()) {
            return SearchHistory.SearchType.general;
        }
        try {
            return SearchHistory.SearchType.valueOf(type.toLowerCase());
        } catch (IllegalArgumentException e) {
            log.warn("Invalid search type: {}, defaulting to general", type);
            return SearchHistory.SearchType.general;
        }
    }

    private SearchHistory.ItemType parseItemType(String type) {
        if (type == null || type.isBlank()) {
            return null;
        }
        try {
            return SearchHistory.ItemType.valueOf(type.toLowerCase());
        } catch (IllegalArgumentException e) {
            log.warn("Invalid item type: {}", type);
            return null;
        }
    }
}
