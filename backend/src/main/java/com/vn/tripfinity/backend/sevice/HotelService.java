package com.vn.tripfinity.backend.sevice;

import com.vn.tripfinity.backend.dto.HotelDTO;
import com.vn.tripfinity.backend.dto.HotelReviewDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.HotelReview;
import com.vn.tripfinity.backend.model.HotelReviewAspects;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.HotelReviewRepository;
import com.vn.tripfinity.backend.repository.HotelReviewAspectsRepository;
import com.vn.tripfinity.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelService {

    private final HotelRepository hotelRepository;
    private final ProviderRepository providerRepository;
    private final HotelReviewRepository hotelReviewRepository;
    private final HotelReviewAspectsRepository hotelReviewAspectsRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

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
                .imageUrls(joinList(dto.getImageUrls()))
                .ratingAverage(dto.getRatingAverage() != null ? dto.getRatingAverage() : new BigDecimal("0.00"))
                .badges(joinList(dto.getBadges()))
                .hotelStatus(dto.getHotelStatus() != null ? Hotel.HotelStatus.valueOf(dto.getHotelStatus())
                        : Hotel.HotelStatus.published)
                .starRating(dto.getStarRating())
                .propertyType(dto.getPropertyType() != null ? Hotel.PropertyType.valueOf(dto.getPropertyType())
                        : Hotel.PropertyType.hotel)
                .address(dto.getAddress())
                .checkinTime(dto.getCheckinTime())
                .checkoutTime(dto.getCheckoutTime())
                .highlightsJson(writeJson(dto.getHighlightsJson()))
                .amenitiesJson(writeJson(dto.getAmenitiesJson()))
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
            existing.setImageUrls(joinList(dto.getImageUrls()));
        if (dto.getRatingAverage() != null)
            existing.setRatingAverage(dto.getRatingAverage());
        if (dto.getBadges() != null)
            existing.setBadges(joinList(dto.getBadges()));
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
            existing.setHighlightsJson(writeJson(dto.getHighlightsJson()));
        if (dto.getAmenitiesJson() != null)
            existing.setAmenitiesJson(writeJson(dto.getAmenitiesJson()));
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

    // ============ Reviews ============
    public HotelReviewDTO createHotelReview(HotelReviewDTO dto) {
        Hotel hotel = hotelRepository.findById(dto.getHotelId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + dto.getHotelId()));
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        HotelReview review = HotelReview.builder()
                .reviewId(null)
                .hotel(hotel)
                .user(user)
                .rating(dto.getRating())
                .title(dto.getTitle())
                .content(dto.getContent())
                .imageUrls(joinList(dto.getImageUrls()))
                .likesCount(dto.getLikesCount() != null ? dto.getLikesCount() : 0)
                .replyCount(dto.getReplyCount() != null ? dto.getReplyCount() : 0)
                .reviewStatus(dto.getReviewStatus() != null ? HotelReview.ReviewStatus.valueOf(dto.getReviewStatus())
                        : HotelReview.ReviewStatus.approved)
                .build();

        HotelReview saved = hotelReviewRepository.save(review);

        if (dto.getAspects() != null) {
            HotelReviewAspects aspects = HotelReviewAspects.builder()
                    .review(saved)
                    .cleanliness(dto.getAspects().getCleanliness())
                    .service(dto.getAspects().getService())
                    .valueForMoney(dto.getAspects().getValueForMoney())
                    .location(dto.getAspects().getLocation())
                    .facilities(dto.getAspects().getFacilities())
                    .build();
            hotelReviewAspectsRepository.save(aspects);
        }

        return toReviewDTO(saved, true);
    }

    public List<HotelReviewDTO> getHotelReviews(Integer hotelId, String status) {
        // if status provided, filter; otherwise list all
        List<HotelReview> list;
        if (status != null && !status.isBlank()) {
            HotelReview.ReviewStatus st = HotelReview.ReviewStatus.valueOf(status);
            list = hotelReviewRepository.findByHotelAndStatus(hotelId, st);
        } else {
            list = hotelReviewRepository.findByHotel_HotelId(hotelId);
        }
        return list.stream().map(r -> toReviewDTO(r, true)).collect(Collectors.toList());
    }

    private HotelReviewDTO toReviewDTO(HotelReview r, boolean fetchAspects) {
        HotelReviewDTO.HotelReviewAspectsDTO aspectsDTO = null;
        if (fetchAspects && r.getReviewId() != null) {
            var opt = hotelReviewAspectsRepository.findById(r.getReviewId());
            if (opt.isPresent()) {
                var a = opt.get();
                aspectsDTO = HotelReviewDTO.HotelReviewAspectsDTO.builder()
                        .cleanliness(a.getCleanliness())
                        .service(a.getService())
                        .valueForMoney(a.getValueForMoney())
                        .location(a.getLocation())
                        .facilities(a.getFacilities())
                        .build();
            }
        }

        return HotelReviewDTO.builder()
                .reviewId(r.getReviewId())
                .hotelId(r.getHotel() != null ? r.getHotel().getHotelId() : null)
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
                .imageUrls(splitList(h.getImageUrls()))
                .ratingAverage(h.getRatingAverage())
                .badges(splitList(h.getBadges()))
                .hotelStatus(h.getHotelStatus() != null ? h.getHotelStatus().name() : null)
                .starRating(h.getStarRating())
                .propertyType(h.getPropertyType() != null ? h.getPropertyType().name() : null)
                .address(h.getAddress())
                .checkinTime(h.getCheckinTime())
                .checkoutTime(h.getCheckoutTime())
                .highlightsJson(readJsonList(h.getHighlightsJson()))
                .amenitiesJson(readJsonList(h.getAmenitiesJson()))
                .policiesText(h.getPoliciesText())
                .createdAt(h.getCreatedAt())
                .updatedAt(h.getUpdatedAt())
                .build();
    }

    private String joinList(List<String> list) {
        if (list == null || list.isEmpty())
            return null;
        return String.join(",", list);
    }

    private List<String> splitList(String csv) {
        if (csv == null || csv.trim().isEmpty())
            return new ArrayList<>();
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
}