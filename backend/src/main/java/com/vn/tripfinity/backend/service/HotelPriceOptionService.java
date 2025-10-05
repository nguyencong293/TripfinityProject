package com.vn.tripfinity.backend.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vn.tripfinity.backend.dto.HotelPriceOptionDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.HotelPriceOption;
import com.vn.tripfinity.backend.repository.HotelPriceOptionRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelPriceOptionService {

    private final HotelPriceOptionRepository optionRepository;
    private final HotelRepository hotelRepository;
    private final ObjectMapper objectMapper;

    public List<HotelPriceOptionDTO> getAllOptions() {
        log.debug("Lấy toàn bộ price options");
        return optionRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelPriceOptionDTO getOptionById(Integer optionId) {
        log.debug("Lấy price option theo ID: {}", optionId);
        HotelPriceOption option = optionRepository.findById(optionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Price Option id: " + optionId));
        return convertToDTO(option);
    }

    public List<HotelPriceOptionDTO> getOptionsByHotel(Integer hotelId) {
        log.debug("Lấy danh sách price options của Hotel ID: {}", hotelId);
        hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        List<HotelPriceOption> options = optionRepository.findByHotel_HotelId(hotelId);
        log.info("Tìm thấy {} price options của Hotel ID: {}", options.size(), hotelId);

        return options.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelPriceOptionDTO createOption(HotelPriceOptionDTO dto) {
        log.debug("Tạo Price Option: {}", dto);

        Hotel hotel = hotelRepository.findById(dto.getHotelId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + dto.getHotelId()));

        // Kiểm tra trùng option name cho hotel
        if (optionRepository.existsByHotel_HotelIdAndOptionName(dto.getHotelId(), dto.getOptionName())) {
            throw new IllegalStateException("Option name đã tồn tại cho hotel này: " + dto.getOptionName());
        }

        HotelPriceOption option = HotelPriceOption.builder()
                .hotel(hotel)
                .optionName(dto.getOptionName())
                .price(dto.getPrice())
                .currencyCode(dto.getCurrencyCode())
                .perPerson(dto.getPerPerson() != null ? dto.getPerPerson() : true)
                .minAge(dto.getMinAge())
                .maxAge(dto.getMaxAge())
                .description(dto.getDescription())
                .includesJson(stringListToJson(dto.getIncludesJson()))
                .build();

        HotelPriceOption savedOption = optionRepository.save(option);
        log.info("✅ Tạo Price Option ID: {}", savedOption.getOptionId());

        return convertToDTO(savedOption);
    }

    public HotelPriceOptionDTO updateOption(Integer optionId, HotelPriceOptionDTO dto) {
        log.debug("Cập nhật Price Option ID: {}", optionId);
        HotelPriceOption option = optionRepository.findById(optionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Price Option id: " + optionId));

        if (dto.getOptionName() != null && !dto.getOptionName().equals(option.getOptionName())) {
            // Kiểm tra trùng option name
            if (optionRepository.existsByHotel_HotelIdAndOptionName(option.getHotel().getHotelId(),
                    dto.getOptionName())) {
                throw new IllegalStateException("Option name đã tồn tại cho hotel này: " + dto.getOptionName());
            }
            option.setOptionName(dto.getOptionName());
        }

        if (dto.getPrice() != null)
            option.setPrice(dto.getPrice());
        if (dto.getCurrencyCode() != null)
            option.setCurrencyCode(dto.getCurrencyCode());
        if (dto.getPerPerson() != null)
            option.setPerPerson(dto.getPerPerson());
        if (dto.getMinAge() != null)
            option.setMinAge(dto.getMinAge());
        if (dto.getMaxAge() != null)
            option.setMaxAge(dto.getMaxAge());
        if (dto.getDescription() != null)
            option.setDescription(dto.getDescription());
        if (dto.getIncludesJson() != null)
            option.setIncludesJson(stringListToJson(dto.getIncludesJson()));

        HotelPriceOption updatedOption = optionRepository.save(option);
        log.info("Đã cập nhật Price Option ID: {}", updatedOption.getOptionId());

        return convertToDTO(updatedOption);
    }

    public void deleteOption(Integer optionId) {
        log.debug("Xóa Price Option ID: {}", optionId);
        HotelPriceOption option = optionRepository.findById(optionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Price Option id: " + optionId));

        optionRepository.delete(option);
        log.info("Đã xóa Price Option ID: {}", optionId);
    }

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

    private List<String> jsonToStringList(String json) {
        if (json == null || json.trim().isEmpty()) {
            return new ArrayList<>();
        }
        try {
            List<String> list = objectMapper.readValue(json, new TypeReference<List<String>>() {
            });
            return list != null ? list : new ArrayList<>();
        } catch (JsonProcessingException e) {
            log.error("Error converting JSON to string list: {}", json, e);
            return new ArrayList<>();
        }
    }

    private HotelPriceOptionDTO convertToDTO(HotelPriceOption option) {
        return HotelPriceOptionDTO.builder()
                .optionId(option.getOptionId())
                .hotelId(option.getHotel() != null ? option.getHotel().getHotelId() : null)
                .optionName(option.getOptionName())
                .price(option.getPrice())
                .currencyCode(option.getCurrencyCode())
                .perPerson(option.getPerPerson())
                .minAge(option.getMinAge())
                .maxAge(option.getMaxAge())
                .description(option.getDescription())
                .includesJson(jsonToStringList(option.getIncludesJson()))
                .createdAt(option.getCreatedAt())
                .updatedAt(option.getUpdatedAt())
                .build();
    }
}