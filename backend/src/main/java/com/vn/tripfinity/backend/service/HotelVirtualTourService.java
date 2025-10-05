package com.vn.tripfinity.backend.service;

import com.vn.tripfinity.backend.dto.HotelVirtualTourDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.HotelVirtualTour;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.HotelVirtualTourRepository;
import com.vn.tripfinity.backend.service.cloudinary.CloudinaryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelVirtualTourService {

    private final HotelVirtualTourRepository virtualTourRepository;
    private final HotelRepository hotelRepository;
    private final CloudinaryService cloudinaryService;

    public List<HotelVirtualTourDTO> getAllVirtualTours() {
        log.debug("Lấy toàn bộ virtual tours");
        return virtualTourRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelVirtualTourDTO getVirtualTourById(Integer virtualTourId) {
        log.debug("Lấy virtual tour theo ID: {}", virtualTourId);
        HotelVirtualTour virtualTour = virtualTourRepository.findById(virtualTourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Virtual Tour id: " + virtualTourId));
        return convertToDTO(virtualTour);
    }

    public List<HotelVirtualTourDTO> getVirtualToursByHotel(Integer hotelId) {
        log.debug("Lấy danh sách virtual tours của Hotel ID: {}", hotelId);
        hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        List<HotelVirtualTour> virtualTours = virtualTourRepository.findByHotel_HotelId(hotelId);
        log.info("Tìm thấy {} virtual tours của Hotel ID: {}", virtualTours.size(), hotelId);

        return virtualTours.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelVirtualTourDTO> getVirtualToursByHotelAndMediaType(Integer hotelId, String mediaType) {
        log.debug("Lấy danh sách virtual tours của Hotel ID: {} với media type: {}", hotelId, mediaType);
        hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        HotelVirtualTour.MediaType type = HotelVirtualTour.MediaType.valueOf(mediaType.toUpperCase().replace("-", "_"));
        List<HotelVirtualTour> virtualTours = virtualTourRepository.findByHotel_HotelIdAndMediaType(hotelId, type);

        return virtualTours.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelVirtualTourDTO createVirtualTour(HotelVirtualTourDTO dto) {
        log.debug("Tạo Virtual Tour: {}", dto);

        Hotel hotel = hotelRepository.findById(dto.getHotelId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + dto.getHotelId()));

        HotelVirtualTour.MediaType mediaType = HotelVirtualTour.MediaType
                .valueOf(dto.getMediaType().toUpperCase().replace("-", "_"));

        HotelVirtualTour virtualTour = HotelVirtualTour.builder()
                .hotel(hotel)
                .mediaType(mediaType)
                .mediaUrl(dto.getMediaUrl())
                .thumbnailUrl(dto.getThumbnailUrl())
                .metadataJson(dto.getMetadataJson())
                .build();

        HotelVirtualTour savedVirtualTour = virtualTourRepository.save(virtualTour);
        log.info("✅ Tạo Virtual Tour ID: {}", savedVirtualTour.getVirtualTourId());

        return convertToDTO(savedVirtualTour);
    }

    public HotelVirtualTourDTO uploadVirtualTourMedia(Integer hotelId, String mediaType, MultipartFile file,
            MultipartFile thumbnailFile) throws IOException {
        log.debug("Upload virtual tour media cho Hotel ID: {}", hotelId);

        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        // Upload media file
        Map<String, Object> mediaUploadResult = cloudinaryService.uploadImage(file);
        String mediaUrl = (String) mediaUploadResult.get("secure_url");

        // Upload thumbnail nếu có
        String thumbnailUrl = null;
        if (thumbnailFile != null && !thumbnailFile.isEmpty()) {
            Map<String, Object> thumbnailUploadResult = cloudinaryService.uploadImage(thumbnailFile);
            thumbnailUrl = (String) thumbnailUploadResult.get("secure_url");
        }

        HotelVirtualTour.MediaType type = HotelVirtualTour.MediaType.valueOf(mediaType.toUpperCase().replace("-", "_"));

        HotelVirtualTour virtualTour = HotelVirtualTour.builder()
                .hotel(hotel)
                .mediaType(type)
                .mediaUrl(mediaUrl)
                .thumbnailUrl(thumbnailUrl)
                .build();

        HotelVirtualTour savedVirtualTour = virtualTourRepository.save(virtualTour);
        log.info("✅ Upload Virtual Tour media cho Hotel ID: {}", hotelId);

        return convertToDTO(savedVirtualTour);
    }

    public HotelVirtualTourDTO updateVirtualTour(Integer virtualTourId, HotelVirtualTourDTO dto) {
        log.debug("Cập nhật Virtual Tour ID: {}", virtualTourId);
        HotelVirtualTour virtualTour = virtualTourRepository.findById(virtualTourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Virtual Tour id: " + virtualTourId));

        if (dto.getMediaType() != null) {
            HotelVirtualTour.MediaType mediaType = HotelVirtualTour.MediaType
                    .valueOf(dto.getMediaType().toUpperCase().replace("-", "_"));
            virtualTour.setMediaType(mediaType);
        }
        if (dto.getMediaUrl() != null)
            virtualTour.setMediaUrl(dto.getMediaUrl());
        if (dto.getThumbnailUrl() != null)
            virtualTour.setThumbnailUrl(dto.getThumbnailUrl());
        if (dto.getMetadataJson() != null)
            virtualTour.setMetadataJson(dto.getMetadataJson());

        HotelVirtualTour updatedVirtualTour = virtualTourRepository.save(virtualTour);
        log.info("Đã cập nhật Virtual Tour ID: {}", updatedVirtualTour.getVirtualTourId());

        return convertToDTO(updatedVirtualTour);
    }

    public void deleteVirtualTour(Integer virtualTourId) throws IOException {
        log.debug("Xóa Virtual Tour ID: {}", virtualTourId);
        HotelVirtualTour virtualTour = virtualTourRepository.findById(virtualTourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Virtual Tour id: " + virtualTourId));

        // Xóa media trên Cloudinary
        if (virtualTour.getMediaUrl() != null && !virtualTour.getMediaUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImage(virtualTour.getMediaUrl());
                log.info("Đã xóa media trên Cloudinary");
            } catch (Exception e) {
                log.error("Lỗi khi xóa media trên Cloudinary: {}", e.getMessage());
            }
        }

        // Xóa thumbnail trên Cloudinary
        if (virtualTour.getThumbnailUrl() != null && !virtualTour.getThumbnailUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImage(virtualTour.getThumbnailUrl());
                log.info("Đã xóa thumbnail trên Cloudinary");
            } catch (Exception e) {
                log.error("Lỗi khi xóa thumbnail trên Cloudinary: {}", e.getMessage());
            }
        }

        virtualTourRepository.delete(virtualTour);
        log.info("Đã xóa Virtual Tour ID: {}", virtualTourId);
    }

    private HotelVirtualTourDTO convertToDTO(HotelVirtualTour virtualTour) {
        return HotelVirtualTourDTO.builder()
                .virtualTourId(virtualTour.getVirtualTourId())
                .hotelId(virtualTour.getHotel() != null ? virtualTour.getHotel().getHotelId() : null)
                .mediaType(virtualTour.getMediaType() != null ? virtualTour.getMediaType().getValue() : null)
                .mediaUrl(virtualTour.getMediaUrl())
                .thumbnailUrl(virtualTour.getThumbnailUrl())
                .metadataJson(virtualTour.getMetadataJson())
                .createdAt(virtualTour.getCreatedAt())
                .updatedAt(virtualTour.getUpdatedAt())
                .build();
    }
}