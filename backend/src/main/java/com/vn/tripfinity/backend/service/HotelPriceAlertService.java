package com.vn.tripfinity.backend.service;

import com.vn.tripfinity.backend.dto.HotelPriceAlertDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.HotelPriceAlert;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.HotelPriceAlertRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelPriceAlertService {

    private final HotelPriceAlertRepository alertRepository;
    private final UserRepository userRepository;
    private final HotelRepository hotelRepository;
    private final ProviderRepository providerRepository;

    public List<HotelPriceAlertDTO> getAllAlerts() {
        log.debug("Lấy toàn bộ price alerts");
        return alertRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelPriceAlertDTO getAlertById(Integer alertId) {
        log.debug("Lấy price alert theo ID: {}", alertId);
        HotelPriceAlert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Price Alert id: " + alertId));
        return convertToDTO(alert);
    }

    public List<HotelPriceAlertDTO> getAlertsByUser(Integer userId) {
        log.debug("Lấy danh sách price alerts của User ID: {}", userId);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        List<HotelPriceAlert> alerts = alertRepository.findByUser_UserId(userId);
        log.info("Tìm thấy {} price alerts của User ID: {}", alerts.size(), userId);

        return alerts.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelPriceAlertDTO> getAlertsByHotel(Integer hotelId) {
        log.debug("Lấy danh sách price alerts của Hotel ID: {}", hotelId);
        hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        List<HotelPriceAlert> alerts = alertRepository.findByHotel_HotelId(hotelId);
        log.info("Tìm thấy {} price alerts của Hotel ID: {}", alerts.size(), hotelId);

        return alerts.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelPriceAlertDTO> getActiveAlertsByUser(Integer userId) {
        log.debug("Lấy danh sách price alerts active của User ID: {}", userId);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        List<HotelPriceAlert> alerts = alertRepository.findByUserAndActive(userId, true);

        return alerts.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelPriceAlertDTO createAlert(HotelPriceAlertDTO dto) {
        log.debug("Tạo Price Alert: {}", dto);

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        Hotel hotel = hotelRepository.findById(dto.getHotelId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + dto.getHotelId()));

        HotelPriceAlert alert = HotelPriceAlert.builder()
                .user(user)
                .hotel(hotel)
                .targetPrice(dto.getTargetPrice())
                .currencyCode(dto.getCurrencyCode())
                .isActive(dto.getIsActive() != null ? dto.getIsActive() : true)
                .build();

        HotelPriceAlert savedAlert = alertRepository.save(alert);
        log.info("✅ Tạo Price Alert ID: {}", savedAlert.getAlertId());

        return convertToDTO(savedAlert);
    }

    public HotelPriceAlertDTO updateAlert(Integer alertId, HotelPriceAlertDTO dto) {
        log.debug("Cập nhật Price Alert ID: {}", alertId);
        HotelPriceAlert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Price Alert id: " + alertId));

        if (dto.getTargetPrice() != null)
            alert.setTargetPrice(dto.getTargetPrice());
        if (dto.getCurrencyCode() != null)
            alert.setCurrencyCode(dto.getCurrencyCode());
        if (dto.getIsActive() != null)
            alert.setIsActive(dto.getIsActive());
        if (dto.getLastNotifiedAt() != null)
            alert.setLastNotifiedAt(dto.getLastNotifiedAt());

        HotelPriceAlert updatedAlert = alertRepository.save(alert);
        log.info("Đã cập nhật Price Alert ID: {}", updatedAlert.getAlertId());

        return convertToDTO(updatedAlert);
    }

    public HotelPriceAlertDTO toggleAlertStatus(Integer alertId) {
        log.debug("Toggle status Price Alert ID: {}", alertId);
        HotelPriceAlert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Price Alert id: " + alertId));

        alert.setIsActive(!alert.getIsActive());
        HotelPriceAlert updatedAlert = alertRepository.save(alert);
        log.info("Đã toggle status Price Alert ID: {} sang: {}", updatedAlert.getAlertId(), updatedAlert.getIsActive());

        return convertToDTO(updatedAlert);
    }

    public HotelPriceAlertDTO markAsNotified(Integer alertId) {
        log.debug("Đánh dấu đã thông báo Price Alert ID: {}", alertId);
        HotelPriceAlert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Price Alert id: " + alertId));

        alert.setLastNotifiedAt(LocalDateTime.now());
        HotelPriceAlert updatedAlert = alertRepository.save(alert);
        log.info("Đã đánh dấu thông báo Price Alert ID: {}", updatedAlert.getAlertId());

        return convertToDTO(updatedAlert);
    }

    public void deleteAlert(Integer alertId) {
        log.debug("Xóa Price Alert ID: {}", alertId);
        HotelPriceAlert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Price Alert id: " + alertId));

        alertRepository.delete(alert);
        log.info("Đã xóa Price Alert ID: {}", alertId);
    }

    public List<HotelPriceAlertDTO> checkAndGetTriggeredAlerts(Integer hotelId, BigDecimal currentPrice) {
        log.debug("Kiểm tra alerts được kích hoạt cho Hotel ID: {} với giá: {}", hotelId, currentPrice);

        List<HotelPriceAlert> triggeredAlerts = alertRepository.findActiveAlertsTriggered(hotelId, currentPrice);
        log.info("Tìm thấy {} alerts được kích hoạt", triggeredAlerts.size());

        return triggeredAlerts.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // ==================== MỚI: METHODS CHO PROVIDER ====================

    /**
     * Lấy tất cả price alerts của các hotels thuộc một provider
     */
    public List<HotelPriceAlertDTO> getAlertsByProvider(Integer providerId) {
        log.debug("Lấy danh sách price alerts của Provider ID: {}", providerId);

        // Verify provider exists
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<HotelPriceAlert> alerts = alertRepository.findByProvider_ProviderId(providerId);
        log.info("Tìm thấy {} price alerts của Provider ID: {}", alerts.size(), providerId);

        return alerts.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Lấy active price alerts của các hotels thuộc một provider
     */
    public List<HotelPriceAlertDTO> getActiveAlertsByProvider(Integer providerId) {
        log.debug("Lấy danh sách active price alerts của Provider ID: {}", providerId);

        // Verify provider exists
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<HotelPriceAlert> alerts = alertRepository.findActiveByProvider_ProviderId(providerId);
        log.info("Tìm thấy {} active price alerts của Provider ID: {}", alerts.size(), providerId);

        return alerts.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private HotelPriceAlertDTO convertToDTO(HotelPriceAlert alert) {
        return HotelPriceAlertDTO.builder()
                .alertId(alert.getAlertId())
                .userId(alert.getUser() != null ? alert.getUser().getUserId() : null)
                .hotelId(alert.getHotel() != null ? alert.getHotel().getHotelId() : null)
                .targetPrice(alert.getTargetPrice())
                .currencyCode(alert.getCurrencyCode())
                .isActive(alert.getIsActive())
                .lastNotifiedAt(alert.getLastNotifiedAt())
                .createdAt(alert.getCreatedAt())
                .updatedAt(alert.getUpdatedAt())
                .build();
    }
}