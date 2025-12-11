package com.vn.tripfinity.backend.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SearchHistoryDTO {

    private Integer searchHistoryId;
    private Integer userId;
    private String searchQuery;
    private String searchType;
    private String itemType;
    private Integer itemId;
    private String itemTitle;
    private String itemLocation;
    private String itemThumbnailUrl;
    private LocalDateTime searchTimestamp;
    private Boolean clicked;
    private LocalDateTime clickTimestamp;
}
