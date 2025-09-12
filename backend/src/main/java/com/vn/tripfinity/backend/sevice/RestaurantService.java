package com.vn.tripfinity.backend.sevice;

import com.vn.tripfinity.backend.dto.RestaurantDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.Restaurant;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.RestaurantRepository;
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

        Restaurant entity = Restaurant.builder()
                .restaurantId(null)
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

    private RestaurantDTO toDTO(Restaurant r) {
        return RestaurantDTO.builder()
                .restaurantId(r.getRestaurantId())
                .providerId(r.getProvider() != null ? r.getProvider().getProviderId() : null)
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
