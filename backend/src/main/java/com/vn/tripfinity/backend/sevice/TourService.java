package com.vn.tripfinity.backend.sevice;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vn.tripfinity.backend.dto.TourDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.Tour;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.TourRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class TourService {

    private final TourRepository tourRepository;
    private final ProviderRepository providerRepository;
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

        Tour entity = Tour.builder()
                .tourId(null)
                .provider(provider)
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
                .tourStatus(dto.getTourStatus() != null ? Tour.TourStatus.valueOf(dto.getTourStatus())
                        : Tour.TourStatus.published)
                .itineraryOverview(dto.getItineraryOverview())
                .meetingPoint(dto.getMeetingPoint())
                .guideLanguage(joinList(dto.getGuideLanguage()))
                .inclusiveItems(joinList(dto.getInclusiveItems()))
                .exclusiveItems(joinList(dto.getExclusiveItems()))
                .cancellationPolicy(dto.getCancellationPolicy())
                .difficultyLevel(
                        dto.getDifficultyLevel() != null ? Tour.DifficultyLevel.valueOf(dto.getDifficultyLevel())
                                : null)
                .durationDays(dto.getDurationDays())
                .departureLocation(dto.getDepartureLocation())
                .includedJson(writeJson(dto.getIncluded()))
                .excludedJson(writeJson(dto.getExcluded()))
                .build();

        Tour saved = tourRepository.save(entity);
        log.info("Tạo Tour ID: {}", saved.getTourId());
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
        if (dto.getTourStatus() != null)
            existing.setTourStatus(Tour.TourStatus.valueOf(dto.getTourStatus()));
        if (dto.getItineraryOverview() != null)
            existing.setItineraryOverview(dto.getItineraryOverview());
        if (dto.getMeetingPoint() != null)
            existing.setMeetingPoint(dto.getMeetingPoint());
        if (dto.getGuideLanguage() != null)
            existing.setGuideLanguage(joinList(dto.getGuideLanguage()));
        if (dto.getInclusiveItems() != null)
            existing.setInclusiveItems(joinList(dto.getInclusiveItems()));
        if (dto.getExclusiveItems() != null)
            existing.setExclusiveItems(joinList(dto.getExclusiveItems()));
        if (dto.getCancellationPolicy() != null)
            existing.setCancellationPolicy(dto.getCancellationPolicy());
        if (dto.getDifficultyLevel() != null)
            existing.setDifficultyLevel(Tour.DifficultyLevel.valueOf(dto.getDifficultyLevel()));
        if (dto.getDurationDays() != null)
            existing.setDurationDays(dto.getDurationDays());
        if (dto.getDepartureLocation() != null)
            existing.setDepartureLocation(dto.getDepartureLocation());
        if (dto.getIncluded() != null)
            existing.setIncludedJson(writeJson(dto.getIncluded()));
        if (dto.getExcluded() != null)
            existing.setExcludedJson(writeJson(dto.getExcluded()));

        Tour saved = tourRepository.save(existing);
        return toDTO(saved);
    }

    public void deleteTour(Integer tourId) {
        Tour existing = tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));
        tourRepository.delete(existing);
        log.info("Đã xóa Tour id: {}", tourId);
    }

    private TourDTO toDTO(Tour t) {
        return TourDTO.builder()
                .tourId(t.getTourId())
                .providerId(t.getProvider() != null ? t.getProvider().getProviderId() : null)
                .title(t.getTitle())
                .serviceDescription(t.getServiceDescription())
                .location(t.getLocation())
                .startDate(t.getStartDate())
                .endDate(t.getEndDate())
                .price(t.getPrice())
                .currencyCode(t.getCurrencyCode())
                .capacity(t.getCapacity())
                .minParticipants(t.getMinParticipants())
                .maxParticipants(t.getMaxParticipants())
                .thumbnailUrl(t.getThumbnailUrl())
                .imageUrls(splitList(t.getImageUrls()))
                .ratingAverage(t.getRatingAverage())
                .badges(splitList(t.getBadges()))
                .tourStatus(t.getTourStatus() != null ? t.getTourStatus().name() : null)
                .itineraryOverview(t.getItineraryOverview())
                .meetingPoint(t.getMeetingPoint())
                .guideLanguage(splitList(t.getGuideLanguage()))
                .inclusiveItems(splitList(t.getInclusiveItems()))
                .exclusiveItems(splitList(t.getExclusiveItems()))
                .cancellationPolicy(t.getCancellationPolicy())
                .difficultyLevel(t.getDifficultyLevel() != null ? t.getDifficultyLevel().name() : null)
                .durationDays(t.getDurationDays())
                .departureLocation(t.getDepartureLocation())
                .included(readJsonList(t.getIncludedJson()))
                .excluded(readJsonList(t.getExcludedJson()))
                .createdAt(t.getCreatedAt())
                .updatedAt(t.getUpdatedAt())
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
}
