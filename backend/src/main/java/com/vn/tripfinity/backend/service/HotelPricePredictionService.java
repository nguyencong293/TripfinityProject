package com.vn.tripfinity.backend.service;

import com.vn.tripfinity.backend.dto.HotelPricePredictionDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.HotelPricePrediction;
import com.vn.tripfinity.backend.repository.HotelPricePredictionRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelPricePredictionService {

    private final HotelPricePredictionRepository predictionRepository;
    private final HotelRepository hotelRepository;

    public List<HotelPricePredictionDTO> getAllPredictions() {
        log.debug("Lấy toàn bộ price predictions");
        return predictionRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelPricePredictionDTO getPredictionById(Integer predictionId) {
        log.debug("Lấy price prediction theo ID: {}", predictionId);
        HotelPricePrediction prediction = predictionRepository.findById(predictionId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Không tìm thấy Price Prediction id: " + predictionId));
        return convertToDTO(prediction);
    }

    public List<HotelPricePredictionDTO> getPredictionsByHotel(Integer hotelId) {
        log.debug("Lấy danh sách price predictions của Hotel ID: {}", hotelId);
        hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        List<HotelPricePrediction> predictions = predictionRepository.findByHotel_HotelId(hotelId);
        log.info("Tìm thấy {} price predictions của Hotel ID: {}", predictions.size(), hotelId);

        return predictions.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelPricePredictionDTO getPredictionByHotelAndDate(Integer hotelId, LocalDate predictedDate) {
        log.debug("Lấy price prediction của Hotel ID: {} cho ngày: {}", hotelId, predictedDate);
        HotelPricePrediction prediction = predictionRepository
                .findByHotel_HotelIdAndPredictedDate(hotelId, predictedDate)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy Price Prediction cho Hotel id: " + hotelId + " và ngày: " + predictedDate));
        return convertToDTO(prediction);
    }

    public List<HotelPricePredictionDTO> getPredictionsByHotelAndDateRange(Integer hotelId, LocalDate startDate,
            LocalDate endDate) {
        log.debug("Lấy price predictions của Hotel ID: {} từ {} đến {}", hotelId, startDate, endDate);
        hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        List<HotelPricePrediction> predictions = predictionRepository.findByHotelAndDateRange(hotelId, startDate,
                endDate);
        log.info("Tìm thấy {} price predictions", predictions.size());

        return predictions.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelPricePredictionDTO createPrediction(HotelPricePredictionDTO dto) {
        log.debug("Tạo Price Prediction: {}", dto);

        Hotel hotel = hotelRepository.findById(dto.getHotelId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + dto.getHotelId()));

        HotelPricePrediction prediction = HotelPricePrediction.builder()
                .hotel(hotel)
                .predictedDate(dto.getPredictedDate())
                .predictedPrice(dto.getPredictedPrice())
                .currencyCode(dto.getCurrencyCode())
                .modelName(dto.getModelName())
                .build();

        HotelPricePrediction savedPrediction = predictionRepository.save(prediction);
        log.info("✅ Tạo Price Prediction ID: {}", savedPrediction.getPredictionId());

        return convertToDTO(savedPrediction);
    }

    public HotelPricePredictionDTO updatePrediction(Integer predictionId, HotelPricePredictionDTO dto) {
        log.debug("Cập nhật Price Prediction ID: {}", predictionId);
        HotelPricePrediction prediction = predictionRepository.findById(predictionId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Không tìm thấy Price Prediction id: " + predictionId));

        if (dto.getPredictedDate() != null)
            prediction.setPredictedDate(dto.getPredictedDate());
        if (dto.getPredictedPrice() != null)
            prediction.setPredictedPrice(dto.getPredictedPrice());
        if (dto.getCurrencyCode() != null)
            prediction.setCurrencyCode(dto.getCurrencyCode());
        if (dto.getModelName() != null)
            prediction.setModelName(dto.getModelName());

        HotelPricePrediction updatedPrediction = predictionRepository.save(prediction);
        log.info("Đã cập nhật Price Prediction ID: {}", updatedPrediction.getPredictionId());

        return convertToDTO(updatedPrediction);
    }

    public void deletePrediction(Integer predictionId) {
        log.debug("Xóa Price Prediction ID: {}", predictionId);
        HotelPricePrediction prediction = predictionRepository.findById(predictionId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Không tìm thấy Price Prediction id: " + predictionId));

        predictionRepository.delete(prediction);
        log.info("Đã xóa Price Prediction ID: {}", predictionId);
    }

    private HotelPricePredictionDTO convertToDTO(HotelPricePrediction prediction) {
        return HotelPricePredictionDTO.builder()
                .predictionId(prediction.getPredictionId())
                .hotelId(prediction.getHotel() != null ? prediction.getHotel().getHotelId() : null)
                .predictedDate(prediction.getPredictedDate())
                .predictedPrice(prediction.getPredictedPrice())
                .currencyCode(prediction.getCurrencyCode())
                .modelName(prediction.getModelName())
                .createdAt(prediction.getCreatedAt())
                .build();
    }
}