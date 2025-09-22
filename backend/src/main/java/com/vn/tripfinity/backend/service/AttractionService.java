package com.vn.tripfinity.backend.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vn.tripfinity.backend.dto.AttractionDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Attraction;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.Area;
import com.vn.tripfinity.backend.repository.AttractionRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.AreaRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AttractionService {

    private final AttractionRepository attractionRepository;
    private final ProviderRepository providerRepository;
    private final AreaRepository areaRepository;
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

        Attraction entity = Attraction.builder()
                .attractionId(null)
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
                .attractionStatus(dto.getAttractionStatus() != null
                        ? Attraction.AttractionStatus.valueOf(dto.getAttractionStatus())
                        : Attraction.AttractionStatus.published)
                .address(dto.getAddress())
                .coordinates(dto.getCoordinates())
                .averageVisitMinutes(dto.getAverageVisitMinutes())
                .visitTypesJson(writeJson(dto.getVisitTypesJson()))
                .availableTimesJson(writeJson(dto.getAvailableTimesJson()))
                .suitableForJson(writeJson(dto.getSuitableForJson()))
                .featuresJson(writeJson(dto.getFeaturesJson()))
                .openingHoursJson(writeJson(dto.getOpeningHoursJson()))
                .highlightsJson(writeJson(dto.getHighlightsJson()))
                .tipsText(dto.getTipsText())
                .build();

        Attraction saved = attractionRepository.save(entity);
        log.info("Tạo Attraction ID: {}", saved.getAttractionId());
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
        if (dto.getAttractionStatus() != null)
            existing.setAttractionStatus(Attraction.AttractionStatus.valueOf(dto.getAttractionStatus()));
        if (dto.getAddress() != null)
            existing.setAddress(dto.getAddress());
        if (dto.getCoordinates() != null)
            existing.setCoordinates(dto.getCoordinates());
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

        Attraction saved = attractionRepository.save(existing);
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
                .startDate(a.getStartDate())
                .endDate(a.getEndDate())
                .price(a.getPrice())
                .currencyCode(a.getCurrencyCode())
                .capacity(a.getCapacity())
                .minParticipants(a.getMinParticipants())
                .maxParticipants(a.getMaxParticipants())
                .thumbnailUrl(a.getThumbnailUrl())
                .imageUrls(splitList(a.getImageUrls()))
                .ratingAverage(a.getRatingAverage())
                .badges(splitList(a.getBadges()))
                .attractionStatus(a.getAttractionStatus() != null ? a.getAttractionStatus().name() : null)
                .address(a.getAddress())
                .coordinates(a.getCoordinates())
                .averageVisitMinutes(a.getAverageVisitMinutes())
                .visitTypesJson(readJsonList(a.getVisitTypesJson()))
                .availableTimesJson(readJsonObject(a.getAvailableTimesJson()))
                .suitableForJson(readJsonList(a.getSuitableForJson()))
                .featuresJson(readJsonList(a.getFeaturesJson()))
                .openingHoursJson(readJsonObject(a.getOpeningHoursJson()))
                .highlightsJson(readJsonList(a.getHighlightsJson()))
                .tipsText(a.getTipsText())
                .createdAt(a.getCreatedAt())
                .updatedAt(a.getUpdatedAt())
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

    private Object readJsonObject(String json) {
        if (json == null || json.isEmpty())
            return null;
        try {
            return objectMapper.readValue(json, Object.class);
        } catch (Exception e) {
            log.warn("Không thể parse JSON object: {}", json, e);
            return null;
        }
    }
}
