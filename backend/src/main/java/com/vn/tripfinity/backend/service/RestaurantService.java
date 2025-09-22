package com.vn.tripfinity.backend.sevice;

import com.vn.tripfinity.backend.dto.RestaurantDTO;
import com.vn.tripfinity.backend.dto.RestaurantReviewDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.Restaurant;
import com.vn.tripfinity.backend.model.RestaurantReview;
import com.vn.tripfinity.backend.model.RestaurantReviewAspects;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.model.ReviewReply;
import com.vn.tripfinity.backend.model.Area;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.RestaurantRepository;
import com.vn.tripfinity.backend.repository.RestaurantReviewRepository;
import com.vn.tripfinity.backend.repository.RestaurantReviewAspectsRepository;
import com.vn.tripfinity.backend.repository.UserRepository;
import com.vn.tripfinity.backend.repository.ReviewReplyRepository;
import com.vn.tripfinity.backend.repository.AreaRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;
    private final ProviderRepository providerRepository;
    private final RestaurantReviewRepository restaurantReviewRepository;
    private final RestaurantReviewAspectsRepository restaurantReviewAspectsRepository;
    private final UserRepository userRepository;
    private final ReviewReplyRepository reviewReplyRepository;
    private final AreaRepository areaRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public List<RestaurantDTO> getAllRestaurants() {
        return restaurantRepository.findAll().stream().map(this::toDTO).collect(Collectors.toList());
    }

    public RestaurantDTO getRestaurantById(Integer restaurantId) {
        Restaurant r = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Restaurant id: " + restaurantId));
        return toDTO(r);
    }

    public List<RestaurantDTO> getRestaurantsByProviderId(Integer providerId) {
        return restaurantRepository.findByProvider_ProviderId(providerId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public RestaurantDTO createRestaurant(RestaurantDTO dto) {
        Provider provider = providerRepository.findById(dto.getProviderId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
        Area area = areaRepository.findById(dto.getAreaId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + dto.getAreaId()));

        Restaurant entity = Restaurant.builder()
                .restaurantId(null)
                .provider(provider)
                .area(area)
                .title(dto.getTitle())
                .serviceDescription(dto.getServiceDescription())
                .location(dto.getLocation())
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .price(dto.getPrice())
                .currencyCode(dto.getCurrencyCode())
                .capacity(dto.getCapacity())
                .minParticipants(dto.getMinParticipants())
                .maxParticipants(dto.getMaxParticipants())
                .thumbnailUrl(dto.getThumbnailUrl())
                .imageUrls(joinList(dto.getImageUrls()))
                .ratingAverage(dto.getRatingAverage() != null ? dto.getRatingAverage() : new BigDecimal("0.00"))
                .badges(joinList(dto.getBadges()))
                .restaurantStatus(dto.getRestaurantStatus() != null
                        ? Restaurant.RestaurantStatus.valueOf(dto.getRestaurantStatus())
                        : Restaurant.RestaurantStatus.published)
                .priceLevel(dto.getPriceLevel() != null ? Restaurant.PriceLevel.valueOf(dto.getPriceLevel()) : null)
                .phone(dto.getPhone())
                .website(dto.getWebsite())
                .address(dto.getAddress())
                .cuisinesJson(writeJson(dto.getCuisines()))
                .servicesJson(writeJson(dto.getServices()))
                .dietsJson(writeJson(dto.getDiets()))
                .openingHoursJson(writeJson(dto.getOpeningHours()))
                .build();

        Restaurant saved = restaurantRepository.save(entity);
        log.info("Tạo Restaurant ID: {}", saved.getRestaurantId());
        return toDTO(saved);
    }

    public RestaurantDTO updateRestaurant(Integer restaurantId, RestaurantDTO dto) {
        Restaurant existing = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Restaurant id: " + restaurantId));

        if (dto.getProviderId() != null &&
                (existing.getProvider() == null
                        || !existing.getProvider().getProviderId().equals(dto.getProviderId()))) {
            Provider provider = providerRepository.findById(dto.getProviderId())
                    .orElseThrow(
                            () -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
            existing.setProvider(provider);
        }

        if (dto.getTitle() != null)
            existing.setTitle(dto.getTitle());
        if (dto.getAreaId() != null
                && (existing.getArea() == null || !existing.getArea().getAreaId().equals(dto.getAreaId()))) {
            Area area = areaRepository.findById(dto.getAreaId())
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + dto.getAreaId()));
            existing.setArea(area);
        }
        if (dto.getServiceDescription() != null)
            existing.setServiceDescription(dto.getServiceDescription());
        if (dto.getLocation() != null)
            existing.setLocation(dto.getLocation());
        if (dto.getStartDate() != null)
            existing.setStartDate(dto.getStartDate());
        if (dto.getEndDate() != null)
            existing.setEndDate(dto.getEndDate());
        if (dto.getPrice() != null)
            existing.setPrice(dto.getPrice());
        if (dto.getCurrencyCode() != null)
            existing.setCurrencyCode(dto.getCurrencyCode());
        if (dto.getCapacity() != null)
            existing.setCapacity(dto.getCapacity());
        if (dto.getMinParticipants() != null)
            existing.setMinParticipants(dto.getMinParticipants());
        if (dto.getMaxParticipants() != null)
            existing.setMaxParticipants(dto.getMaxParticipants());
        if (dto.getThumbnailUrl() != null)
            existing.setThumbnailUrl(dto.getThumbnailUrl());
        if (dto.getImageUrls() != null)
            existing.setImageUrls(joinList(dto.getImageUrls()));
        if (dto.getRatingAverage() != null)
            existing.setRatingAverage(dto.getRatingAverage());
        if (dto.getBadges() != null)
            existing.setBadges(joinList(dto.getBadges()));
        if (dto.getRestaurantStatus() != null)
            existing.setRestaurantStatus(Restaurant.RestaurantStatus.valueOf(dto.getRestaurantStatus()));
        if (dto.getPriceLevel() != null)
            existing.setPriceLevel(Restaurant.PriceLevel.valueOf(dto.getPriceLevel()));
        if (dto.getPhone() != null)
            existing.setPhone(dto.getPhone());
        if (dto.getWebsite() != null)
            existing.setWebsite(dto.getWebsite());
        if (dto.getAddress() != null)
            existing.setAddress(dto.getAddress());
        if (dto.getCuisines() != null)
            existing.setCuisinesJson(writeJson(dto.getCuisines()));
        if (dto.getServices() != null)
            existing.setServicesJson(writeJson(dto.getServices()));
        if (dto.getDiets() != null)
            existing.setDietsJson(writeJson(dto.getDiets()));
        if (dto.getOpeningHours() != null)
            existing.setOpeningHoursJson(writeJson(dto.getOpeningHours()));

        Restaurant saved = restaurantRepository.save(existing);
        return toDTO(saved);
    }

    public void deleteRestaurant(Integer restaurantId) {
        Restaurant existing = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Restaurant id: " + restaurantId));
        restaurantRepository.delete(existing);
        log.info("Đã xóa Restaurant id: {}", restaurantId);
    }

    // ============ Reviews ============
    public RestaurantReviewDTO createRestaurantReview(RestaurantReviewDTO dto) {
        Restaurant restaurant = restaurantRepository.findById(dto.getRestaurantId())
                .orElseThrow(
                        () -> new ResourceNotFoundException("Không tìm thấy Restaurant id: " + dto.getRestaurantId()));
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        RestaurantReview review = RestaurantReview.builder()
                .reviewId(null)
                .restaurant(restaurant)
                .user(user)
                .rating(dto.getRating())
                .title(dto.getTitle())
                .content(dto.getContent())
                .imageUrls(joinList(dto.getImageUrls()))
                .likesCount(dto.getLikesCount() != null ? dto.getLikesCount() : 0)
                .replyCount(dto.getReplyCount() != null ? dto.getReplyCount() : 0)
                .reviewStatus(
                        dto.getReviewStatus() != null ? RestaurantReview.ReviewStatus.valueOf(dto.getReviewStatus())
                                : RestaurantReview.ReviewStatus.approved)
                .build();

        RestaurantReview saved = restaurantReviewRepository.save(review);

        if (dto.getAspects() != null) {
            RestaurantReviewAspects aspects = RestaurantReviewAspects.builder()
                    .review(saved)
                    .quality(dto.getAspects().getQuality())
                    .service(dto.getAspects().getService())
                    .price(dto.getAspects().getPrice())
                    .location(dto.getAspects().getLocation())
                    .ambience(dto.getAspects().getAmbience())
                    .build();
            restaurantReviewAspectsRepository.save(aspects);
        }

        return toReviewDTO(saved, true);
    }

    public List<RestaurantReviewDTO> getRestaurantReviews(Integer restaurantId, String status) {
        List<RestaurantReview> list;
        if (status != null && !status.isBlank()) {
            RestaurantReview.ReviewStatus st = RestaurantReview.ReviewStatus.valueOf(status);
            list = restaurantReviewRepository.findByRestaurantAndStatus(restaurantId, st);
        } else {
            list = restaurantReviewRepository.findByRestaurant_RestaurantId(restaurantId);
        }
        return list.stream().map(r -> toReviewDTO(r, true)).collect(Collectors.toList());
    }

    // ===== Review Replies (Restaurant) =====
    public com.vn.tripfinity.backend.dto.RestaurantReviewReplyDTO createRestaurantReviewReply(Integer reviewId,
            com.vn.tripfinity.backend.dto.RestaurantReviewReplyDTO dto) {
        RestaurantReview review = restaurantReviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy RestaurantReview id: " + reviewId));

        User replier = userRepository.findById(dto.getReplierId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getReplierId()));

        ReviewReply reply = ReviewReply.builder()
                .replyId(null)
                .reviewType(ReviewReply.ReviewType.restaurant)
                .reviewId(review.getReviewId())
                .replier(replier)
                .content(dto.getContent())
                .isPublic(dto.getIsPublic() != null ? dto.getIsPublic() : Boolean.TRUE)
                .build();

        ReviewReply saved = reviewReplyRepository.save(reply);

        review.setReplyCount(review.getReplyCount() == null ? 1 : review.getReplyCount() + 1);
        restaurantReviewRepository.save(review);

        return toRestaurantReviewReplyDTO(saved);
    }

    public java.util.List<com.vn.tripfinity.backend.dto.RestaurantReviewReplyDTO> getRestaurantReviewReplies(
            Integer reviewId) {
        RestaurantReview review = restaurantReviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy RestaurantReview id: " + reviewId));
        List<ReviewReply> replies = reviewReplyRepository.findByReviewTypeAndReviewIdOrderByCreatedAtAsc(
                ReviewReply.ReviewType.restaurant, review.getReviewId());
        return replies.stream().map(this::toRestaurantReviewReplyDTO)
                .collect(java.util.stream.Collectors.toList());
    }

    private com.vn.tripfinity.backend.dto.RestaurantReviewReplyDTO toRestaurantReviewReplyDTO(ReviewReply r) {
        return com.vn.tripfinity.backend.dto.RestaurantReviewReplyDTO.builder()
                .replyId(r.getReplyId())
                .reviewId(r.getReviewId())
                .replierId(r.getReplier() != null ? r.getReplier().getUserId() : null)
                .content(r.getContent())
                .isPublic(r.getIsPublic())
                .createdAt(r.getCreatedAt())
                .updatedAt(r.getUpdatedAt())
                .build();
    }

    private RestaurantReviewDTO toReviewDTO(RestaurantReview r, boolean fetchAspects) {
        RestaurantReviewDTO.RestaurantReviewAspectsDTO aspectsDTO = null;
        if (fetchAspects && r.getReviewId() != null) {
            var opt = restaurantReviewAspectsRepository.findById(r.getReviewId());
            if (opt.isPresent()) {
                var a = opt.get();
                aspectsDTO = RestaurantReviewDTO.RestaurantReviewAspectsDTO.builder()
                        .quality(a.getQuality())
                        .service(a.getService())
                        .price(a.getPrice())
                        .location(a.getLocation())
                        .ambience(a.getAmbience())
                        .build();
            }
        }

        return RestaurantReviewDTO.builder()
                .reviewId(r.getReviewId())
                .restaurantId(r.getRestaurant() != null ? r.getRestaurant().getRestaurantId() : null)
                .userId(r.getUser() != null ? r.getUser().getUserId() : null)
                .rating(r.getRating())
                .title(r.getTitle())
                .content(r.getContent())
                .imageUrls(splitList(r.getImageUrls()))
                .likesCount(r.getLikesCount())
                .replyCount(r.getReplyCount())
                .reviewStatus(r.getReviewStatus() != null ? r.getReviewStatus().name() : null)
                .aspects(aspectsDTO)
                .createdAt(r.getCreatedAt())
                .updatedAt(r.getUpdatedAt())
                .build();
    }

    private RestaurantDTO toDTO(Restaurant r) {
        return RestaurantDTO.builder()
                .restaurantId(r.getRestaurantId())
                .providerId(r.getProvider() != null ? r.getProvider().getProviderId() : null)
                .areaId(r.getArea() != null ? r.getArea().getAreaId() : null)
                .title(r.getTitle())
                .serviceDescription(r.getServiceDescription())
                .location(r.getLocation())
                .startDate(r.getStartDate())
                .endDate(r.getEndDate())
                .price(r.getPrice())
                .currencyCode(r.getCurrencyCode())
                .capacity(r.getCapacity())
                .minParticipants(r.getMinParticipants())
                .maxParticipants(r.getMaxParticipants())
                .thumbnailUrl(r.getThumbnailUrl())
                .imageUrls(splitList(r.getImageUrls()))
                .ratingAverage(r.getRatingAverage())
                .badges(splitList(r.getBadges()))
                .restaurantStatus(r.getRestaurantStatus() != null ? r.getRestaurantStatus().name() : null)
                .priceLevel(r.getPriceLevel() != null ? r.getPriceLevel().name() : null)
                .phone(r.getPhone())
                .website(r.getWebsite())
                .address(r.getAddress())
                .cuisines(readJsonList(r.getCuisinesJson()))
                .services(readJsonList(r.getServicesJson()))
                .diets(readJsonList(r.getDietsJson()))
                .openingHours(readJsonMapOfList(r.getOpeningHoursJson()))
                .createdAt(r.getCreatedAt())
                .updatedAt(r.getUpdatedAt())
                .build();
    }

    private String joinList(List<String> list) {
        if (list == null || list.isEmpty())
            return null;
        return String.join(",", list);
    }

    private List<String> splitList(String csv) {
        if (csv == null || csv.trim().isEmpty())
            return null;
        return List.of(csv.split(","));
    }

    private String writeJson(Object obj) {
        if (obj == null)
            return null;
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            throw new IllegalArgumentException("Không thể chuyển dữ liệu sang JSON", e);
        }
    }

    @SuppressWarnings("unchecked")
    private List<String> readJsonList(String json) {
        if (json == null || json.isEmpty())
            return null;
        try {
            return objectMapper.readValue(json, List.class);
        } catch (Exception e) {
            log.warn("Không thể parse JSON list: {}", json, e);
            return null;
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, List<Map<String, String>>> readJsonMapOfList(String json) {
        if (json == null || json.isEmpty())
            return null;
        try {
            return objectMapper.readValue(json, Map.class);
        } catch (Exception e) {
            log.warn("Không thể parse JSON map: {}", json, e);
            return null;
        }
    }
}
