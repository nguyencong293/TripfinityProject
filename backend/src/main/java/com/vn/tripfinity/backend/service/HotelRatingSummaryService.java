package com.vn.tripfinity.backend.service;

import com.vn.tripfinity.backend.dto.HotelRatingSummaryDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.HotelRatingSummary;
import com.vn.tripfinity.backend.model.HotelReview;
import com.vn.tripfinity.backend.model.HotelReviewAspects;
import com.vn.tripfinity.backend.repository.HotelRatingSummaryRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.HotelReviewAspectsRepository;
import com.vn.tripfinity.backend.repository.HotelReviewRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelRatingSummaryService {

        private final HotelRatingSummaryRepository summaryRepository;
        private final HotelRepository hotelRepository;
        private final HotelReviewRepository reviewRepository;
        private final HotelReviewAspectsRepository aspectsRepository;
        private final ProviderRepository providerRepository;

        public List<HotelRatingSummaryDTO> getAllSummaries() {
                log.debug("Lấy toàn bộ rating summaries");
                return summaryRepository.findAll().stream()
                                .map(this::convertToDTO)
                                .collect(Collectors.toList());
        }

        public HotelRatingSummaryDTO getSummaryByHotelId(Integer hotelId) {
                log.debug("Lấy rating summary theo Hotel ID: {}", hotelId);
                HotelRatingSummary summary = summaryRepository.findById(hotelId)
                                .orElseThrow(
                                                () -> new ResourceNotFoundException(
                                                                "Không tìm thấy Rating Summary cho Hotel id: "
                                                                                + hotelId));
                return convertToDTO(summary);
        }

        public HotelRatingSummaryDTO createOrUpdateSummary(Integer hotelId) {
                log.debug("Tạo/cập nhật rating summary cho Hotel ID: {}", hotelId);

                Hotel hotel = hotelRepository.findById(hotelId)
                                .orElseThrow(() -> new ResourceNotFoundException(
                                                "Không tìm thấy Hotel id: " + hotelId));

                // Lấy tất cả reviews đã approved của hotel
                List<HotelReview> reviews = reviewRepository.findByHotelAndStatus(hotelId,
                                HotelReview.ReviewStatus.approved);

                HotelRatingSummary summary = summaryRepository.findById(hotelId)
                                .orElse(HotelRatingSummary.builder()
                                                .hotelId(hotelId)
                                                .hotel(hotel)
                                                .build());

                // Tính toán các thống kê
                int totalReviews = reviews.size();
                summary.setTotalReviews(totalReviews);

                if (totalReviews > 0) {
                        // Tính avg rating
                        double avgRating = reviews.stream()
                                        .mapToInt(HotelReview::getRating)
                                        .average()
                                        .orElse(0.0);
                        summary.setAvgRating(BigDecimal.valueOf(avgRating).setScale(2, RoundingMode.HALF_UP));

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

                        List<HotelReviewAspects> aspects = aspectsRepository.findAllById(reviewIds);

                        if (!aspects.isEmpty()) {
                                double avgCleanliness = aspects.stream()
                                                .mapToInt(HotelReviewAspects::getCleanliness)
                                                .average()
                                                .orElse(0.0);
                                summary.setAvgCleanliness(
                                                BigDecimal.valueOf(avgCleanliness).setScale(2, RoundingMode.HALF_UP));

                                double avgService = aspects.stream()
                                                .mapToInt(HotelReviewAspects::getService)
                                                .average()
                                                .orElse(0.0);
                                summary.setAvgService(BigDecimal.valueOf(avgService).setScale(2, RoundingMode.HALF_UP));

                                double avgValueForMoney = aspects.stream()
                                                .mapToInt(HotelReviewAspects::getValueForMoney)
                                                .average()
                                                .orElse(0.0);
                                summary.setAvgValueForMoney(
                                                BigDecimal.valueOf(avgValueForMoney).setScale(2, RoundingMode.HALF_UP));

                                double avgLocation = aspects.stream()
                                                .mapToInt(HotelReviewAspects::getLocation)
                                                .average()
                                                .orElse(0.0);
                                summary.setAvgLocation(
                                                BigDecimal.valueOf(avgLocation).setScale(2, RoundingMode.HALF_UP));

                                double avgFacilities = aspects.stream()
                                                .mapToInt(HotelReviewAspects::getFacilities)
                                                .average()
                                                .orElse(0.0);
                                summary.setAvgFacilities(
                                                BigDecimal.valueOf(avgFacilities).setScale(2, RoundingMode.HALF_UP));
                        }

                        // Cập nhật rating average của hotel
                        hotel.setRatingAverage(summary.getAvgRating());
                        hotelRepository.save(hotel);
                } else {
                        // Reset về 0 nếu không có reviews
                        summary.setAvgRating(BigDecimal.ZERO);
                        summary.setCount1(0);
                        summary.setCount2(0);
                        summary.setCount3(0);
                        summary.setCount4(0);
                        summary.setCount5(0);
                        summary.setAvgCleanliness(null);
                        summary.setAvgService(null);
                        summary.setAvgValueForMoney(null);
                        summary.setAvgLocation(null);
                        summary.setAvgFacilities(null);

                        hotel.setRatingAverage(BigDecimal.ZERO);
                        hotelRepository.save(hotel);
                }

                HotelRatingSummary savedSummary = summaryRepository.save(summary);
                log.info("✅ Đã cập nhật Rating Summary cho Hotel ID: {} với {} reviews", hotelId, totalReviews);

                return convertToDTO(savedSummary);
        }

        public void deleteSummary(Integer hotelId) {
                log.debug("Xóa Rating Summary cho Hotel ID: {}", hotelId);
                HotelRatingSummary summary = summaryRepository.findById(hotelId)
                                .orElseThrow(
                                                () -> new ResourceNotFoundException(
                                                                "Không tìm thấy Rating Summary cho Hotel id: "
                                                                                + hotelId));

                summaryRepository.delete(summary);
                log.info("Đã xóa Rating Summary cho Hotel ID: {}", hotelId);
        }

        // ==================== MỚI: METHOD CHO PROVIDER ====================

        /**
         * Lấy tất cả rating summaries của các hotels thuộc một provider
         */
        public List<HotelRatingSummaryDTO> getSummariesByProvider(Integer providerId) {
                log.debug("Lấy danh sách rating summaries của Provider ID: {}", providerId);

                // Verify provider exists
                providerRepository.findById(providerId)
                                .orElseThrow(() -> new ResourceNotFoundException(
                                                "Không tìm thấy Provider id: " + providerId));

                List<HotelRatingSummary> summaries = summaryRepository.findByProvider_ProviderId(providerId);
                log.info("Tìm thấy {} rating summaries của Provider ID: {}", summaries.size(), providerId);

                return summaries.stream()
                                .map(this::convertToDTO)
                                .collect(Collectors.toList());
        }

        private HotelRatingSummaryDTO convertToDTO(HotelRatingSummary summary) {
                return HotelRatingSummaryDTO.builder()
                                .hotelId(summary.getHotelId())
                                .avgRating(summary.getAvgRating())
                                .totalReviews(summary.getTotalReviews())
                                .count1(summary.getCount1())
                                .count2(summary.getCount2())
                                .count3(summary.getCount3())
                                .count4(summary.getCount4())
                                .count5(summary.getCount5())
                                .avgCleanliness(summary.getAvgCleanliness())
                                .avgService(summary.getAvgService())
                                .avgValueForMoney(summary.getAvgValueForMoney())
                                .avgLocation(summary.getAvgLocation())
                                .avgFacilities(summary.getAvgFacilities())
                                .build();
        }
}