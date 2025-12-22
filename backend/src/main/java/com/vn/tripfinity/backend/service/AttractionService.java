package com.vn.tripfinity.backend.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
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
import com.vn.tripfinity.backend.dto.AttractionDTO;
import com.vn.tripfinity.backend.dto.AttractionRatingSummaryDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Area;
import com.vn.tripfinity.backend.model.Attraction;
import com.vn.tripfinity.backend.model.AttractionReview;
import com.vn.tripfinity.backend.model.AttractionReviewAspects;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.repository.AreaRepository;
import com.vn.tripfinity.backend.repository.AttractionRepository;
import com.vn.tripfinity.backend.repository.AttractionReviewAspectsRepository;
import com.vn.tripfinity.backend.repository.AttractionReviewRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.service.cloudinary.CloudinaryService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AttractionService {

    private final AttractionRepository attractionRepository;
    private final AttractionReviewRepository attractionReviewRepository;
    private final AttractionReviewAspectsRepository attractionReviewAspectsRepository;
    private final ProviderRepository providerRepository;
    private final AreaRepository areaRepository;
    private final NotificationService notificationService;
    private final CloudinaryService cloudinaryService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public List<AttractionDTO> getAll() {
        return attractionRepository.findAll().stream().map(this::toDTO).collect(Collectors.toList());
    }

    public AttractionDTO getById(Integer id) {
        Attraction a = attractionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + id));
        return toDTO(a);
    }

    public List<AttractionDTO> getByProviderId(Integer providerId) {
        return attractionRepository.findByProvider_ProviderId(providerId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public AttractionDTO create(AttractionDTO dto) {
        Provider provider = providerRepository.findById(dto.getProviderId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
        Area area = areaRepository.findById(dto.getAreaId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + dto.getAreaId()));

        // Xác định attractionStatus và publishedAt
        Attraction.AttractionStatus attractionStatus = dto.getAttractionStatus() != null
                ? Attraction.AttractionStatus.valueOf(dto.getAttractionStatus())
                : Attraction.AttractionStatus.published;
        LocalDateTime publishedAt = determinePublishedAt(attractionStatus, null);

        Attraction entity = Attraction.builder()
                .attractionId(null)
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
                .badges(joinList(dto.getBadges()))
                .attractionStatus(attractionStatus)
                .visibility(dto.getVisibility() != null
                        ? Attraction.Visibility.valueOf(dto.getVisibility())
                        : Attraction.Visibility.public_)
                .isFeatured(dto.getIsFeatured() != null && dto.getIsFeatured())
                .attractionType(dto.getAttractionType() != null
                        ? Attraction.AttractionType.valueOf(dto.getAttractionType())
                        : null)
                .averageVisitMinutes(dto.getAverageVisitMinutes())
                .visitTypesJson(writeJson(dto.getVisitTypesJson()))
                .availableTimesJson(writeJson(dto.getAvailableTimesJson()))
                .suitableForJson(writeJson(dto.getSuitableForJson()))
                .featuresJson(writeJson(dto.getFeaturesJson()))
                .openingHoursJson(writeJson(dto.getOpeningHoursJson()))
                .highlightsJson(writeJson(dto.getHighlightsJson()))
                .tipsText(dto.getTipsText())
                .policiesText(dto.getPoliciesText())
                .slug(dto.getSlug())
                .seoTitle(dto.getSeoTitle())
                .seoDescription(dto.getSeoDescription())
                .publishedAt(publishedAt)
                .build();

        Attraction saved = attractionRepository.save(entity);
        log.info("Tạo Attraction ID: {}", saved.getAttractionId());
        
        // 📬 GỬI THÔNG BÁO CHO SUPPLIER
        try {
            if (provider != null && provider.getUser() != null) {
                Integer userId = provider.getUser().getUserId();
                notificationService.notifyAttractionCreated(userId, saved.getTitle());
                log.info("📬 Attraction created notification sent to userId: {}", userId);
            }
        } catch (Exception e) {
            log.error("❌ Failed to send attraction created notification: {}", e.getMessage());
        }
        
        return toDTO(saved);
    }

    public AttractionDTO update(Integer id, AttractionDTO dto) {
        Attraction existing = attractionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + id));

        if (dto.getProviderId() != null && (existing.getProvider() == null
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
            existing.setBadges(joinList(dto.getBadges()));
        if (dto.getAttractionStatus() != null) {
            Attraction.AttractionStatus oldStatus = existing.getAttractionStatus();
            Attraction.AttractionStatus newStatus = Attraction.AttractionStatus.valueOf(dto.getAttractionStatus());
            LocalDateTime oldPublishedAt = existing.getPublishedAt();
            
            existing.setAttractionStatus(newStatus);
            
            if (oldStatus != newStatus) {
                LocalDateTime newPublishedAt = determinePublishedAt(newStatus, oldPublishedAt);
                existing.setPublishedAt(newPublishedAt);
                log.info("🔄 Attraction {} status thay đổi từ {} -> {}, publishedAt: {} -> {}",
                        existing.getAttractionId(), oldStatus, newStatus, oldPublishedAt, newPublishedAt);
            }
        }
        if (dto.getVisibility() != null)
            existing.setVisibility(Attraction.Visibility.valueOf(dto.getVisibility()));
        if (dto.getIsFeatured() != null)
            existing.setIsFeatured(dto.getIsFeatured());
        if (dto.getAttractionType() != null)
            existing.setAttractionType(Attraction.AttractionType.valueOf(dto.getAttractionType()));
        if (dto.getAverageVisitMinutes() != null)
            existing.setAverageVisitMinutes(dto.getAverageVisitMinutes());
        if (dto.getVisitTypesJson() != null)
            existing.setVisitTypesJson(writeJson(dto.getVisitTypesJson()));
        if (dto.getAvailableTimesJson() != null)
            existing.setAvailableTimesJson(writeJson(dto.getAvailableTimesJson()));
        if (dto.getSuitableForJson() != null)
            existing.setSuitableForJson(writeJson(dto.getSuitableForJson()));
        if (dto.getFeaturesJson() != null)
            existing.setFeaturesJson(writeJson(dto.getFeaturesJson()));
        if (dto.getOpeningHoursJson() != null)
            existing.setOpeningHoursJson(writeJson(dto.getOpeningHoursJson()));
        if (dto.getHighlightsJson() != null)
            existing.setHighlightsJson(writeJson(dto.getHighlightsJson()));
        if (dto.getTipsText() != null)
            existing.setTipsText(dto.getTipsText());
        if (dto.getPoliciesText() != null)
            existing.setPoliciesText(dto.getPoliciesText());
        if (dto.getSlug() != null)
            existing.setSlug(dto.getSlug());
        if (dto.getSeoTitle() != null)
            existing.setSeoTitle(dto.getSeoTitle());
        if (dto.getSeoDescription() != null)
            existing.setSeoDescription(dto.getSeoDescription());
        if (dto.getPublishedAt() != null)
            existing.setPublishedAt(dto.getPublishedAt());

        Attraction saved = attractionRepository.save(existing);
        
        // 📬 GỬI THÔNG BÁO CHO SUPPLIER
        try {
            if (saved.getProvider() != null && saved.getProvider().getUser() != null) {
                Integer userId = saved.getProvider().getUser().getUserId();
                notificationService.notifyAttractionUpdated(userId, saved.getTitle());
                log.info("📬 Attraction updated notification sent to userId: {}", userId);
            }
        } catch (Exception e) {
            log.error("❌ Failed to send attraction updated notification: {}", e.getMessage());
        }
        
        return toDTO(saved);
    }

    public void delete(Integer id) {
        Attraction existing = attractionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + id));
        attractionRepository.delete(existing);
        log.info("Đã xóa Attraction id: {}", id);
    }

    private AttractionDTO toDTO(Attraction a) {
        return AttractionDTO.builder()
                .attractionId(a.getAttractionId())
                .providerId(a.getProvider() != null ? a.getProvider().getProviderId() : null)
                .areaId(a.getArea() != null ? a.getArea().getAreaId() : null)
                .title(a.getTitle())
                .serviceDescription(a.getServiceDescription())
                .location(a.getLocation())
                .address(a.getAddress())
                .latitude(a.getLatitude())
                .longitude(a.getLongitude())
                .startDate(a.getStartDate())
                .endDate(a.getEndDate())
                .price(a.getPrice())
                .currencyCode(a.getCurrencyCode())
                .capacity(a.getCapacity())
                .minParticipants(a.getMinParticipants())
                .maxParticipants(a.getMaxParticipants())
                .thumbnailUrl(a.getThumbnailUrl())
                .imageUrls(readJsonListString(a.getImageUrls()))
                .badges(splitList(a.getBadges()))
                .attractionStatus(a.getAttractionStatus() != null ? a.getAttractionStatus().name() : null)
                .visibility(a.getVisibility() != null ? a.getVisibility().name() : null)
                .isFeatured(a.getIsFeatured())
                .attractionType(a.getAttractionType() != null ? a.getAttractionType().name() : null)
                .averageVisitMinutes(a.getAverageVisitMinutes())
                .visitTypesJson(readJsonListString(a.getVisitTypesJson()))
                .availableTimesJson(readJsonListString(a.getAvailableTimesJson()))
                .suitableForJson(readJsonListString(a.getSuitableForJson()))
                .featuresJson(readJsonListInteger(a.getFeaturesJson()))
                .openingHoursJson(readJsonObject(a.getOpeningHoursJson()))
                .highlightsJson(readJsonListInteger(a.getHighlightsJson()))
                .tipsText(a.getTipsText())
                .policiesText(a.getPoliciesText())
                .slug(a.getSlug())
                .seoTitle(a.getSeoTitle())
                .seoDescription(a.getSeoDescription())
                .publishedAt(a.getPublishedAt())
                .ratingAverage(null) // Chưa có review system cho attraction
                .createdAt(a.getCreatedAt())
                .updatedAt(a.getUpdatedAt())
                .build();
    }

    /**
     * Xác định publishedAt dựa trên attractionStatus
     */
    private LocalDateTime determinePublishedAt(Attraction.AttractionStatus status, LocalDateTime currentPublishedAt) {
        return switch (status) {
            case published -> currentPublishedAt == null ? LocalDateTime.now() : currentPublishedAt;
            case archived, disabled -> null;
        };
    }

    private String joinList(List<String> list) {
        if (list == null || list.isEmpty())
            return null;
        return String.join(",", list);
    }

    private List<String> splitList(String csv) {
        if (csv == null || csv.trim().isEmpty())
            return null;
        String[] arr = csv.split(",");
        List<String> out = new ArrayList<>();
        for (String s : arr) {
            String v = s.trim();
            if (!v.isEmpty())
                out.add(v);
        }
        return out;
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
            // Try JSON format first
            return objectMapper.readValue(json, List.class);
        } catch (JsonProcessingException e) {
            // Fallback to CSV format for legacy data
            log.debug("Parse JSON failed, trying CSV format: {}", json);
            return splitList(json);
        }
    }

    @SuppressWarnings("unchecked")
    private List<Integer> readJsonListInteger(String json) {
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

    // ==================== IMAGE MANAGEMENT ====================

    public AttractionDTO uploadThumbnail(Integer attractionId, MultipartFile file) throws IOException {
        log.debug("Upload thumbnail cho Attraction ID: {}", attractionId);
        Attraction attraction = attractionRepository.findById(attractionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + attractionId));

        // Xóa thumbnail cũ nếu có
        if (attraction.getThumbnailUrl() != null && !attraction.getThumbnailUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImage(attraction.getThumbnailUrl());
                log.info("Đã xóa thumbnail cũ trên Cloudinary");
            } catch (Exception e) {
                log.error("Lỗi khi xóa thumbnail cũ: {}", e.getMessage());
            }
        }

        // Upload thumbnail mới
        Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
        String thumbnailUrl = (String) uploadResult.get("secure_url");

        attraction.setThumbnailUrl(thumbnailUrl);
        Attraction savedAttraction = attractionRepository.save(attraction);
        log.info("Đã upload thumbnail cho Attraction ID: {}", savedAttraction.getAttractionId());

        return toDTO(savedAttraction);
    }

    public AttractionDTO deleteThumbnail(Integer attractionId) throws IOException {
        log.debug("Xóa thumbnail cho Attraction ID: {}", attractionId);
        Attraction attraction = attractionRepository.findById(attractionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + attractionId));

        if (attraction.getThumbnailUrl() != null && !attraction.getThumbnailUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImage(attraction.getThumbnailUrl());
                log.info("Đã xóa thumbnail trên Cloudinary");
            } catch (Exception e) {
                log.error("Lỗi khi xóa thumbnail trên Cloudinary: {}", e.getMessage());
            }
        }

        attraction.setThumbnailUrl(null);
        Attraction savedAttraction = attractionRepository.save(attraction);
        log.info("Đã xóa thumbnail cho Attraction ID: {}", savedAttraction.getAttractionId());

        return toDTO(savedAttraction);
    }

    public AttractionDTO addImages(Integer attractionId, List<MultipartFile> files) throws IOException {
        log.debug("Thêm {} ảnh cho Attraction ID: {}", files.size(), attractionId);
        Attraction attraction = attractionRepository.findById(attractionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + attractionId));

        List<String> currentImageUrls = readJsonListString(attraction.getImageUrls());
        if (currentImageUrls == null) {
            currentImageUrls = new ArrayList<>();
        }
        List<String> newImageUrls = new ArrayList<>(currentImageUrls);

        for (MultipartFile file : files) {
            Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
            String imageUrl = (String) uploadResult.get("secure_url");
            newImageUrls.add(imageUrl);
        }

        attraction.setImageUrls(writeJson(newImageUrls));
        Attraction savedAttraction = attractionRepository.save(attraction);
        log.info("Đã thêm {} ảnh cho Attraction ID: {}", files.size(), savedAttraction.getAttractionId());

        return toDTO(savedAttraction);
    }

    public AttractionDTO deleteImage(Integer attractionId, String imageUrl) throws IOException {
        log.debug("Xóa ảnh cho Attraction ID: {} - URL: {}", attractionId, imageUrl);
        Attraction attraction = attractionRepository.findById(attractionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + attractionId));

        List<String> imageUrls = readJsonListString(attraction.getImageUrls());
        if (imageUrls != null && imageUrls.contains(imageUrl)) {
            try {
                cloudinaryService.deleteImage(imageUrl);
                log.info("Đã xóa ảnh trên Cloudinary");
            } catch (Exception e) {
                log.error("Lỗi khi xóa ảnh trên Cloudinary: {}", e.getMessage());
            }

            imageUrls.remove(imageUrl);
            attraction.setImageUrls(writeJson(imageUrls));
            Attraction savedAttraction = attractionRepository.save(attraction);
            log.info("Đã xóa ảnh cho Attraction ID: {}", savedAttraction.getAttractionId());

            return toDTO(savedAttraction);
        }

        log.warn("Ảnh không tồn tại trong Attraction ID: {}", attractionId);
        return toDTO(attraction);
    }

    // ==================== RATING SUMMARY ====================
    
    /**
     * Tính rating summary cho một attraction (tương tự HotelService)
     * Thay thế cho việc lưu DB
     */
    public AttractionRatingSummaryDTO calculateRatingSummary(Integer attractionId) {
        log.debug("Tính rating summary cho Attraction ID: {}", attractionId);

        // Lấy tất cả reviews đã approved của attraction
        List<AttractionReview> reviews = attractionReviewRepository.findByAttractionAndStatus(
            attractionId, AttractionReview.ReviewStatus.approved);

        AttractionRatingSummaryDTO summary = AttractionRatingSummaryDTO.builder()
            .attractionId(attractionId)
            .totalReviews(reviews.size())
            .build();

        if (reviews.isEmpty()) {
            // Không có review, trả về giá trị mặc định
            summary.setAvgRating(BigDecimal.ZERO);
            summary.setCount1(0);
            summary.setCount2(0);
            summary.setCount3(0);
            summary.setCount4(0);
            summary.setCount5(0);
            return summary;
        }

        // Tính avg rating tổng thể
        double avgRating = reviews.stream()
            .mapToInt(AttractionReview::getRating)
            .average()
            .orElse(0.0);
        summary.setAvgRating(BigDecimal.valueOf(avgRating).setScale(2, RoundingMode.HALF_UP));

        // Đếm số lượng từng loại rating
        summary.setCount1((int) reviews.stream().filter(r -> r.getRating() == 1).count());
        summary.setCount2((int) reviews.stream().filter(r -> r.getRating() == 2).count());
        summary.setCount3((int) reviews.stream().filter(r -> r.getRating() == 3).count());
        summary.setCount4((int) reviews.stream().filter(r -> r.getRating() == 4).count());
        summary.setCount5((int) reviews.stream().filter(r -> r.getRating() == 5).count());

        // Tính trung bình các aspects
        List<Integer> reviewIds = reviews.stream()
            .map(AttractionReview::getReviewId)
            .collect(Collectors.toList());

        List<AttractionReviewAspects> aspects = attractionReviewAspectsRepository.findAllById(reviewIds);

        if (!aspects.isEmpty()) {
            // beauty -> avgExperience
            double avgExperience = aspects.stream()
                .filter(a -> a.getBeauty() != null)
                .mapToInt(AttractionReviewAspects::getBeauty)
                .average()
                .orElse(0.0);
            summary.setAvgExperience(BigDecimal.valueOf(avgExperience).setScale(2, RoundingMode.HALF_UP));

            // price -> avgValueForMoney
            double avgValueForMoney = aspects.stream()
                .filter(a -> a.getPrice() != null)
                .mapToInt(AttractionReviewAspects::getPrice)
                .average()
                .orElse(0.0);
            summary.setAvgValueForMoney(BigDecimal.valueOf(avgValueForMoney).setScale(2, RoundingMode.HALF_UP));

            // accessibility -> avgAccessibility
            double avgAccessibility = aspects.stream()
                .filter(a -> a.getAccessibility() != null)
                .mapToInt(AttractionReviewAspects::getAccessibility)
                .average()
                .orElse(0.0);
            summary.setAvgAccessibility(BigDecimal.valueOf(avgAccessibility).setScale(2, RoundingMode.HALF_UP));

            // facilities -> avgFacilities
            double avgFacilities = aspects.stream()
                .filter(a -> a.getFacilities() != null)
                .mapToInt(AttractionReviewAspects::getFacilities)
                .average()
                .orElse(0.0);
            summary.setAvgFacilities(BigDecimal.valueOf(avgFacilities).setScale(2, RoundingMode.HALF_UP));

            // culture -> avgStaff
            double avgStaff = aspects.stream()
                .filter(a -> a.getCulture() != null)
                .mapToInt(AttractionReviewAspects::getCulture)
                .average()
                .orElse(0.0);
            summary.setAvgStaff(BigDecimal.valueOf(avgStaff).setScale(2, RoundingMode.HALF_UP));
        }

        log.info("✅ Đã tính rating summary cho Attraction ID: {} với {} reviews", attractionId, reviews.size());
        return summary;
    }
}
