package com.vn.tripfinity.backend.service;

import com.vn.tripfinity.backend.dto.ProviderDTO;
import com.vn.tripfinity.backend.exception.DuplicateResourceException;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.UserRepository;
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
public class ProviderService {

    private final ProviderRepository providerRepository;
    private final UserRepository userRepository;

    public List<ProviderDTO> getAllProviders() {
        return providerRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public ProviderDTO getProviderById(Integer providerId) {
        Provider p = providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));
        return toDTO(p);
    }

    public List<ProviderDTO> getProvidersByUserId(Integer userId) {
        return providerRepository.findByUser_UserId(userId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public ProviderDTO createProvider(ProviderDTO dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        // Chỉ cho phép user có role PROVIDER
        if (user.getAccountRole() != User.AccountRole.provider) {
            throw new IllegalArgumentException("Chỉ tài khoản có role 'provider' mới được tạo hồ sơ provider.");
        }

        // Ràng buộc: 1 user chỉ có 1 hồ sơ provider
        if (providerRepository.existsByUser_UserId(user.getUserId())) {
            throw new DuplicateResourceException("Người dùng đã có hồ sơ provider");
        }

        Provider entity = Provider.builder()
                .providerId(null)
                .user(user)
                .companyName(dto.getCompanyName())
                .taxCode(dto.getTaxCode())
                .address(dto.getAddress())
                .contactEmail(dto.getContactEmail())
                .contactPhone(dto.getContactPhone())
                .bankAccountNumber(dto.getBankAccountNumber())
                .bankName(dto.getBankName())
                .logoUrl(dto.getLogoUrl())
                .providerDescription(dto.getProviderDescription())
                .ratingOverall(dto.getRatingOverall() != null ? dto.getRatingOverall() : new BigDecimal("0.00"))
                .providerStatus(dto.getProviderStatus() != null
                        ? Provider.ProviderStatus.valueOf(dto.getProviderStatus())
                        : Provider.ProviderStatus.pending)
                .build();

        Provider saved = providerRepository.save(entity);
        log.info("Tạo Provider ID: {}", saved.getProviderId());
        return toDTO(saved);
    }

    public ProviderDTO updateProvider(Integer providerId, ProviderDTO dto) {
        Provider existing = providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        if (dto.getUserId() != null &&
                (existing.getUser() == null || !existing.getUser().getUserId().equals(dto.getUserId()))) {
            User newUser = userRepository.findById(dto.getUserId())
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

            // Chỉ cho phép đổi sang user có role PROVIDER
            if (newUser.getAccountRole() != User.AccountRole.provider) {
                throw new IllegalArgumentException(
                        "Chỉ tài khoản có role 'provider' mới được liên kết với hồ sơ provider.");
            }

            if (providerRepository.existsByUser_UserId(newUser.getUserId())
                    && !existing.getUser().getUserId().equals(newUser.getUserId())) {
                throw new DuplicateResourceException("Người dùng đã có hồ sơ provider");
            }
            existing.setUser(newUser);
        }

        if (dto.getCompanyName() != null)
            existing.setCompanyName(dto.getCompanyName());
        if (dto.getTaxCode() != null)
            existing.setTaxCode(dto.getTaxCode());
        if (dto.getAddress() != null)
            existing.setAddress(dto.getAddress());
        if (dto.getContactEmail() != null)
            existing.setContactEmail(dto.getContactEmail());
        if (dto.getContactPhone() != null)
            existing.setContactPhone(dto.getContactPhone());
        if (dto.getBankAccountNumber() != null)
            existing.setBankAccountNumber(dto.getBankAccountNumber());
        if (dto.getBankName() != null)
            existing.setBankName(dto.getBankName());
        if (dto.getLogoUrl() != null)
            existing.setLogoUrl(dto.getLogoUrl());
        if (dto.getProviderDescription() != null)
            existing.setProviderDescription(dto.getProviderDescription());
        if (dto.getRatingOverall() != null)
            existing.setRatingOverall(dto.getRatingOverall());
        if (dto.getProviderStatus() != null)
            existing.setProviderStatus(Provider.ProviderStatus.valueOf(dto.getProviderStatus()));

        Provider saved = providerRepository.save(existing);
        return toDTO(saved);
    }

    public void deleteProvider(Integer providerId) {
        Provider existing = providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));
        providerRepository.delete(existing);
        log.info("Đã xóa Provider id: {}", providerId);
    }

    private ProviderDTO toDTO(Provider p) {
        return ProviderDTO.builder()
                .providerId(p.getProviderId())
                .userId(p.getUser() != null ? p.getUser().getUserId() : null)
                .companyName(p.getCompanyName())
                .taxCode(p.getTaxCode())
                .address(p.getAddress())
                .contactEmail(p.getContactEmail())
                .contactPhone(p.getContactPhone())
                .bankAccountNumber(p.getBankAccountNumber())
                .bankName(p.getBankName())
                .logoUrl(p.getLogoUrl())
                .providerDescription(p.getProviderDescription())
                .ratingOverall(p.getRatingOverall())
                .providerStatus(p.getProviderStatus() != null ? p.getProviderStatus().name() : null)
                .createdAt(p.getCreatedAt())
                .updatedAt(p.getUpdatedAt())
                .build();
    }
}