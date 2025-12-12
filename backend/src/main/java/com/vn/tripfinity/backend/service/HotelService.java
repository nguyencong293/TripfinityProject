package com.vn.tripfinity.backend.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vn.tripfinity.backend.dto.HotelDTO;
import com.vn.tripfinity.backend.dto.HotelRatingSummaryDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Area;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.HotelReview;
import com.vn.tripfinity.backend.model.HotelReviewAspects;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.repository.AreaRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.HotelReviewAspectsRepository;
import com.vn.tripfinity.backend.repository.HotelReviewRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.service.cloudinary.CloudinaryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
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
    private final HotelReviewRepository hotelReviewRepository;
    private final HotelReviewAspectsRepository hotelReviewAspectsRepository;
    private final com.vn.tripfinity.backend.repository.HotelBookingRepository hotelBookingRepository;
    private final NotificationService notificationService;

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

        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        Hotel.HotelStatus hotelStatus = Hotel.HotelStatus.valueOf(status);
        List<Hotel> hotels = hotelRepository.findByProvider_ProviderIdAndHotelStatus(providerId, hotelStatus);
        log.info("Tìm thấy {} hotels của Provider ID: {} với status: {}", hotels.size(), providerId, status);

        return hotels.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelDTO> getHotelsByArea(Integer areaId) {
        log.debug("Lấy danh sách hotels ở Area ID: {}", areaId);

        areaRepository.findById(areaId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + areaId));

        List<Hotel> hotels = hotelRepository.findByArea_AreaId(areaId);
        log.info("Tìm thấy {} hotels ở Area ID: {}", hotels.size(), areaId);

        return hotels.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelDTO getHotelBySlug(String slug) {
        log.debug("Lấy hotel theo slug: {}", slug);
        Hotel hotel = hotelRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel với slug: " + slug));

        return convertToDTO(hotel);
    }

    public HotelDTO createHotel(HotelDTO dto) {
        log.debug("Tạo Hotel: {}", dto);

        log.info("📝 Creating hotel với data: title={}, highlightsJson={}, amenitiesJson={}",
                dto.getTitle(), dto.getHighlightsJson(), dto.getAmenitiesJson());

        Provider provider = providerRepository.findById(dto.getProviderId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));

        Area area = areaRepository.findById(dto.getAreaId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + dto.getAreaId()));

        // Xác định hotelStatus và publishedAt
        Hotel.HotelStatus hotelStatus = dto.getHotelStatus() != null ? Hotel.HotelStatus.valueOf(dto.getHotelStatus())
                : Hotel.HotelStatus.published;

        LocalDateTime publishedAt = determinePublishedAt(hotelStatus, null);

        Hotel hotel = Hotel.builder()
                .provider(provider)
                .area(area)
                .title(dto.getTitle())
                .serviceDescription(dto.getServiceDescription())
                .location(dto.getLocation())
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .price(dto.getPrice())
                .pricePerNight(dto.getPricePerNight())
                .currencyCode(dto.getCurrencyCode())
                .capacity(dto.getCapacity())
                .maxBedsPerRoom(dto.getMaxBedsPerRoom())
                .totalRooms(dto.getTotalRooms())
                .minParticipants(dto.getMinParticipants())
                .maxParticipants(dto.getMaxParticipants())
                .badges(listToCommaString(dto.getBadges()))
                .hotelStatus(hotelStatus)
                .starRating(dto.getStarRating())
                .propertyType(dto.getPropertyType() != null ? Hotel.PropertyType.valueOf(dto.getPropertyType()) : null)
                .address(dto.getAddress())
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .checkinTime(dto.getCheckinTime())
                .checkoutTime(dto.getCheckoutTime())
                .highlightsJson(integerListToJson(dto.getHighlightsJson()))
                .amenitiesJson(integerListToJson(dto.getAmenitiesJson()))
                .policiesText(dto.getPoliciesText())
                .slug(dto.getSlug())
                .seoTitle(dto.getSeoTitle())
                .seoDescription(dto.getSeoDescription())
                .isFeatured(dto.getIsFeatured() != null ? dto.getIsFeatured() : false)
                .publishedAt(publishedAt)
                .visibility(dto.getVisibility() != null ? Hotel.Visibility.valueOf(dto.getVisibility())
                        : Hotel.Visibility.public_)
                .build();

        log.info("🔍 Hotel entity trước khi save: hotelStatus={}, publishedAt={}",
                hotel.getHotelStatus(), hotel.getPublishedAt());

        Hotel savedHotel = hotelRepository.save(hotel);
        log.info("✅ Tạo Hotel ID: {} với hotelStatus={}, publishedAt={}",
                savedHotel.getHotelId(), savedHotel.getHotelStatus(), savedHotel.getPublishedAt());

        // Tạo thông báo cho supplier
        try {
            Integer userId = provider.getUser().getUserId();
            notificationService.notifyHotelCreated(userId, savedHotel.getTitle());
        } catch (Exception e) {
            log.error("⚠️ Không thể tạo thông báo cho Hotel ID: {}", savedHotel.getHotelId(), e);
        }

        return convertToDTO(savedHotel);
    }

    public HotelDTO updateHotel(Integer hotelId, HotelDTO dto) {
        log.debug("Cập nhật Hotel ID: {}", hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        // Lưu trạng thái cũ để so sánh
        Hotel.HotelStatus oldStatus = hotel.getHotelStatus();
        LocalDateTime oldPublishedAt = hotel.getPublishedAt();

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
        if (dto.getPricePerNight() != null)
            hotel.setPricePerNight(dto.getPricePerNight());
        if (dto.getCurrencyCode() != null)
            hotel.setCurrencyCode(dto.getCurrencyCode());
        if (dto.getCapacity() != null)
            hotel.setCapacity(dto.getCapacity());
        if (dto.getMaxBedsPerRoom() != null)
            hotel.setMaxBedsPerRoom(dto.getMaxBedsPerRoom());
        if (dto.getTotalRooms() != null)
            hotel.setTotalRooms(dto.getTotalRooms());
        if (dto.getMinParticipants() != null)
            hotel.setMinParticipants(dto.getMinParticipants());
        if (dto.getMaxParticipants() != null)
            hotel.setMaxParticipants(dto.getMaxParticipants());
        if (dto.getBadges() != null)
            hotel.setBadges(listToCommaString(dto.getBadges()));

        // Xử lý hotelStatus và publishedAt
        if (dto.getHotelStatus() != null) {
            Hotel.HotelStatus newStatus = Hotel.HotelStatus.valueOf(dto.getHotelStatus());
            hotel.setHotelStatus(newStatus);

            // Tự động cập nhật publishedAt dựa trên status
            LocalDateTime newPublishedAt = determinePublishedAt(newStatus, oldPublishedAt);
            hotel.setPublishedAt(newPublishedAt);

            log.info("🔄 Status thay đổi từ {} -> {}, publishedAt: {} -> {}",
                    oldStatus, newStatus, oldPublishedAt, newPublishedAt);
        }

        if (dto.getStarRating() != null)
            hotel.setStarRating(dto.getStarRating());
        if (dto.getPropertyType() != null)
            hotel.setPropertyType(Hotel.PropertyType.valueOf(dto.getPropertyType()));
        if (dto.getAddress() != null)
            hotel.setAddress(dto.getAddress());
        if (dto.getLatitude() != null)
            hotel.setLatitude(dto.getLatitude());
        if (dto.getLongitude() != null)
            hotel.setLongitude(dto.getLongitude());
        if (dto.getCheckinTime() != null)
            hotel.setCheckinTime(dto.getCheckinTime());
        if (dto.getCheckoutTime() != null)
            hotel.setCheckoutTime(dto.getCheckoutTime());
        if (dto.getHighlightsJson() != null)
            hotel.setHighlightsJson(integerListToJson(dto.getHighlightsJson()));
        if (dto.getAmenitiesJson() != null)
            hotel.setAmenitiesJson(integerListToJson(dto.getAmenitiesJson()));
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

        if (dto.getVisibility() != null)
            hotel.setVisibility(Hotel.Visibility.valueOf(dto.getVisibility()));

        Hotel updatedHotel = hotelRepository.save(hotel);
        log.info("Đã cập nhật Hotel ID: {}", updatedHotel.getHotelId());

        // Tạo thông báo cho supplier
        try {
            Integer userId = updatedHotel.getProvider().getUser().getUserId();
            notificationService.notifyHotelUpdated(userId, updatedHotel.getTitle());
        } catch (Exception e) {
            log.error("⚠️ Không thể tạo thông báo cho Hotel ID: {}", updatedHotel.getHotelId(), e);
        }

        return convertToDTO(updatedHotel);
    }

    public void deleteHotel(Integer hotelId) {
        log.debug("Xóa Hotel ID: {}", hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        // Xóa thumbnail trên Cloudinary
        if (hotel.getThumbnailUrl() != null && !hotel.getThumbnailUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImage(hotel.getThumbnailUrl());
                log.info("Đã xóa thumbnail trên Cloudinary cho Hotel ID: {}", hotelId);
            } catch (Exception e) {
                log.error("Lỗi khi xóa thumbnail trên Cloudinary: {}", e.getMessage());
            }
        }

        // Xóa các ảnh trên Cloudinary
        if (hotel.getImageUrls() != null && !hotel.getImageUrls().isEmpty()) {
            try {
                List<String> imageUrls = jsonToStringList(hotel.getImageUrls());
                for (String imageUrl : imageUrls) {
                    cloudinaryService.deleteImage(imageUrl);
                }
                log.info("Đã xóa {} ảnh trên Cloudinary cho Hotel ID: {}", imageUrls.size(), hotelId);
            } catch (Exception e) {
                log.error("Lỗi khi xóa ảnh trên Cloudinary: {}", e.getMessage());
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
                cloudinaryService.deleteImage(hotel.getThumbnailUrl());
                log.info("Đã xóa thumbnail cũ trên Cloudinary");
            } catch (Exception e) {
                log.error("Lỗi khi xóa thumbnail cũ: {}", e.getMessage());
            }
        }

        // Upload thumbnail mới
        Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
        String thumbnailUrl = (String) uploadResult.get("secure_url");

        hotel.setThumbnailUrl(thumbnailUrl);
        Hotel savedHotel = hotelRepository.save(hotel);
        log.info("Đã upload thumbnail cho Hotel ID: {}", savedHotel.getHotelId());

        return convertToDTO(savedHotel);
    }

    public HotelDTO deleteThumbnail(Integer hotelId) throws IOException {
        log.debug("Xóa thumbnail cho Hotel ID: {}", hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        if (hotel.getThumbnailUrl() != null && !hotel.getThumbnailUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImage(hotel.getThumbnailUrl());
                log.info("Đã xóa thumbnail trên Cloudinary");
            } catch (Exception e) {
                log.error("Lỗi khi xóa thumbnail trên Cloudinary: {}", e.getMessage());
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

        List<String> currentImageUrls = jsonToStringList(hotel.getImageUrls());
        List<String> newImageUrls = new ArrayList<>(currentImageUrls);

        for (MultipartFile file : files) {
            Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
            String imageUrl = (String) uploadResult.get("secure_url");
            newImageUrls.add(imageUrl);
        }

        hotel.setImageUrls(stringListToJson(newImageUrls));
        Hotel savedHotel = hotelRepository.save(hotel);
        log.info("Đã thêm {} ảnh cho Hotel ID: {}", files.size(), savedHotel.getHotelId());

        return convertToDTO(savedHotel);
    }

    public HotelDTO deleteImage(Integer hotelId, String imageUrl) throws IOException {
        log.debug("Xóa ảnh cho Hotel ID: {}", hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        List<String> currentImageUrls = jsonToStringList(hotel.getImageUrls());

        if (currentImageUrls.contains(imageUrl)) {
            try {
                cloudinaryService.deleteImage(imageUrl);
                log.info("Đã xóa ảnh trên Cloudinary");
            } catch (Exception e) {
                log.error("Lỗi khi xóa ảnh trên Cloudinary: {}", e.getMessage());
            }

            currentImageUrls.remove(imageUrl);
            hotel.setImageUrls(stringListToJson(currentImageUrls));
            Hotel savedHotel = hotelRepository.save(hotel);
            log.info("Đã xóa ảnh cho Hotel ID: {}", savedHotel.getHotelId());

            return convertToDTO(savedHotel);
        } else {
            throw new ResourceNotFoundException("Không tìm thấy ảnh với URL: " + imageUrl);
        }
    }

    public HotelDTO deleteAllImages(Integer hotelId) throws IOException {
        log.debug("Xóa tất cả ảnh cho Hotel ID: {}", hotelId);
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        List<String> currentImageUrls = jsonToStringList(hotel.getImageUrls());

        for (String imageUrl : currentImageUrls) {
            try {
                cloudinaryService.deleteImage(imageUrl);
            } catch (Exception e) {
                log.error("Lỗi khi xóa ảnh trên Cloudinary: {}", e.getMessage());
            }
        }

        hotel.setImageUrls(null);
        Hotel savedHotel = hotelRepository.save(hotel);
        log.info("Đã xóa tất cả ảnh cho Hotel ID: {}", savedHotel.getHotelId());

        return convertToDTO(savedHotel);
    }

    // ==================== HELPER METHODS ====================

    /**
     * Xác định publishedAt dựa trên hotelStatus
     * 
     * @param status             Trạng thái hotel mới
     * @param currentPublishedAt Thời gian published hiện tại (có thể null)
     * @return LocalDateTime cho publishedAt
     */
    private LocalDateTime determinePublishedAt(Hotel.HotelStatus status, LocalDateTime currentPublishedAt) {
        switch (status) {
            case published:
                // Nếu đang chuyển sang published và chưa có publishedAt thì set thời gian hiện
                // tại
                if (currentPublishedAt == null) {
                    LocalDateTime now = LocalDateTime.now();
                    log.info("🕐 Set publishedAt = {} vì status = published và chưa có publishedAt", now);
                    return now;
                }
                // Nếu đã có publishedAt thì giữ nguyên
                log.info("📅 Giữ nguyên publishedAt = {} vì đã có sẵn", currentPublishedAt);
                return currentPublishedAt;

            case archived:
            case disabled:
                // Nếu không phải published thì set publishedAt = null
                if (currentPublishedAt != null) {
                    log.info("🚫 Set publishedAt = null vì status = {}", status);
                }
                return null;

            default:
                log.warn("⚠️ Unknown hotel status: {}, set publishedAt = null", status);
                return null;
        }
    }

    private HotelDTO convertToDTO(Hotel hotel) {
        // Calculate available rooms and capacity
        Integer availableRooms = calculateAvailableRooms(hotel.getHotelId(), hotel.getTotalRooms());
        Integer availableCapacity = calculateAvailableCapacity(hotel.getHotelId(), hotel.getCapacity());
        
        // Calculate rating average from reviews (null if no reviews)
        Double ratingAverage = hotelReviewRepository.calculateAverageRating(hotel.getHotelId());
        
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
                .pricePerNight(hotel.getPricePerNight())
                .currencyCode(hotel.getCurrencyCode())
                .capacity(hotel.getCapacity())
                .totalRooms(hotel.getTotalRooms())
                .availableRooms(availableRooms)
                .availableCapacity(availableCapacity)
                .maxBedsPerRoom(hotel.getMaxBedsPerRoom())
                .minParticipants(hotel.getMinParticipants())
                .maxParticipants(hotel.getMaxParticipants())
                .thumbnailUrl(hotel.getThumbnailUrl())
                .imageUrls(jsonToStringList(hotel.getImageUrls()))
                .badges(commaStringToList(hotel.getBadges()))
                .hotelStatus(hotel.getHotelStatus() != null ? hotel.getHotelStatus().name() : null)
                .starRating(hotel.getStarRating())
                .propertyType(hotel.getPropertyType() != null ? hotel.getPropertyType().name() : null)
                .address(hotel.getAddress())
                .latitude(hotel.getLatitude())
                .longitude(hotel.getLongitude())
                .checkinTime(hotel.getCheckinTime())
                .checkoutTime(hotel.getCheckoutTime())
                .highlightsJson(jsonToIntegerList(hotel.getHighlightsJson()))
                .amenitiesJson(jsonToIntegerList(hotel.getAmenitiesJson()))
                .policiesText(hotel.getPoliciesText())
                .slug(hotel.getSlug())
                .seoTitle(hotel.getSeoTitle())
                .seoDescription(hotel.getSeoDescription())
                .isFeatured(hotel.getIsFeatured())
                .publishedAt(hotel.getPublishedAt())
                .visibility(hotel.getVisibility() != null ? hotel.getVisibility().name() : null)
                .ratingAverage(ratingAverage)
                .createdAt(hotel.getCreatedAt())
                .updatedAt(hotel.getUpdatedAt())
                .build();
    }

    /**
     * Tính số phòng còn lại của hotel
     * totalRooms - SUM(rooms) của TẤT CẢ booking active (pending, confirmed, completed)
     * KHÔNG tính: cancelled, refunded, checked_out
     */
    private Integer calculateAvailableRooms(Integer hotelId, Integer totalRooms) {
        if (totalRooms == null || totalRooms <= 0) {
            return null; // Hotel chưa set total rooms
        }
        
        // Tính tổng số phòng đã book (TẤT CẢ booking active, không tính cancelled/refunded/checked_out)
        Integer bookedRooms = hotelBookingRepository.sumRoomsByHotelActive(hotelId);
        if (bookedRooms == null) {
            bookedRooms = 0;
        }
        
        Integer available = totalRooms - bookedRooms;
        log.debug("Hotel {}: totalRooms={}, bookedRooms={}, availableRooms={}", 
                hotelId, totalRooms, bookedRooms, available);
        
        return Math.max(0, available); // Không cho âm
    }

    /**
     * Tính sức chứa còn lại của hotel
     * capacity - SUM(numAdults) của TẤT CẢ booking active (pending, confirmed, completed)
     * KHÔNG tính: cancelled, refunded, checked_out
     */
    private Integer calculateAvailableCapacity(Integer hotelId, Integer capacity) {
        if (capacity == null || capacity <= 0) {
            return null; // Hotel chưa set capacity
        }
        
        // Tính tổng số người đã book (TẤT CẢ booking active, không tính cancelled/refunded/checked_out)
        Integer bookedCapacity = hotelBookingRepository.sumGuestsByHotelActive(hotelId);
        if (bookedCapacity == null) {
            bookedCapacity = 0;
        }
        
        Integer available = capacity - bookedCapacity;
        log.debug("Hotel {}: capacity={}, bookedCapacity={}, availableCapacity={}", 
                hotelId, capacity, bookedCapacity, available);
        
        return Math.max(0, available); // Không cho âm
    }

    /**
     * Convert List<Integer> thành JSON string. Nếu list null hoặc empty thì return
     * null.
     */
    private String integerListToJson(List<Integer> list) {
        if (list == null || list.isEmpty()) {
            log.debug("integerListToJson: list is null or empty, returning null");
            return null;
        }
        try {
            String json = objectMapper.writeValueAsString(list);
            log.debug("integerListToJson: converted {} items to JSON: {}", list.size(), json);
            return json;
        } catch (JsonProcessingException e) {
            log.error("Error converting integer list to JSON: {}", list, e);
            return null;
        }
    }

    /**
     * Convert JSON string thành List<Integer>. Nếu json null hoặc empty thì return
     * empty list.
     */
    private List<Integer> jsonToIntegerList(String json) {
        if (json == null || json.trim().isEmpty()) {
            log.debug("jsonToIntegerList: json is null or empty, returning empty list");
            return new ArrayList<>();
        }
        try {
            List<Integer> list = objectMapper.readValue(json, new TypeReference<List<Integer>>() {
            });
            log.debug("jsonToIntegerList: converted JSON to {} items: {}", list != null ? list.size() : 0, list);
            return list != null ? list : new ArrayList<>();
        } catch (JsonProcessingException e) {
            log.error("Error converting JSON to integer list: {}", json, e);
            return new ArrayList<>();
        }
    }

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
            // Try JSON format first
            List<String> list = objectMapper.readValue(json, new TypeReference<List<String>>() {
            });
            return list != null ? list : new ArrayList<>();
        } catch (JsonProcessingException e) {
            // Fallback to CSV format for legacy data
            log.debug("Parse JSON failed, trying CSV format: {}", json);
            return commaStringToList(json);
        }
    }

    private String listToCommaString(List<String> list) {
        return list != null && !list.isEmpty() ? String.join(",", list) : null;
    }

    private List<String> commaStringToList(String str) {
        return str != null && !str.trim().isEmpty() ? List.of(str.split(",")) : new ArrayList<>();
    }

    /**
     * Tính rating summary động từ hotel_reviews và hotel_review_aspects
     * Thay thế cho bảng hotel_rating_summaries (không cần lưu DB nữa)
     */
    public HotelRatingSummaryDTO calculateRatingSummary(Integer hotelId) {
        log.debug("Tính rating summary cho Hotel ID: {}", hotelId);

        // Lấy tất cả reviews đã approved của hotel
        List<HotelReview> reviews = hotelReviewRepository.findByHotelAndStatus(
            hotelId, HotelReview.ReviewStatus.approved);

        HotelRatingSummaryDTO summary = HotelRatingSummaryDTO.builder()
            .hotelId(hotelId)
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
            .mapToInt(HotelReview::getRating)
            .average()
            .orElse(0.0);
        summary.setAvgRating(BigDecimal.valueOf(avgRating).setScale(2, java.math.RoundingMode.HALF_UP));

        // Đếm số lượng từng loại rating
        summary.setCount1((int) reviews.stream().filter(r -> r.getRating() == 1).count());
        summary.setCount2((int) reviews.stream().filter(r -> r.getRating() == 2).count());
        summary.setCount3((int) reviews.stream().filter(r -> r.getRating() == 3).count());
        summary.setCount4((int) reviews.stream().filter(r -> r.getRating() == 4).count());
        summary.setCount5((int) reviews.stream().filter(r -> r.getRating() == 5).count());

        // Tính trung bình các aspects
        List<Integer> reviewIds = reviews.stream()
            .map(HotelReview::getReviewId)
            .collect(Collectors.toList());

        List<HotelReviewAspects> aspects = hotelReviewAspectsRepository.findAllById(reviewIds);

        if (!aspects.isEmpty()) {
            double avgCleanliness = aspects.stream()
                .mapToInt(HotelReviewAspects::getCleanliness)
                .average()
                .orElse(0.0);
            summary.setAvgCleanliness(BigDecimal.valueOf(avgCleanliness).setScale(2, java.math.RoundingMode.HALF_UP));

            double avgService = aspects.stream()
                .mapToInt(HotelReviewAspects::getService)
                .average()
                .orElse(0.0);
            summary.setAvgService(BigDecimal.valueOf(avgService).setScale(2, java.math.RoundingMode.HALF_UP));

            double avgValueForMoney = aspects.stream()
                .mapToInt(HotelReviewAspects::getValueForMoney)
                .average()
                .orElse(0.0);
            summary.setAvgValueForMoney(BigDecimal.valueOf(avgValueForMoney).setScale(2, java.math.RoundingMode.HALF_UP));

            double avgLocation = aspects.stream()
                .mapToInt(HotelReviewAspects::getLocation)
                .average()
                .orElse(0.0);
            summary.setAvgLocation(BigDecimal.valueOf(avgLocation).setScale(2, java.math.RoundingMode.HALF_UP));

            double avgFacilities = aspects.stream()
                .mapToInt(HotelReviewAspects::getFacilities)
                .average()
                .orElse(0.0);
            summary.setAvgFacilities(BigDecimal.valueOf(avgFacilities).setScale(2, java.math.RoundingMode.HALF_UP));
        }

        log.info("✅ Đã tính rating summary cho Hotel ID: {} với {} reviews", hotelId, reviews.size());
        return summary;
    }
}