package com.vn.tripfinity.backend.service;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vn.tripfinity.backend.dto.TourDTO;
import com.vn.tripfinity.backend.dto.TourReviewDTO;
import com.vn.tripfinity.backend.dto.TourReviewReplyDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Area;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.ReviewReply;
import com.vn.tripfinity.backend.model.Tour;
import com.vn.tripfinity.backend.model.TourReview;
import com.vn.tripfinity.backend.model.TourReviewAspects;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.AreaRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.ReviewReplyRepository;
import com.vn.tripfinity.backend.repository.TourRepository;
import com.vn.tripfinity.backend.repository.TourReviewAspectsRepository;
import com.vn.tripfinity.backend.repository.TourReviewRepository;
import com.vn.tripfinity.backend.repository.UserRepository;
import com.vn.tripfinity.backend.service.cloudinary.CloudinaryService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class TourService {

    private final TourRepository tourRepository;
    private final ProviderRepository providerRepository;
    private final TourReviewRepository tourReviewRepository;
    private final TourReviewAspectsRepository tourReviewAspectsRepository;
    private final UserRepository userRepository;
    private final ReviewReplyRepository reviewReplyRepository;
    private final AreaRepository areaRepository;
    private final CloudinaryService cloudinaryService;
    private final NotificationService notificationService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public List<TourDTO> getAllTours() {
        return tourRepository.findAll().stream().map(this::toDTO).collect(Collectors.toList());
    }

    public TourDTO getTourById(Integer tourId) {
        Tour t = tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));
        return toDTO(t);
    }

    public List<TourDTO> getToursByProviderId(Integer providerId) {
        return tourRepository.findByProvider_ProviderId(providerId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public TourDTO createTour(TourDTO dto) {
        Provider provider = providerRepository.findById(dto.getProviderId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
        Area area = areaRepository.findById(dto.getAreaId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + dto.getAreaId()));

        // Xác định tourStatus và publishedAt
        Tour.TourStatus tourStatus = dto.getTourStatus() != null 
                ? Tour.TourStatus.valueOf(dto.getTourStatus())
                : Tour.TourStatus.published;
        LocalDateTime publishedAt = determinePublishedAt(tourStatus, null);

        Tour entity = Tour.builder()
                .tourId(null)
                .provider(provider)
                .area(area)
                .title(dto.getTitle())
                .serviceDescription(dto.getServiceDescription())
                .location(dto.getLocation())
                .address(dto.getAddress())
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .price(dto.getPrice())
                .currencyCode(dto.getCurrencyCode())
                .capacity(dto.getCapacity())
                .minParticipants(dto.getMinParticipants())
                .maxParticipants(dto.getMaxParticipants())
                .thumbnailUrl(dto.getThumbnailUrl())
                .imageUrls(writeJson(dto.getImageUrls()))
                .badges(writeJson(dto.getBadges()))
                .tourStatus(tourStatus)
                .visibility(dto.getVisibility() != null ? Tour.Visibility.valueOf(dto.getVisibility().replace("public", "public_").replace("private", "private_"))
                        : Tour.Visibility.public_)
                .isFeatured(Boolean.TRUE.equals(dto.getIsFeatured()))
                .durationDays(dto.getDurationDays())
                .difficultyLevel(
                        dto.getDifficultyLevel() != null ? Tour.DifficultyLevel.valueOf(dto.getDifficultyLevel())
                                : null)
                .departureLocation(dto.getDepartureLocation())
                .meetingPoint(dto.getMeetingPoint())
                .guideLanguage(dto.getGuideLanguagesJson() != null ? joinList(dto.getGuideLanguagesJson()) : joinList(dto.getGuideLanguage()))
                .guideLanguagesJson(writeJson(dto.getGuideLanguagesJson()))
                .itineraryOverview(dto.getItineraryOverview())
                .itineraryDetailsJson(dto.getItineraryDetailsJson())
                .inclusiveItems(dto.getIncludedJson() != null ? joinList(dto.getIncludedJson()) : joinList(dto.getInclusiveItems()))
                .exclusiveItems(dto.getExcludedJson() != null ? joinList(dto.getExcludedJson()) : joinList(dto.getExclusiveItems()))
                .includedJson(writeJson(dto.getIncludedJson()))
                .excludedJson(writeJson(dto.getExcludedJson()))
                .cancellationPolicy(dto.getCancellationPolicy())
                .policiesText(dto.getPoliciesText())
                .tourType(dto.getTourType() != null ? Tour.TourType.valueOf(dto.getTourType().replace("private", "private_"))
                        : Tour.TourType.group)
                .categoriesJson(writeJson(dto.getCategoriesJson()))
                .servicesJson(writeJson(dto.getServicesJson()))
                .slug(dto.getSlug())
                .seoTitle(dto.getSeoTitle())
                .seoDescription(dto.getSeoDescription())
                .publishedAt(publishedAt)
                .build();

        Tour saved = tourRepository.save(entity);
        log.info("Tạo Tour ID: {}", saved.getTourId());
        
        // 📬 GỬI THÔNG BÁO CHO SUPPLIER
        try {
            if (provider != null && provider.getUser() != null) {
                Integer userId = provider.getUser().getUserId();
                notificationService.notifyTourCreated(userId, saved.getTitle());
                log.info("📬 Tour created notification sent to userId: {}", userId);
            }
        } catch (Exception e) {
            log.error("❌ Failed to send tour created notification: {}", e.getMessage());
        }
        
        return toDTO(saved);
    }

    public TourDTO updateTour(Integer tourId, TourDTO dto) {
        Tour existing = tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));

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
            existing.setImageUrls(writeJson(dto.getImageUrls()));
        if (dto.getBadges() != null)
            existing.setBadges(writeJson(dto.getBadges()));
        if (dto.getTourStatus() != null) {
            Tour.TourStatus oldStatus = existing.getTourStatus();
            Tour.TourStatus newStatus = Tour.TourStatus.valueOf(dto.getTourStatus());
            LocalDateTime oldPublishedAt = existing.getPublishedAt();
            
            existing.setTourStatus(newStatus);
            
            if (oldStatus != newStatus) {
                LocalDateTime newPublishedAt = determinePublishedAt(newStatus, oldPublishedAt);
                existing.setPublishedAt(newPublishedAt);
                log.info("🔄 Tour {} status thay đổi từ {} -> {}, publishedAt: {} -> {}",
                        existing.getTourId(), oldStatus, newStatus, oldPublishedAt, newPublishedAt);
            }
        }
        if (dto.getVisibility() != null)
            existing.setVisibility(Tour.Visibility.valueOf(dto.getVisibility().replace("public", "public_").replace("private", "private_")));
        if (dto.getIsFeatured() != null)
            existing.setIsFeatured(dto.getIsFeatured());
        if (dto.getDurationDays() != null)
            existing.setDurationDays(dto.getDurationDays());
        if (dto.getDifficultyLevel() != null)
            existing.setDifficultyLevel(Tour.DifficultyLevel.valueOf(dto.getDifficultyLevel()));
        if (dto.getDepartureLocation() != null)
            existing.setDepartureLocation(dto.getDepartureLocation());
        if (dto.getMeetingPoint() != null)
            existing.setMeetingPoint(dto.getMeetingPoint());
        // Sync guide language: prioritize JSON, fallback to CSV
        if (dto.getGuideLanguagesJson() != null) {
            existing.setGuideLanguagesJson(writeJson(dto.getGuideLanguagesJson()));
            existing.setGuideLanguage(joinList(dto.getGuideLanguagesJson()));
        } else if (dto.getGuideLanguage() != null) {
            existing.setGuideLanguage(joinList(dto.getGuideLanguage()));
        }
        if (dto.getItineraryOverview() != null)
            existing.setItineraryOverview(dto.getItineraryOverview());
        if (dto.getItineraryDetailsJson() != null)
            existing.setItineraryDetailsJson(dto.getItineraryDetailsJson());
        // Sync inclusive/exclusive items: prioritize JSON, fallback to CSV
        if (dto.getIncludedJson() != null) {
            existing.setIncludedJson(writeJson(dto.getIncludedJson()));
            existing.setInclusiveItems(joinList(dto.getIncludedJson()));
        } else if (dto.getInclusiveItems() != null) {
            existing.setInclusiveItems(joinList(dto.getInclusiveItems()));
        }
        if (dto.getExcludedJson() != null) {
            existing.setExcludedJson(writeJson(dto.getExcludedJson()));
            existing.setExclusiveItems(joinList(dto.getExcludedJson()));
        } else if (dto.getExclusiveItems() != null) {
            existing.setExclusiveItems(joinList(dto.getExclusiveItems()));
        }
        if (dto.getCancellationPolicy() != null)
            existing.setCancellationPolicy(dto.getCancellationPolicy());
        if (dto.getPoliciesText() != null)
            existing.setPoliciesText(dto.getPoliciesText());
        if (dto.getTourType() != null)
            existing.setTourType(Tour.TourType.valueOf(dto.getTourType().replace("private", "private_")));
        if (dto.getCategoriesJson() != null)
            existing.setCategoriesJson(writeJson(dto.getCategoriesJson()));
        if (dto.getServicesJson() != null)
            existing.setServicesJson(writeJson(dto.getServicesJson()));
        if (dto.getSlug() != null)
            existing.setSlug(dto.getSlug());
        if (dto.getSeoTitle() != null)
            existing.setSeoTitle(dto.getSeoTitle());
        if (dto.getSeoDescription() != null)
            existing.setSeoDescription(dto.getSeoDescription());
        if (dto.getPublishedAt() != null)
            existing.setPublishedAt(dto.getPublishedAt());

        Tour saved = tourRepository.save(existing);
        
        // 📬 GỬI THÔNG BÁO CHO SUPPLIER
        try {
            if (saved.getProvider() != null && saved.getProvider().getUser() != null) {
                Integer userId = saved.getProvider().getUser().getUserId();
                notificationService.notifyTourUpdated(userId, saved.getTitle());
                log.info("📬 Tour updated notification sent to userId: {}", userId);
            }
        } catch (Exception e) {
            log.error("❌ Failed to send tour updated notification: {}", e.getMessage());
        }
        
        return toDTO(saved);
    }

    public void deleteTour(Integer tourId) {
        Tour existing = tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));
        tourRepository.delete(existing);
        log.info("Đã xóa Tour id: {}", tourId);
    }

    // ============ Reviews ============
    public TourReviewDTO createTourReview(TourReviewDTO dto) {
        Tour tour = tourRepository.findById(dto.getTourId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + dto.getTourId()));
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        Integer likesCount = 0;
        if (dto.getLikesCount() != null) {
            likesCount = dto.getLikesCount();
        }
        Integer replyCount = 0;
        if (dto.getReplyCount() != null) {
            replyCount = dto.getReplyCount();
        }
        
        TourReview review = TourReview.builder()
                .reviewId(null)
                .tour(tour)
                .user(user)
                .rating(dto.getRating())
                .title(dto.getTitle())
                .content(dto.getContent())
                .imageUrls(joinList(dto.getImageUrls()))
                .likesCount(likesCount)
                .replyCount(replyCount)
                .reviewStatus(dto.getReviewStatus() != null ? TourReview.ReviewStatus.valueOf(dto.getReviewStatus())
                        : TourReview.ReviewStatus.approved)
                .build();

        TourReview saved = tourReviewRepository.save(review);

        if (dto.getAspects() != null) {
            TourReviewAspects aspects = TourReviewAspects.builder()
                    .review(saved)
                    .guideQuality(dto.getAspects().getGuideQuality())
                    .itineraryQuality(dto.getAspects().getItineraryQuality())
                    .valueForMoney(dto.getAspects().getValueForMoney())
                    .organization(dto.getAspects().getOrganization())
                    .safety(dto.getAspects().getSafety())
                    .build();
            tourReviewAspectsRepository.save(aspects);
        }

        return toReviewDTO(saved, true);
    }

    public List<TourReviewDTO> getTourReviews(Integer tourId, String status) {
        List<TourReview> list;
        if (status != null && !status.isBlank()) {
            TourReview.ReviewStatus st = TourReview.ReviewStatus.valueOf(status);
            list = tourReviewRepository.findByTourAndStatus(tourId, st);
        } else {
            list = tourReviewRepository.findByTour_TourId(tourId);
        }
        return list.stream().map(r -> toReviewDTO(r, true)).collect(Collectors.toList());
    }

    // ===== Review Replies (Tour) =====
    public TourReviewReplyDTO createTourReviewReply(Integer reviewId, TourReviewReplyDTO dto) {
        TourReview review = tourReviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy TourReview id: " + reviewId));

        User replier = userRepository.findById(dto.getReplierId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getReplierId()));

        ReviewReply reply = ReviewReply.builder()
                .replyId(null)
                .reviewType(ReviewReply.ReviewType.tour)
                .reviewId(review.getReviewId())
                .replier(replier)
                .content(dto.getContent())
                .isPublic(dto.getIsPublic() != null ? dto.getIsPublic() : Boolean.TRUE)
                .build();

        ReviewReply saved = reviewReplyRepository.save(reply);

        review.setReplyCount(review.getReplyCount() == null ? 1 : review.getReplyCount() + 1);
        tourReviewRepository.save(review);

        return toTourReviewReplyDTO(saved);
    }

    public List<TourReviewReplyDTO> getTourReviewReplies(Integer reviewId) {
        TourReview review = tourReviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy TourReview id: " + reviewId));
        List<ReviewReply> replies = reviewReplyRepository
                .findByReviewTypeAndReviewIdOrderByCreatedAtDesc(ReviewReply.ReviewType.tour, review.getReviewId());
        return replies.stream().map(this::toTourReviewReplyDTO).collect(Collectors.toList());
    }

    private TourReviewReplyDTO toTourReviewReplyDTO(ReviewReply r) {
        return TourReviewReplyDTO.builder()
                .replyId(r.getReplyId())
                .reviewId(r.getReviewId())
                .replierId(r.getReplier() != null ? r.getReplier().getUserId() : null)
                .content(r.getContent())
                .isPublic(r.getIsPublic())
                .createdAt(r.getCreatedAt())
                .updatedAt(r.getUpdatedAt())
                .build();
    }

    private TourReviewDTO toReviewDTO(TourReview r, boolean fetchAspects) {
        TourReviewDTO.TourReviewAspectsDTO aspectsDTO = null;
        if (fetchAspects && r.getReviewId() != null) {
            var opt = tourReviewAspectsRepository.findById(r.getReviewId());
            if (opt.isPresent()) {
                var a = opt.get();
                aspectsDTO = TourReviewDTO.TourReviewAspectsDTO.builder()
                        .guideQuality(a.getGuideQuality())
                        .itineraryQuality(a.getItineraryQuality())
                        .valueForMoney(a.getValueForMoney())
                        .organization(a.getOrganization())
                        .safety(a.getSafety())
                        .build();
            }
        }

        return TourReviewDTO.builder()
                .reviewId(r.getReviewId())
                .tourId(r.getTour() != null ? r.getTour().getTourId() : null)
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

    private TourDTO toDTO(Tour t) {
        // Calculate rating average from reviews (null if no reviews)
        Double ratingAverage = tourReviewRepository.calculateAverageRating(t.getTourId());
        
        return TourDTO.builder()
                .tourId(t.getTourId())
                .providerId(t.getProvider() != null ? t.getProvider().getProviderId() : null)
                .areaId(t.getArea() != null ? t.getArea().getAreaId() : null)
                .title(t.getTitle())
                .serviceDescription(t.getServiceDescription())
                .location(t.getLocation())
                .address(t.getAddress())
                .latitude(t.getLatitude())
                .longitude(t.getLongitude())
                .startDate(t.getStartDate())
                .endDate(t.getEndDate())
                .price(t.getPrice())
                .currencyCode(t.getCurrencyCode())
                .capacity(t.getCapacity())
                .minParticipants(t.getMinParticipants())
                .maxParticipants(t.getMaxParticipants())
                .thumbnailUrl(t.getThumbnailUrl())
                .imageUrls(readJsonList(t.getImageUrls()))
                .badges(readJsonList(t.getBadges()))
                .tourStatus(t.getTourStatus() != null ? t.getTourStatus().name() : null)
                .visibility(t.getVisibility() != null ? t.getVisibility().name().replace("public_", "public").replace("private_", "private") : null)
                .isFeatured(t.getIsFeatured())
                .durationDays(t.getDurationDays())
                .difficultyLevel(t.getDifficultyLevel() != null ? t.getDifficultyLevel().name() : null)
                .departureLocation(t.getDepartureLocation())
                .meetingPoint(t.getMeetingPoint())
                .guideLanguage(splitList(t.getGuideLanguage()))
                .guideLanguagesJson(readJsonList(t.getGuideLanguagesJson()))
                .itineraryOverview(t.getItineraryOverview())
                .itineraryDetailsJson(t.getItineraryDetailsJson())
                .inclusiveItems(splitList(t.getInclusiveItems()))
                .exclusiveItems(splitList(t.getExclusiveItems()))
                .includedJson(readJsonList(t.getIncludedJson()))
                .excludedJson(readJsonList(t.getExcludedJson()))
                .cancellationPolicy(t.getCancellationPolicy())
                .policiesText(t.getPoliciesText())
                .tourType(t.getTourType() != null ? t.getTourType().name().replace("private_", "private") : null)
                .categoriesJson(readJsonList(t.getCategoriesJson()))
                .servicesJson(readJsonList(t.getServicesJson()))
                .slug(t.getSlug())
                .seoTitle(t.getSeoTitle())
                .seoDescription(t.getSeoDescription())
                .publishedAt(t.getPublishedAt())
                .ratingAverage(ratingAverage)
                .createdAt(t.getCreatedAt())
                .updatedAt(t.getUpdatedAt())
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
    private List<String> readJsonList(String json) {
        if (json == null || json.isEmpty())
            return null;
        try {
            // Try JSON format first
            return objectMapper.readValue(json, List.class);
        } catch (JsonProcessingException e) {
            // Fallback to CSV format for legacy data
            log.debug("Parse JSON failed, trying CSV format: {}", json);
            return splitList(json);
        }
    }

    /**
     * Xác định publishedAt dựa trên tourStatus
     */
    private LocalDateTime determinePublishedAt(Tour.TourStatus status, LocalDateTime currentPublishedAt) {
        return switch (status) {
            case published -> currentPublishedAt == null ? LocalDateTime.now() : currentPublishedAt;
            case archived, disabled -> null;
            default -> null;
        };
    }

    // Helper methods for deprecated CSV fields (guideLanguage, inclusiveItems, exclusiveItems)
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

    // ==================== IMAGE MANAGEMENT ====================

    public TourDTO uploadThumbnail(Integer tourId, MultipartFile file) throws IOException {
        log.debug("Upload thumbnail cho Tour ID: {}", tourId);
        Tour tour = tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));

        // Xóa thumbnail cũ nếu có
        if (tour.getThumbnailUrl() != null && !tour.getThumbnailUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImage(tour.getThumbnailUrl());
                log.info("Đã xóa thumbnail cũ trên Cloudinary");
            } catch (IOException e) {
                log.error("Lỗi khi xóa thumbnail cũ: {}", e.getMessage());
            }
        }

        // Upload thumbnail mới
        Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
        String thumbnailUrl = (String) uploadResult.get("secure_url");

        tour.setThumbnailUrl(thumbnailUrl);
        Tour savedTour = tourRepository.save(tour);
        log.info("Đã upload thumbnail cho Tour ID: {}", savedTour.getTourId());

        return toDTO(savedTour);
    }

    public TourDTO deleteThumbnail(Integer tourId) throws IOException {
        log.debug("Xóa thumbnail cho Tour ID: {}", tourId);
        Tour tour = tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));

        if (tour.getThumbnailUrl() != null && !tour.getThumbnailUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImage(tour.getThumbnailUrl());
                log.info("Đã xóa thumbnail trên Cloudinary");
            } catch (IOException e) {
                log.error("Lỗi khi xóa thumbnail trên Cloudinary: {}", e.getMessage());
            }
        }

        tour.setThumbnailUrl(null);
        Tour savedTour = tourRepository.save(tour);
        log.info("Đã xóa thumbnail cho Tour ID: {}", savedTour.getTourId());

        return toDTO(savedTour);
    }

    public TourDTO addImages(Integer tourId, List<MultipartFile> files) throws IOException {
        log.debug("Thêm {} ảnh cho Tour ID: {}", files.size(), tourId);
        Tour tour = tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));

        List<String> currentImageUrls = jsonToStringList(tour.getImageUrls());
        List<String> newImageUrls = new ArrayList<>(currentImageUrls);

        for (MultipartFile file : files) {
            Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
            String imageUrl = (String) uploadResult.get("secure_url");
            newImageUrls.add(imageUrl);
        }

        tour.setImageUrls(stringListToJson(newImageUrls));
        Tour savedTour = tourRepository.save(tour);
        log.info("Đã thêm {} ảnh cho Tour ID: {}", files.size(), savedTour.getTourId());

        return toDTO(savedTour);
    }

    public TourDTO deleteImage(Integer tourId, String imageUrl) throws IOException {
        log.debug("Xóa ảnh cho Tour ID: {}", tourId);
        Tour tour = tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));

        List<String> currentImageUrls = jsonToStringList(tour.getImageUrls());

        if (currentImageUrls.contains(imageUrl)) {
            try {
                cloudinaryService.deleteImage(imageUrl);
                log.info("Đã xóa ảnh trên Cloudinary");
            } catch (IOException e) {
                log.error("Lỗi khi xóa ảnh trên Cloudinary: {}", e.getMessage());
            }

            currentImageUrls.remove(imageUrl);
            tour.setImageUrls(stringListToJson(currentImageUrls));
            Tour savedTour = tourRepository.save(tour);
            log.info("Đã xóa ảnh cho Tour ID: {}", savedTour.getTourId());

            return toDTO(savedTour);
        } else {
            throw new ResourceNotFoundException("Không tìm thấy ảnh với URL: " + imageUrl);
        }
    }

    public TourDTO deleteAllImages(Integer tourId) throws IOException {
        log.debug("Xóa tất cả ảnh cho Tour ID: {}", tourId);
        Tour tour = tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));

        List<String> currentImageUrls = jsonToStringList(tour.getImageUrls());

        for (String imageUrl : currentImageUrls) {
            try {
                cloudinaryService.deleteImage(imageUrl);
            } catch (IOException e) {
                log.error("Lỗi khi xóa ảnh trên Cloudinary: {}", e.getMessage());
            }
        }

        tour.setImageUrls(null);
        Tour savedTour = tourRepository.save(tour);
        log.info("Đã xóa tất cả ảnh cho Tour ID: {}", savedTour.getTourId());

        return toDTO(savedTour);
    }

    // ==================== JSON HELPER METHODS ====================

    /**
     * Convert List<String> thành JSON string cho imageUrls
     */
    private String stringListToJson(List<String> list) {
        if (list == null || list.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(list);
        } catch (JsonProcessingException e) {
            log.error("Error converting string list to JSON: {}", list, e);
            return null;
        }
    }

    /**
     * Convert JSON string thành List<String> cho imageUrls
     */
    private List<String> jsonToStringList(String json) {
        if (json == null || json.trim().isEmpty()) {
            return new ArrayList<>();
        }
        try {
            List<String> list = objectMapper.readValue(json, new com.fasterxml.jackson.core.type.TypeReference<List<String>>() {});
            return list != null ? list : new ArrayList<>();
        } catch (JsonProcessingException e) {
            log.error("Error converting JSON to string list: {}", json, e);
            return new ArrayList<>();
        }
    }
}
