package com.vn.tripfinity.backend.sevice;

import com.vn.tripfinity.backend.dto.ServiceTripDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.ServiceTrip;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.ServiceTripRepository;
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
public class ServiceTripService {

    private final ServiceTripRepository serviceTripRepository;
    private final ProviderRepository providerRepository;

    public List<ServiceTripDTO> getAllServiceTrips() {
        log.debug("Lấy toàn bộ ServiceTrip");
        return serviceTripRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public ServiceTripDTO getServiceTripById(Integer id) {
        ServiceTrip s = serviceTripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy ServiceTrip id: " + id));
        return convertToDTO(s);
    }

    public List<ServiceTripDTO> getServiceTripsByProvider(Integer providerId) {
        return serviceTripRepository.findByProvider_ProviderId(providerId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public ServiceTripDTO createServiceTrip(ServiceTripDTO dto) {
        Provider provider = providerRepository.findById(dto.getProviderId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));

        ServiceTrip entity = convertToEntity(dto, provider);
        entity.setServiceId(null);
        if (entity.getRatingAverage() == null) {
            entity.setRatingAverage(BigDecimal.ZERO);
        }
        ServiceTrip saved = serviceTripRepository.save(entity);
        log.info("Tạo ServiceTrip ID: {}", saved.getServiceId());
        return convertToDTO(saved);
    }

    public ServiceTripDTO updateServiceTrip(Integer id, ServiceTripDTO dto) {
        ServiceTrip existing = serviceTripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy ServiceTrip id: " + id));

        if (dto.getProviderId() != null &&
                (existing.getProvider() == null
                        || !existing.getProvider().getProviderId().equals(dto.getProviderId()))) {
            Provider provider = providerRepository.findById(dto.getProviderId())
                    .orElseThrow(
                            () -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
            existing.setProvider(provider);
        }

        applyServiceTripUpdates(existing, dto);
        ServiceTrip saved = serviceTripRepository.save(existing);
        return convertToDTO(saved);
    }

    public void deleteServiceTrip(Integer id) {
        ServiceTrip existing = serviceTripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy ServiceTrip id: " + id));
        serviceTripRepository.delete(existing);
        log.info("Đã xóa ServiceTrip id: {}", id);
    }

    private void applyServiceTripUpdates(ServiceTrip e, ServiceTripDTO d) {
        if (d.getServiceType() != null)
            e.setServiceType(ServiceTrip.ServiceType.valueOf(d.getServiceType()));
        if (d.getTitle() != null)
            e.setTitle(d.getTitle());
        if (d.getServiceDescription() != null)
            e.setServiceDescription(d.getServiceDescription());
        if (d.getLocation() != null)
            e.setLocation(d.getLocation());
        if (d.getStartDate() != null)
            e.setStartDate(d.getStartDate());
        if (d.getEndDate() != null)
            e.setEndDate(d.getEndDate());
        if (d.getPrice() != null)
            e.setPrice(d.getPrice());
        if (d.getCurrencyCode() != null)
            e.setCurrencyCode(d.getCurrencyCode());
        if (d.getCapacity() != null)
            e.setCapacity(d.getCapacity());
        if (d.getMinParticipants() != null)
            e.setMinParticipants(d.getMinParticipants());
        if (d.getMaxParticipants() != null)
            e.setMaxParticipants(d.getMaxParticipants());
        if (d.getThumbnailUrl() != null)
            e.setThumbnailUrl(d.getThumbnailUrl());
        if (d.getImageUrls() != null)
            e.setImageUrls(d.getImageUrls());
        if (d.getRatingAverage() != null)
            e.setRatingAverage(d.getRatingAverage());
        if (d.getBadges() != null)
            e.setBadges(d.getBadges());
        if (d.getServiceStatus() != null)
            e.setServiceStatus(ServiceTrip.ServiceStatus.valueOf(d.getServiceStatus()));
    }

    private ServiceTripDTO convertToDTO(ServiceTrip s) {
        return ServiceTripDTO.builder()
                .serviceId(s.getServiceId())
                .providerId(s.getProvider() != null ? s.getProvider().getProviderId() : null)
                .serviceType(s.getServiceType() != null ? s.getServiceType().name() : null)
                .title(s.getTitle())
                .serviceDescription(s.getServiceDescription())
                .location(s.getLocation())
                .startDate(s.getStartDate())
                .endDate(s.getEndDate())
                .price(s.getPrice())
                .currencyCode(s.getCurrencyCode())
                .capacity(s.getCapacity())
                .minParticipants(s.getMinParticipants())
                .maxParticipants(s.getMaxParticipants())
                .thumbnailUrl(s.getThumbnailUrl())
                .imageUrls(s.getImageUrls())
                .ratingAverage(s.getRatingAverage())
                .badges(s.getBadges())
                .serviceStatus(s.getServiceStatus() != null ? s.getServiceStatus().name() : null)
                .createdAt(s.getCreatedAt())
                .updatedAt(s.getUpdatedAt())
                .build();
    }

    private ServiceTrip convertToEntity(ServiceTripDTO d, Provider provider) {
        return ServiceTrip.builder()
                .serviceId(d.getServiceId())
                .provider(provider)
                .serviceType(d.getServiceType() != null ? ServiceTrip.ServiceType.valueOf(d.getServiceType()) : null)
                .title(d.getTitle())
                .serviceDescription(d.getServiceDescription())
                .location(d.getLocation())
                .startDate(d.getStartDate())
                .endDate(d.getEndDate())
                .price(d.getPrice())
                .currencyCode(d.getCurrencyCode())
                .capacity(d.getCapacity())
                .minParticipants(d.getMinParticipants())
                .maxParticipants(d.getMaxParticipants())
                .thumbnailUrl(d.getThumbnailUrl())
                .imageUrls(d.getImageUrls())
                .ratingAverage(d.getRatingAverage())
                .badges(d.getBadges())
                .serviceStatus(
                        d.getServiceStatus() != null ? ServiceTrip.ServiceStatus.valueOf(d.getServiceStatus()) : null)
                .createdAt(d.getCreatedAt())
                .updatedAt(d.getUpdatedAt())
                .build();
    }
}