package com.vn.tripfinity.backend.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vn.tripfinity.backend.dto.HotelDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Area;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.repository.AreaRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.service.cloudinary.CloudinaryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelService {
    private final HotelRepository hotelRepository;
    private final ProviderRepository providerRepository;
    private final AreaRepository areaRepository;
    private final CloudinaryService cloudinaryService;
    private final ObjectMapper objectMapper;

    public List<HotelDTO> getAllHotels() {
        log.debug("Lấy toàn bộ hotels");
        return hotelRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelDTO getHotelById(Integer hotelId) {
        log.debug("Lấy hotel theo ID: {}", hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));
        return convertToDTO(hotel);
    }

    public List<HotelDTO> getHotelsByProvider(Integer providerId) {
        log.debug("Lấy danh sách hotels của Provider ID: {}", providerId);

        // Kiểm tra provider có tồn tại không
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<Hotel> hotels = hotelRepository.findByProvider_ProviderId(providerId);
        log.info("Tìm thấy {} hotels của Provider ID: {}", hotels.size(), providerId);

        return hotels.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelDTO> getHotelsByProviderAndStatus(Integer providerId, String status) {
        log.debug("Lấy danh sách hotels của Provider ID: {} với status: {}", providerId, status);

        // Kiểm tra provider có tồn tại không
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        Hotel.HotelStatus hotelStatus = Hotel.HotelStatus.valueOf(status);
        List<Hotel> hotels = hotelRepository.findByProvider_ProviderIdAndHotelStatus(providerId, hotelStatus);
        log.info("Tìm thấy {} hotels của Provider ID: {} với status: {}", hotels.size(), providerId, status);

        return hotels.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // ==================== QUERY BY AREA ====================

    public List<HotelDTO> getHotelsByArea(Integer areaId) {
        log.debug("Lấy danh sách hotels ở Area ID: {}", areaId);

        // Kiểm tra area có tồn tại không
        areaRepository.findById(areaId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + areaId));

        List<Hotel> hotels = hotelRepository.findByArea_AreaId(areaId);
        log.info("Tìm thấy {} hotels ở Area ID: {}", hotels.size(), areaId);

        return hotels.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // ==================== QUERY BY SLUG ====================

    public HotelDTO getHotelBySlug(String slug) {
        log.debug("Lấy hotel theo slug: {}", slug);
        Hotel hotel = hotelRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel với slug: " + slug));

        return convertToDTO(hotel);
    }

    public HotelDTO createHotel(HotelDTO dto) {
        log.debug("Tạo Hotel: {}", dto);

        Provider provider = providerRepository.findById(dto.getProviderId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));

        Area area = areaRepository.findById(dto.getAreaId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + dto.getAreaId()));

        Hotel hotel = Hotel.builder()
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
                .ratingAverage(dto.getRatingAverage() != null ? dto.getRatingAverage() : new BigDecimal("0.00"))
                .badges(listToCommaString(dto.getBadges()))
                .hotelStatus(dto.getHotelStatus() != null ? Hotel.HotelStatus.valueOf(dto.getHotelStatus())
                        : Hotel.HotelStatus.published)
                .starRating(dto.getStarRating())
                .propertyType(dto.getPropertyType() != null ? Hotel.PropertyType.valueOf(dto.getPropertyType()) : null)
                .address(dto.getAddress())
                .checkinTime(dto.getCheckinTime())
                .checkoutTime(dto.getCheckoutTime())
                .highlightsJson(listToJson(dto.getHighlights()))
                .amenitiesJson(listToJson(dto.getAmenities()))
                .policiesText(dto.getPoliciesText())
                .slug(dto.getSlug())
                .seoTitle(dto.getSeoTitle())
                .seoDescription(dto.getSeoDescription())
                .isFeatured(dto.getIsFeatured() != null ? dto.getIsFeatured() : false)
                .bookingSettingsJson(dto.getBookingSettingsJson())
                .publishedAt(dto.getPublishedAt())
                .visibility(dto.getVisibility() != null ? Hotel.Visibility.valueOf(dto.getVisibility())
                        : Hotel.Visibility.public_)
                .build();

        Hotel savedHotel = hotelRepository.save(hotel);
        log.info("Tạo Hotel ID: {}", savedHotel.getHotelId());

        return convertToDTO(savedHotel);
    }

    public HotelDTO updateHotel(Integer hotelId, HotelDTO dto) {
        log.debug("Cập nhật Hotel ID: {}", hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        // Update provider nếu có
        if (dto.getProviderId() != null && !dto.getProviderId().equals(hotel.getProvider().getProviderId())) {
            Provider provider = providerRepository.findById(dto.getProviderId())
                    .orElseThrow(
                            () -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
            hotel.setProvider(provider);
        }

        // Update area nếu có
        if (dto.getAreaId() != null && !dto.getAreaId().equals(hotel.getArea().getAreaId())) {
            Area area = areaRepository.findById(dto.getAreaId())
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + dto.getAreaId()));
            hotel.setArea(area);
        }

        // Update các field khác
        if (dto.getTitle() != null)
            hotel.setTitle(dto.getTitle());
        if (dto.getServiceDescription() != null)
            hotel.setServiceDescription(dto.getServiceDescription());
        if (dto.getLocation() != null)
            hotel.setLocation(dto.getLocation());
        if (dto.getStartDate() != null)
            hotel.setStartDate(dto.getStartDate());
        if (dto.getEndDate() != null)
            hotel.setEndDate(dto.getEndDate());
        if (dto.getPrice() != null)
            hotel.setPrice(dto.getPrice());
        if (dto.getCurrencyCode() != null)
            hotel.setCurrencyCode(dto.getCurrencyCode());
        if (dto.getCapacity() != null)
            hotel.setCapacity(dto.getCapacity());
        if (dto.getMinParticipants() != null)
            hotel.setMinParticipants(dto.getMinParticipants());
        if (dto.getMaxParticipants() != null)
            hotel.setMaxParticipants(dto.getMaxParticipants());
        if (dto.getRatingAverage() != null)
            hotel.setRatingAverage(dto.getRatingAverage());
        if (dto.getBadges() != null)
            hotel.setBadges(listToCommaString(dto.getBadges()));
        if (dto.getHotelStatus() != null)
            hotel.setHotelStatus(Hotel.HotelStatus.valueOf(dto.getHotelStatus()));
        if (dto.getStarRating() != null)
            hotel.setStarRating(dto.getStarRating());
        if (dto.getPropertyType() != null)
            hotel.setPropertyType(Hotel.PropertyType.valueOf(dto.getPropertyType()));
        if (dto.getAddress() != null)
            hotel.setAddress(dto.getAddress());
        if (dto.getCheckinTime() != null)
            hotel.setCheckinTime(dto.getCheckinTime());
        if (dto.getCheckoutTime() != null)
            hotel.setCheckoutTime(dto.getCheckoutTime());
        if (dto.getHighlights() != null)
            hotel.setHighlightsJson(listToJson(dto.getHighlights()));
        if (dto.getAmenities() != null)
            hotel.setAmenitiesJson(listToJson(dto.getAmenities()));
        if (dto.getPoliciesText() != null)
            hotel.setPoliciesText(dto.getPoliciesText());
        if (dto.getSlug() != null)
            hotel.setSlug(dto.getSlug());
        if (dto.getSeoTitle() != null)
            hotel.setSeoTitle(dto.getSeoTitle());
        if (dto.getSeoDescription() != null)
            hotel.setSeoDescription(dto.getSeoDescription());
        if (dto.getIsFeatured() != null)
            hotel.setIsFeatured(dto.getIsFeatured());
        if (dto.getBookingSettingsJson() != null)
            hotel.setBookingSettingsJson(dto.getBookingSettingsJson());
        if (dto.getPublishedAt() != null)
            hotel.setPublishedAt(dto.getPublishedAt());
        if (dto.getVisibility() != null)
            hotel.setVisibility(Hotel.Visibility.valueOf(dto.getVisibility()));

        Hotel updatedHotel = hotelRepository.save(hotel);
        log.info("Đã cập nhật Hotel ID: {}", updatedHotel.getHotelId());

        return convertToDTO(updatedHotel);
    }

    public void deleteHotel(Integer hotelId) {
        log.debug("Xóa Hotel ID: {}", hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        // Xóa thumbnail nếu có
        if (hotel.getThumbnailUrl() != null && !hotel.getThumbnailUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImageByUrl(hotel.getThumbnailUrl());
            } catch (Exception e) {
                log.warn("Không thể xóa thumbnail: {}", e.getMessage());
            }
        }

        // Xóa tất cả images nếu có
        if (hotel.getImageUrls() != null && !hotel.getImageUrls().isEmpty()) {
            try {
                List<String> imageUrls = jsonToList(hotel.getImageUrls());
                for (String imageUrl : imageUrls) {
                    try {
                        cloudinaryService.deleteImageByUrl(imageUrl);
                    } catch (Exception e) {
                        log.warn("Không thể xóa image: {}", e.getMessage());
                    }
                }
            } catch (Exception e) {
                log.warn("Lỗi khi xóa images: {}", e.getMessage());
            }
        }

        hotelRepository.delete(hotel);
        log.info("Đã xóa Hotel ID: {}", hotelId);
    }

    // ==================== THUMBNAIL MANAGEMENT ====================

    public HotelDTO uploadThumbnail(Integer hotelId, MultipartFile file) throws IOException {
        log.debug("Upload thumbnail cho Hotel ID: {}", hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        // Xóa thumbnail cũ nếu có
        if (hotel.getThumbnailUrl() != null && !hotel.getThumbnailUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImageByUrl(hotel.getThumbnailUrl());
                log.info("Đã xóa thumbnail cũ: {}", hotel.getThumbnailUrl());
            } catch (Exception e) {
                log.warn("Không thể xóa thumbnail cũ: {}", e.getMessage());
            }
        }

        // Upload thumbnail mới
        Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
        String thumbnailUrl = (String) uploadResult.get("secure_url");

        hotel.setThumbnailUrl(thumbnailUrl);
        Hotel savedHotel = hotelRepository.save(hotel);
        log.info("Đã upload thumbnail mới cho Hotel ID: {}", savedHotel.getHotelId());

        return convertToDTO(savedHotel);
    }

    public HotelDTO deleteThumbnail(Integer hotelId) throws IOException {
        log.debug("Xóa thumbnail cho Hotel ID: {}", hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        // Xóa thumbnail trên Cloudinary
        if (hotel.getThumbnailUrl() != null && !hotel.getThumbnailUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImageByUrl(hotel.getThumbnailUrl());
                log.info("Đã xóa thumbnail: {}", hotel.getThumbnailUrl());
            } catch (Exception e) {
                log.warn("Không thể xóa thumbnail: {}", e.getMessage());
            }
        }

        hotel.setThumbnailUrl(null);
        Hotel savedHotel = hotelRepository.save(hotel);
        log.info("Đã xóa thumbnail cho Hotel ID: {}", savedHotel.getHotelId());

        return convertToDTO(savedHotel);
    }

    // ==================== IMAGES MANAGEMENT ====================

    public HotelDTO addImages(Integer hotelId, List<MultipartFile> files) throws IOException {
        log.debug("Thêm {} ảnh cho Hotel ID: {}", files.size(), hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        // Lấy danh sách URL hiện tại
        List<String> currentImageUrls = new ArrayList<>();
        if (hotel.getImageUrls() != null && !hotel.getImageUrls().isEmpty()) {
            currentImageUrls = jsonToList(hotel.getImageUrls());
        }

        // Upload từng file và thêm vào list
        for (MultipartFile file : files) {
            Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
            String imageUrl = (String) uploadResult.get("secure_url");
            currentImageUrls.add(imageUrl);
            log.info("Đã upload ảnh: {}", imageUrl);
        }

        // Lưu lại danh sách URL
        hotel.setImageUrls(listToJson(currentImageUrls));
        Hotel savedHotel = hotelRepository.save(hotel);
        log.info("Đã thêm {} ảnh cho Hotel ID: {}", files.size(), savedHotel.getHotelId());

        return convertToDTO(savedHotel);
    }

    public HotelDTO deleteImage(Integer hotelId, String imageUrl) throws IOException {
        log.debug("Xóa ảnh {} cho Hotel ID: {}", imageUrl, hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        if (hotel.getImageUrls() == null || hotel.getImageUrls().isEmpty()) {
            throw new IllegalArgumentException("Hotel không có ảnh nào");
        }

        List<String> imageUrls = jsonToList(hotel.getImageUrls());

        if (!imageUrls.contains(imageUrl)) {
            throw new IllegalArgumentException("Ảnh không tồn tại trong danh sách");
        }

        // Xóa ảnh trên Cloudinary
        try {
            cloudinaryService.deleteImageByUrl(imageUrl);
            log.info("Đã xóa ảnh trên Cloudinary: {}", imageUrl);
        } catch (Exception e) {
            log.warn("Không thể xóa ảnh trên Cloudinary: {}", e.getMessage());
        }

        // Xóa khỏi danh sách
        imageUrls.remove(imageUrl);
        hotel.setImageUrls(imageUrls.isEmpty() ? null : listToJson(imageUrls));

        Hotel savedHotel = hotelRepository.save(hotel);
        log.info("Đã xóa ảnh cho Hotel ID: {}", savedHotel.getHotelId());

        return convertToDTO(savedHotel);
    }

    public HotelDTO deleteAllImages(Integer hotelId) throws IOException {
        log.debug("Xóa tất cả ảnh cho Hotel ID: {}", hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        if (hotel.getImageUrls() != null && !hotel.getImageUrls().isEmpty()) {
            List<String> imageUrls = jsonToList(hotel.getImageUrls());

            // Xóa từng ảnh trên Cloudinary
            for (String imageUrl : imageUrls) {
                try {
                    cloudinaryService.deleteImageByUrl(imageUrl);
                    log.info("Đã xóa ảnh: {}", imageUrl);
                } catch (Exception e) {
                    log.warn("Không thể xóa ảnh: {}", e.getMessage());
                }
            }
        }

        hotel.setImageUrls(null);
        Hotel savedHotel = hotelRepository.save(hotel);
        log.info("Đã xóa tất cả ảnh cho Hotel ID: {}", savedHotel.getHotelId());

        return convertToDTO(savedHotel);
    }

    // ==================== HELPER METHODS ====================

    private HotelDTO convertToDTO(Hotel hotel) {
        return HotelDTO.builder()
                .hotelId(hotel.getHotelId())
                .providerId(hotel.getProvider() != null ? hotel.getProvider().getProviderId() : null)
                .areaId(hotel.getArea() != null ? hotel.getArea().getAreaId() : null)
                .title(hotel.getTitle())
                .serviceDescription(hotel.getServiceDescription())
                .location(hotel.getLocation())
                .startDate(hotel.getStartDate())
                .endDate(hotel.getEndDate())
                .price(hotel.getPrice())
                .currencyCode(hotel.getCurrencyCode())
                .capacity(hotel.getCapacity())
                .minParticipants(hotel.getMinParticipants())
                .maxParticipants(hotel.getMaxParticipants())
                .thumbnailUrl(hotel.getThumbnailUrl())
                .imageUrls(jsonToList(hotel.getImageUrls()))
                .ratingAverage(hotel.getRatingAverage())
                .badges(commaStringToList(hotel.getBadges()))
                .hotelStatus(hotel.getHotelStatus() != null ? hotel.getHotelStatus().name() : null)
                .starRating(hotel.getStarRating())
                .propertyType(hotel.getPropertyType() != null ? hotel.getPropertyType().name() : null)
                .address(hotel.getAddress())
                .checkinTime(hotel.getCheckinTime())
                .checkoutTime(hotel.getCheckoutTime())
                .highlights(jsonToList(hotel.getHighlightsJson()))
                .amenities(jsonToList(hotel.getAmenitiesJson()))
                .policiesText(hotel.getPoliciesText())
                .slug(hotel.getSlug())
                .seoTitle(hotel.getSeoTitle())
                .seoDescription(hotel.getSeoDescription())
                .isFeatured(hotel.getIsFeatured())
                .bookingSettingsJson(hotel.getBookingSettingsJson())
                .publishedAt(hotel.getPublishedAt())
                .visibility(hotel.getVisibility() != null ? hotel.getVisibility().name().replace("_", "") : null)
                .createdAt(hotel.getCreatedAt())
                .updatedAt(hotel.getUpdatedAt())
                .build();
    }

    private String listToJson(List<String> list) {
        if (list == null || list.isEmpty())
            return null;
        try {
            return objectMapper.writeValueAsString(list);
        } catch (JsonProcessingException e) {
            log.error("Error converting list to JSON", e);
            return null;
        }
    }

    private List<String> jsonToList(String json) {
        if (json == null || json.isEmpty())
            return new ArrayList<>();
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {
            });
        } catch (JsonProcessingException e) {
            log.error("Error converting JSON to list", e);
            return new ArrayList<>();
        }
    }

    private String listToCommaString(List<String> list) {
        if (list == null || list.isEmpty())
            return null;
        return String.join(",", list);
    }

    private List<String> commaStringToList(String str) {
        if (str == null || str.isEmpty())
            return new ArrayList<>();
        return List.of(str.split(","));
    }
}