package com.vn.tripfinity.backend.sevice;

import com.vn.tripfinity.backend.dto.HotelDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
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
public class HotelService {

    private final HotelRepository hotelRepository;
    private final ProviderRepository providerRepository;

    public List<HotelDTO> getAllHotels() {
        return hotelRepository.findAll().stream().map(this::toDTO).collect(Collectors.toList());
    }

    public HotelDTO getHotelById(Integer hotelId) {
        Hotel h = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));
        return toDTO(h);
    }

    public List<HotelDTO> getHotelsByProviderId(Integer providerId) {
        return hotelRepository.findByProvider_ProviderId(providerId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public HotelDTO createHotel(HotelDTO dto) {
        Provider provider = providerRepository.findById(dto.getProviderId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));

        Hotel entity = Hotel.builder()
                .hotelId(null)
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
                .imageUrls(dto.getImageUrls())
                .ratingAverage(dto.getRatingAverage() != null ? dto.getRatingAverage() : new BigDecimal("0.00"))
                .badges(dto.getBadges())
                .hotelStatus(dto.getHotelStatus() != null ? Hotel.HotelStatus.valueOf(dto.getHotelStatus())
                        : Hotel.HotelStatus.published)
                .starRating(dto.getStarRating())
                .propertyType(dto.getPropertyType() != null ? Hotel.PropertyType.valueOf(dto.getPropertyType())
                        : Hotel.PropertyType.hotel)
                .address(dto.getAddress())
                .checkinTime(dto.getCheckinTime())
                .checkoutTime(dto.getCheckoutTime())
                .highlightsJson(dto.getHighlightsJson())
                .amenitiesJson(dto.getAmenitiesJson())
                .policiesText(dto.getPoliciesText())
                .build();

        Hotel saved = hotelRepository.save(entity);
        log.info("Tạo Hotel ID: {}", saved.getHotelId());
        return toDTO(saved);
    }

    public HotelDTO updateHotel(Integer hotelId, HotelDTO dto) {
        Hotel existing = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

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
            existing.setImageUrls(dto.getImageUrls());
        if (dto.getRatingAverage() != null)
            existing.setRatingAverage(dto.getRatingAverage());
        if (dto.getBadges() != null)
            existing.setBadges(dto.getBadges());
        if (dto.getHotelStatus() != null)
            existing.setHotelStatus(Hotel.HotelStatus.valueOf(dto.getHotelStatus()));
        if (dto.getStarRating() != null)
            existing.setStarRating(dto.getStarRating());
        if (dto.getPropertyType() != null)
            existing.setPropertyType(Hotel.PropertyType.valueOf(dto.getPropertyType()));
        if (dto.getAddress() != null)
            existing.setAddress(dto.getAddress());
        if (dto.getCheckinTime() != null)
            existing.setCheckinTime(dto.getCheckinTime());
        if (dto.getCheckoutTime() != null)
            existing.setCheckoutTime(dto.getCheckoutTime());
        if (dto.getHighlightsJson() != null)
            existing.setHighlightsJson(dto.getHighlightsJson());
        if (dto.getAmenitiesJson() != null)
            existing.setAmenitiesJson(dto.getAmenitiesJson());
        if (dto.getPoliciesText() != null)
            existing.setPoliciesText(dto.getPoliciesText());

        Hotel saved = hotelRepository.save(existing);
        return toDTO(saved);
    }

    public void deleteHotel(Integer hotelId) {
        Hotel existing = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));
        hotelRepository.delete(existing);
        log.info("Đã xóa Hotel id: {}", hotelId);
    }

    private HotelDTO toDTO(Hotel h) {
        return HotelDTO.builder()
                .hotelId(h.getHotelId())
                .providerId(h.getProvider() != null ? h.getProvider().getProviderId() : null)
                .title(h.getTitle())
                .serviceDescription(h.getServiceDescription())
                .location(h.getLocation())
                .startDate(h.getStartDate())
                .endDate(h.getEndDate())
                .price(h.getPrice())
                .currencyCode(h.getCurrencyCode())
                .capacity(h.getCapacity())
                .minParticipants(h.getMinParticipants())
                .maxParticipants(h.getMaxParticipants())
                .thumbnailUrl(h.getThumbnailUrl())
                .imageUrls(h.getImageUrls())
                .ratingAverage(h.getRatingAverage())
                .badges(h.getBadges())
                .hotelStatus(h.getHotelStatus() != null ? h.getHotelStatus().name() : null)
                .starRating(h.getStarRating())
                .propertyType(h.getPropertyType() != null ? h.getPropertyType().name() : null)
                .address(h.getAddress())
                .checkinTime(h.getCheckinTime())
                .checkoutTime(h.getCheckoutTime())
                .highlightsJson(h.getHighlightsJson())
                .amenitiesJson(h.getAmenitiesJson())
                .policiesText(h.getPoliciesText())
                .createdAt(h.getCreatedAt())
                .updatedAt(h.getUpdatedAt())
                .build();
    }
}