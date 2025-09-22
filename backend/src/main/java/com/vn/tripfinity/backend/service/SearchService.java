package com.vn.tripfinity.backend.service;

import com.vn.tripfinity.backend.dto.AttractionDTO;
import com.vn.tripfinity.backend.dto.HotelDTO;
import com.vn.tripfinity.backend.dto.RestaurantDTO;
import com.vn.tripfinity.backend.dto.TourDTO;
import com.vn.tripfinity.backend.model.Area;
import com.vn.tripfinity.backend.model.Attraction;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.Restaurant;
import com.vn.tripfinity.backend.model.Tour;
import com.vn.tripfinity.backend.repository.AreaRepository;
import com.vn.tripfinity.backend.repository.AttractionRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.RestaurantRepository;
import com.vn.tripfinity.backend.repository.TourRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SearchService {

    private final HotelRepository hotelRepository;
    private final RestaurantRepository restaurantRepository;
    private final AttractionRepository attractionRepository;
    private final TourRepository tourRepository;
    private final AreaRepository areaRepository;

    public Map<String, Object> searchAll(String q, String type, String status) {
        String query = q == null ? null : q.trim();
        Map<String, Object> result = new HashMap<>();

        // Chuẩn hóa status riêng theo từng loại
        Hotel.HotelStatus hotelStatus = null;
        Restaurant.RestaurantStatus restaurantStatus = null;
        Attraction.AttractionStatus attractionStatus = null;
        Tour.TourStatus tourStatus = null;
        if (status != null && !status.isBlank()) {
            try {
                hotelStatus = Hotel.HotelStatus.valueOf(status);
            } catch (Exception ignored) {
            }
            try {
                restaurantStatus = Restaurant.RestaurantStatus.valueOf(status);
            } catch (Exception ignored) {
            }
            try {
                attractionStatus = Attraction.AttractionStatus.valueOf(status);
            } catch (Exception ignored) {
            }
            try {
                tourStatus = Tour.TourStatus.valueOf(status);
            } catch (Exception ignored) {
            }
        }

        // Thử nhận diện Area (không phân biệt dấu, chấp nhận slug có '-')
        if (query != null && !query.isBlank()) {
            AreaMatch areaMatch = findBestAreaMatch(query);

            // area-only: chỉ hiển thị Area + các dịch vụ thuộc Area
            if (areaMatch != null && areaMatch.isAreaOnlyQuery) {
                Area area = areaMatch.area;

                Map<String, Object> areaSummary = new HashMap<>();
                areaSummary.put("areaId", area.getAreaId());
                areaSummary.put("name", area.getName());
                areaSummary.put("slug", area.getSlug());
                areaSummary.put("areaType", area.getAreaType() != null ? area.getAreaType().name() : null);
                areaSummary.put("hotelsCount", hotelRepository.countByArea_AreaId(area.getAreaId()));
                areaSummary.put("restaurantsCount", restaurantRepository.countByArea_AreaId(area.getAreaId()));
                areaSummary.put("attractionsCount", attractionRepository.countByArea_AreaId(area.getAreaId()));
                areaSummary.put("toursCount", tourRepository.countByArea_AreaId(area.getAreaId()));
                result.put("area", areaSummary);

                if (type == null || type.isBlank() || type.equalsIgnoreCase("hotel")) {
                    List<HotelDTO> hotels = hotelRepository
                            .findByAreaWithStatus(area.getAreaId(), hotelStatus)
                            .stream().map(this::toHotelDTO).collect(Collectors.toList());
                    result.put("hotels", hotels);
                }
                if (type == null || type.isBlank() || type.equalsIgnoreCase("restaurant")) {
                    List<RestaurantDTO> restaurants = restaurantRepository
                            .findByAreaWithStatus(area.getAreaId(), restaurantStatus)
                            .stream().map(this::toRestaurantDTO).collect(Collectors.toList());
                    result.put("restaurants", restaurants);
                }
                if (type == null || type.isBlank() || type.equalsIgnoreCase("attraction")) {
                    List<AttractionDTO> attractions = attractionRepository
                            .findByAreaWithStatus(area.getAreaId(), attractionStatus)
                            .stream().map(this::toAttractionDTO).collect(Collectors.toList());
                    result.put("attractions", attractions);
                }
                if (type == null || type.isBlank() || type.equalsIgnoreCase("tour")) {
                    List<TourDTO> tours = tourRepository
                            .findByAreaWithStatus(area.getAreaId(), tourStatus)
                            .stream().map(this::toTourDTO).collect(Collectors.toList());
                    result.put("tours", tours);
                }

                return result; // Ưu tiên area-only
            }
        }

        // Fallback: Search theo title/location như hiện tại
        if (type == null || type.isBlank() || type.equalsIgnoreCase("hotel")) {
            List<HotelDTO> hotels = hotelRepository.searchByTitleOrLocation(query, hotelStatus).stream()
                    .map(this::toHotelDTO).collect(Collectors.toList());
            result.put("hotels", hotels);
        }

        if (type == null || type.isBlank() || type.equalsIgnoreCase("restaurant")) {
            List<RestaurantDTO> restaurants = restaurantRepository.searchByTitleOrLocation(query, restaurantStatus)
                    .stream().map(this::toRestaurantDTO).collect(Collectors.toList());
            result.put("restaurants", restaurants);
        }

        if (type == null || type.isBlank() || type.equalsIgnoreCase("attraction")) {
            List<AttractionDTO> attractions = attractionRepository.searchByTitleOrLocation(query, attractionStatus)
                    .stream().map(this::toAttractionDTO).collect(Collectors.toList());
            result.put("attractions", attractions);
        }

        if (type == null || type.isBlank() || type.equalsIgnoreCase("tour")) {
            List<TourDTO> tours = tourRepository.searchByTitleOrLocation(query, tourStatus).stream()
                    .map(this::toTourDTO).collect(Collectors.toList());
            result.put("tours", tours);
        }

        return result;
    }

    /**
     * Tìm Area tốt nhất:
     * - Normalize (bỏ dấu, lower, '-' -> space, gộp space) cho query và name/slug.
     * - Ưu tiên exact match (stripped == name/slug) -> area-only.
     * - Nếu hoà, chọn Area có tổng dịch vụ (hotel+restaurant+attraction+tour) lớn
     * hơn.
     */
    private AreaMatch findBestAreaMatch(String inputQuery) {
        String normalized = normalize(inputQuery);
        String stripped = stripAreaDecorators(normalized);

        List<Area> areas = areaRepository.findAll();
        if (areas == null || areas.isEmpty())
            return null;

        Area best = null;
        int bestScore = -1;
        long bestTotal = -1;
        boolean bestExact = false;

        for (Area a : areas) {
            String nName = normalize(a.getName());
            String nSlug = normalize(a.getSlug()); // ví dụ 'da-nang' -> 'da nang'

            int score = -1;
            boolean exact = false;

            // Exact theo stripped (khu vực thuần, không từ trang trí)
            if (stripped.equals(nName) || stripped.equals(nSlug)) {
                score = 100;
                exact = true;
            } else if (normalized.equals(nName) || normalized.equals(nSlug)) {
                score = 90;
            } else if (nName.contains(stripped) || nSlug.contains(stripped) ||
                    stripped.contains(nName) || stripped.contains(nSlug) ||
                    nName.startsWith(stripped) || nSlug.startsWith(stripped)) {
                score = 70;
            }

            if (score >= 0) {
                long total = safeCountArea(a.getAreaId());
                if (score > bestScore || (score == bestScore && total > bestTotal)) {
                    best = a;
                    bestScore = score;
                    bestTotal = total;
                    bestExact = exact;
                }
            }
        }

        if (best == null)
            return null;

        boolean isAreaOnly = bestExact; // chỉ hiển thị area khi là truy vấn khu vực thuần
        return new AreaMatch(best, isAreaOnly);
    }

    private long safeCountArea(Integer areaId) {
        if (areaId == null)
            return 0;
        long h = hotelRepository.countByArea_AreaId(areaId);
        long r = restaurantRepository.countByArea_AreaId(areaId);
        long at = attractionRepository.countByArea_AreaId(areaId);
        long t = tourRepository.countByArea_AreaId(areaId);
        return h + r + at + t;
    }

    // Chuẩn hóa chuỗi: lower, bỏ dấu, chuyển '-' thành space, giữ chữ/số/space, gộp
    // space
    private String normalize(String s) {
        if (s == null)
            return "";
        String lower = s.toLowerCase().trim();

        // NFD rồi loại bỏ dấu
        String noDiacritics = Normalizer.normalize(lower, Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "");

        // Thay '-' thành space để slug 'da-nang' ≡ 'da nang'
        noDiacritics = noDiacritics.replace('-', ' ');

        // Loại ký tự khác (giữ a-z, 0-9 và khoảng trắng), gộp khoảng trắng
        noDiacritics = noDiacritics.replaceAll("[^a-z0-9\\s]+", " ");
        noDiacritics = noDiacritics.replaceAll("\\s+", " ").trim();
        return noDiacritics;
    }

    // Bỏ từ “trang trí” trong tên khu vực để nhận diện area-only
    // Hỗ trợ cả tiếng Việt và tiếng Anh
    private String stripAreaDecorators(String normalized) {
        if (normalized.isEmpty())
            return normalized;

        String pattern = "\\b("
                + "tp|t\\.?p\\.?|thanh pho|thanhpho|tinh|quan|huyen|thi xa|thixa|"
                + "city|province|district|town|ward"
                + ")\\b";

        String stripped = normalized.replaceAll(pattern, " ");
        stripped = stripped.replaceAll("\\s+", " ").trim();
        return stripped;
    }

    private HotelDTO toHotelDTO(Hotel h) {
        return HotelDTO.builder()
                .hotelId(h.getHotelId())
                .providerId(h.getProvider() != null ? h.getProvider().getProviderId() : null)
                .areaId(h.getArea() != null ? h.getArea().getAreaId() : null)
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
                .imageUrls(splitCsv(h.getImageUrls()))
                .ratingAverage(h.getRatingAverage())
                .badges(splitCsv(h.getBadges()))
                .hotelStatus(h.getHotelStatus() != null ? h.getHotelStatus().name() : null)
                .starRating(h.getStarRating())
                .propertyType(h.getPropertyType() != null ? h.getPropertyType().name() : null)
                .address(h.getAddress())
                .checkinTime(h.getCheckinTime())
                .checkoutTime(h.getCheckoutTime())
                .createdAt(h.getCreatedAt())
                .updatedAt(h.getUpdatedAt())
                .build();
    }

    private RestaurantDTO toRestaurantDTO(Restaurant r) {
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
                .imageUrls(splitCsv(r.getImageUrls()))
                .ratingAverage(r.getRatingAverage())
                .badges(splitCsv(r.getBadges()))
                .restaurantStatus(r.getRestaurantStatus() != null ? r.getRestaurantStatus().name() : null)
                .priceLevel(r.getPriceLevel() != null ? r.getPriceLevel().name() : null)
                .phone(r.getPhone())
                .website(r.getWebsite())
                .address(r.getAddress())
                .createdAt(r.getCreatedAt())
                .updatedAt(r.getUpdatedAt())
                .build();
    }

    private AttractionDTO toAttractionDTO(Attraction a) {
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
                .imageUrls(splitCsv(a.getImageUrls()))
                .ratingAverage(a.getRatingAverage())
                .badges(splitCsv(a.getBadges()))
                .attractionStatus(a.getAttractionStatus() != null ? a.getAttractionStatus().name() : null)
                .address(a.getAddress())
                .coordinates(a.getCoordinates())
                .averageVisitMinutes(a.getAverageVisitMinutes())
                .createdAt(a.getCreatedAt())
                .updatedAt(a.getUpdatedAt())
                .build();
    }

    private TourDTO toTourDTO(Tour t) {
        return TourDTO.builder()
                .tourId(t.getTourId())
                .providerId(t.getProvider() != null ? t.getProvider().getProviderId() : null)
                .areaId(t.getArea() != null ? t.getArea().getAreaId() : null)
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
                .imageUrls(splitCsv(t.getImageUrls()))
                .ratingAverage(t.getRatingAverage())
                .badges(splitCsv(t.getBadges()))
                .tourStatus(t.getTourStatus() != null ? t.getTourStatus().name() : null)
                .itineraryOverview(t.getItineraryOverview())
                .meetingPoint(t.getMeetingPoint())
                .guideLanguage(splitCsv(t.getGuideLanguage()))
                .inclusiveItems(splitCsv(t.getInclusiveItems()))
                .exclusiveItems(splitCsv(t.getExclusiveItems()))
                .cancellationPolicy(t.getCancellationPolicy())
                .difficultyLevel(t.getDifficultyLevel() != null ? t.getDifficultyLevel().name() : null)
                .durationDays(t.getDurationDays())
                .departureLocation(t.getDepartureLocation())
                .createdAt(t.getCreatedAt())
                .updatedAt(t.getUpdatedAt())
                .build();
    }

    private List<String> splitCsv(String csv) {
        if (csv == null || csv.trim().isEmpty())
            return null;
        return java.util.Arrays.stream(csv.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(java.util.stream.Collectors.toList());
    }

    private static class AreaMatch {
        final Area area;
        final boolean isAreaOnlyQuery;

        AreaMatch(Area area, boolean isAreaOnlyQuery) {
            this.area = area;
            this.isAreaOnlyQuery = isAreaOnlyQuery;
        }
    }
}