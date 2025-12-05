package com.vn.tripfinity.backend.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vn.tripfinity.backend.dto.RestaurantDTO;
import com.vn.tripfinity.backend.dto.RestaurantReviewDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Area;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.Restaurant;
import com.vn.tripfinity.backend.model.RestaurantReview;
import com.vn.tripfinity.backend.model.RestaurantReviewAspects;
import com.vn.tripfinity.backend.model.ReviewReply;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.AreaRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.RestaurantRepository;
import com.vn.tripfinity.backend.repository.RestaurantReviewAspectsRepository;
import com.vn.tripfinity.backend.repository.RestaurantReviewRepository;
import com.vn.tripfinity.backend.repository.ReviewReplyRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

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
                .address(dto.getAddress())
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .phone(dto.getPhone())
                .website(dto.getWebsite())
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .price(dto.getPrice())
                .currencyCode(dto.getCurrencyCode())
                .priceLevel(dto.getPriceLevel() != null ? Restaurant.PriceLevel.valueOf(dto.getPriceLevel()) : null)
                .capacity(dto.getCapacity())
                .minParticipants(dto.getMinParticipants())
                .maxParticipants(dto.getMaxParticipants())
                .thumbnailUrl(dto.getThumbnailUrl())
                .imageUrls(writeJson(dto.getImageUrls()))
                .ratingAverage(dto.getRatingAverage() != null ? dto.getRatingAverage() : new BigDecimal("0.00"))
                .badges(writeJson(dto.getBadges()))
                .restaurantStatus(dto.getRestaurantStatus() != null
                        ? Restaurant.RestaurantStatus.valueOf(dto.getRestaurantStatus())
                        : Restaurant.RestaurantStatus.published)
                .visibility(dto.getVisibility() != null
                        ? Restaurant.Visibility.valueOf(dto.getVisibility())
                        : Restaurant.Visibility.public_)
                .isFeatured(dto.getIsFeatured() != null && dto.getIsFeatured())
                .cuisinesJson(writeJson(dto.getCuisinesJson()))
                .servicesJson(writeJson(dto.getServicesJson()))
                .dietsJson(writeJson(dto.getDietsJson()))
                .openingHoursJson(writeJson(dto.getOpeningHoursJson()))
                .menuHighlightsJson(writeJson(dto.getMenuHighlightsJson()))
                .ambianceTagsJson(writeJson(dto.getAmbianceTagsJson()))
                .paymentMethodsJson(writeJson(dto.getPaymentMethodsJson()))
                .policiesText(dto.getPoliciesText())
                .slug(dto.getSlug())
                .seoTitle(dto.getSeoTitle())
                .seoDescription(dto.getSeoDescription())
                .bookingSettingsJson(writeJson(dto.getBookingSettingsJson()))
                .publishedAt(dto.getPublishedAt())
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
        if (dto.getAddress() != null)
            existing.setAddress(dto.getAddress());
        if (dto.getLatitude() != null)
            existing.setLatitude(dto.getLatitude());
        if (dto.getLongitude() != null)
            existing.setLongitude(dto.getLongitude());
        if (dto.getPhone() != null)
            existing.setPhone(dto.getPhone());
        if (dto.getWebsite() != null)
            existing.setWebsite(dto.getWebsite());
        if (dto.getStartDate() != null)
            existing.setStartDate(dto.getStartDate());
        if (dto.getEndDate() != null)
            existing.setEndDate(dto.getEndDate());
        if (dto.getPrice() != null)
            existing.setPrice(dto.getPrice());
        if (dto.getCurrencyCode() != null)
            existing.setCurrencyCode(dto.getCurrencyCode());
        if (dto.getPriceLevel() != null)
            existing.setPriceLevel(Restaurant.PriceLevel.valueOf(dto.getPriceLevel()));
        if (dto.getCapacity() != null)
            existing.setCapacity(dto.getCapacity());
        if (dto.getMinParticipants() != null)
            existing.setMinParticipants(dto.getMinParticipants());
        if (dto.getMaxParticipants() != null)
            existing.setMaxParticipants(dto.getMaxParticipants());
        if (dto.getThumbnailUrl() != null)
            existing.setThumbnailUrl(dto.getThumbnailUrl());
        if (dto.getImageUrls() != null)
            existing.setImageUrls(writeJson(dto.getImageUrls()));
        if (dto.getRatingAverage() != null)
            existing.setRatingAverage(dto.getRatingAverage());
        if (dto.getBadges() != null)
            existing.setBadges(writeJson(dto.getBadges()));
        if (dto.getRestaurantStatus() != null)
            existing.setRestaurantStatus(Restaurant.RestaurantStatus.valueOf(dto.getRestaurantStatus()));
        if (dto.getVisibility() != null)
            existing.setVisibility(Restaurant.Visibility.valueOf(dto.getVisibility()));
        if (dto.getIsFeatured() != null)
            existing.setIsFeatured(dto.getIsFeatured());
        if (dto.getCuisinesJson() != null)
            existing.setCuisinesJson(writeJson(dto.getCuisinesJson()));
        if (dto.getServicesJson() != null)
            existing.setServicesJson(writeJson(dto.getServicesJson()));
        if (dto.getDietsJson() != null)
            existing.setDietsJson(writeJson(dto.getDietsJson()));
        if (dto.getOpeningHoursJson() != null)
            existing.setOpeningHoursJson(writeJson(dto.getOpeningHoursJson()));
        if (dto.getMenuHighlightsJson() != null)
            existing.setMenuHighlightsJson(writeJson(dto.getMenuHighlightsJson()));
        if (dto.getAmbianceTagsJson() != null)
            existing.setAmbianceTagsJson(writeJson(dto.getAmbianceTagsJson()));
        if (dto.getPaymentMethodsJson() != null)
            existing.setPaymentMethodsJson(writeJson(dto.getPaymentMethodsJson()));
        if (dto.getPoliciesText() != null)
            existing.setPoliciesText(dto.getPoliciesText());
        if (dto.getSlug() != null)
            existing.setSlug(dto.getSlug());
        if (dto.getSeoTitle() != null)
            existing.setSeoTitle(dto.getSeoTitle());
        if (dto.getSeoDescription() != null)
            existing.setSeoDescription(dto.getSeoDescription());
        if (dto.getBookingSettingsJson() != null)
            existing.setBookingSettingsJson(writeJson(dto.getBookingSettingsJson()));
        if (dto.getPublishedAt() != null)
            existing.setPublishedAt(dto.getPublishedAt());

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
                .rating(java.util.Objects.requireNonNullElse(dto.getRating(), 0))
                .title(dto.getTitle())
                .content(dto.getContent())
                .imageUrls(writeJson(dto.getImageUrls()))
                .likesCount(java.util.Objects.requireNonNullElse(dto.getLikesCount(), 0))
                .replyCount(java.util.Objects.requireNonNullElse(dto.getReplyCount(), 0))
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
        List<ReviewReply> replies = reviewReplyRepository.findByReviewTypeAndReviewIdOrderByCreatedAtDesc(
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
                .imageUrls(readJsonListString(r.getImageUrls()))
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
                .address(r.getAddress())
                .latitude(r.getLatitude())
                .longitude(r.getLongitude())
                .phone(r.getPhone())
                .website(r.getWebsite())
                .startDate(r.getStartDate())
                .endDate(r.getEndDate())
                .price(r.getPrice())
                .currencyCode(r.getCurrencyCode())
                .priceLevel(r.getPriceLevel() != null ? r.getPriceLevel().name() : null)
                .capacity(r.getCapacity())
                .minParticipants(r.getMinParticipants())
                .maxParticipants(r.getMaxParticipants())
                .thumbnailUrl(r.getThumbnailUrl())
                .imageUrls(readJsonListString(r.getImageUrls()))
                .ratingAverage(r.getRatingAverage())
                .badges(readJsonListString(r.getBadges()))
                .restaurantStatus(r.getRestaurantStatus() != null ? r.getRestaurantStatus().name() : null)
                .visibility(r.getVisibility() != null ? r.getVisibility().name() : null)
                .isFeatured(r.getIsFeatured())
                .cuisinesJson(readJsonListString(r.getCuisinesJson()))
                .servicesJson(readJsonListString(r.getServicesJson()))
                .dietsJson(readJsonListString(r.getDietsJson()))
                .openingHoursJson(readJsonObject(r.getOpeningHoursJson()))
                .menuHighlightsJson(readJsonListString(r.getMenuHighlightsJson()))
                .ambianceTagsJson(readJsonListString(r.getAmbianceTagsJson()))
                .paymentMethodsJson(readJsonListString(r.getPaymentMethodsJson()))
                .policiesText(r.getPoliciesText())
                .slug(r.getSlug())
                .seoTitle(r.getSeoTitle())
                .seoDescription(r.getSeoDescription())
                .bookingSettingsJson(readJsonObject(r.getBookingSettingsJson()))
                .publishedAt(r.getPublishedAt())
                .createdAt(r.getCreatedAt())
                .updatedAt(r.getUpdatedAt())
                .build();
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
    private List<String> readJsonListString(String json) {
        if (json == null || json.isEmpty())
            return null;
        try {
            return objectMapper.readValue(json, List.class);
        } catch (JsonProcessingException e) {
            log.warn("Không thể parse JSON list: {}", json, e);
            return null;
        }
    }

    private Object readJsonObject(String json) {
        if (json == null || json.isEmpty())
            return null;
        try {
            return objectMapper.readValue(json, Object.class);
        } catch (JsonProcessingException e) {
            log.warn("Không thể parse JSON object: {}", json, e);
            return null;
        }
    }
}
