package com.vn.tripfinity.backend.sevice;

import com.vn.tripfinity.backend.dto.AreaDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Area;
import com.vn.tripfinity.backend.repository.AreaRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.RestaurantRepository;
import com.vn.tripfinity.backend.repository.AttractionRepository;
import com.vn.tripfinity.backend.repository.TourRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
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
public class AreaService {

    private final AreaRepository areaRepository;
    private final HotelRepository hotelRepository;
    private final RestaurantRepository restaurantRepository;
    private final AttractionRepository attractionRepository;
    private final TourRepository tourRepository;

    public List<AreaDTO> getAll() {
        return areaRepository.findAll().stream().map(this::toDTOWithAggregates).collect(Collectors.toList());
    }

    public AreaDTO getById(Integer id) {
        Area a = areaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + id));
        return toDTOWithAggregates(a);
    }

    public AreaDTO getBySlug(String slug) {
        Area a = areaRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area slug: " + slug));
        return toDTOWithAggregates(a);
    }

    public AreaDTO create(AreaDTO dto) {
        // slug unique at DB level; let DB enforce; optionally pre-check
        Area entity = Area.builder()
                .areaId(null)
                .name(dto.getName())
                .slug(dto.getSlug())
                .areaType(dto.getAreaType() != null ? Area.AreaType.valueOf(dto.getAreaType()) : Area.AreaType.province)
                .shortDescription(dto.getShortDescription())
                .coverImageUrl(dto.getCoverImageUrl())
                .build();
        try {
            Area saved = areaRepository.save(entity);
            // initialize stats as 0.00/0; aggregates can be recalculated via endpoints
            saved.setAvgRating(new BigDecimal("0.00"));
            saved.setRatingsCount(0);
            saved = areaRepository.save(saved);
            log.info("Tạo Area ID: {}", saved.getAreaId());
            return toDTO(saved);
        } catch (DataIntegrityViolationException e) {
            throw new IllegalArgumentException("Slug đã tồn tại: " + dto.getSlug());
        }
    }

    public AreaDTO update(Integer id, AreaDTO dto) {
        Area existing = areaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + id));

        if (dto.getName() != null)
            existing.setName(dto.getName());
        if (dto.getSlug() != null)
            existing.setSlug(dto.getSlug());
        if (dto.getAreaType() != null)
            existing.setAreaType(Area.AreaType.valueOf(dto.getAreaType()));
        if (dto.getShortDescription() != null)
            existing.setShortDescription(dto.getShortDescription());
        if (dto.getCoverImageUrl() != null)
            existing.setCoverImageUrl(dto.getCoverImageUrl());
        // avgRating/ratingsCount are derived; ignore direct external updates here

        try {
            Area saved = areaRepository.save(existing);
            return toDTO(saved);
        } catch (DataIntegrityViolationException e) {
            throw new IllegalArgumentException("Slug đã tồn tại: " + dto.getSlug());
        }
    }

    public void delete(Integer id) {
        Area existing = areaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + id));
        areaRepository.delete(existing);
        log.info("Đã xóa Area id: {}", id);
    }

    private AreaDTO toDTO(Area a) {
        return AreaDTO.builder()
                .areaId(a.getAreaId())
                .name(a.getName())
                .slug(a.getSlug())
                .areaType(a.getAreaType() != null ? a.getAreaType().name() : null)
                .shortDescription(a.getShortDescription())
                .coverImageUrl(a.getCoverImageUrl())
                .avgRating(a.getAvgRating())
                .ratingsCount(a.getRatingsCount())
                .createdAt(a.getCreatedAt())
                .updatedAt(a.getUpdatedAt())
                .build();
    }

    // Build DTO and compute avgRating/ratingsCount on-the-fly from current children
    private AreaDTO toDTOWithAggregates(Area a) {
        AreaDTO dto = toDTO(a);
        Integer id = a.getAreaId();

        long countHotels = hotelRepository.countByArea_AreaId(id);
        long countRestaurants = restaurantRepository.countByArea_AreaId(id);
        long countAttractions = attractionRepository.countByArea_AreaId(id);
        long countTours = tourRepository.countByArea_AreaId(id);

        long total = countHotels + countRestaurants + countAttractions + countTours;

        BigDecimal sum = BigDecimal.ZERO;
        Double sH = hotelRepository.sumRatingAverageByArea(id);
        Double sR = restaurantRepository.sumRatingAverageByArea(id);
        Double sA = attractionRepository.sumRatingAverageByArea(id);
        Double sT = tourRepository.sumRatingAverageByArea(id);
        if (sH != null)
            sum = sum.add(BigDecimal.valueOf(sH));
        if (sR != null)
            sum = sum.add(BigDecimal.valueOf(sR));
        if (sA != null)
            sum = sum.add(BigDecimal.valueOf(sA));
        if (sT != null)
            sum = sum.add(BigDecimal.valueOf(sT));

        BigDecimal avg = total > 0 ? sum.divide(BigDecimal.valueOf(total), 2, RoundingMode.HALF_UP)
                : new BigDecimal("0.00");

        dto.setAvgRating(avg);
        dto.setRatingsCount((int) total);
        return dto;
    }

    // ==== Aggregations per area (avgRating & ratingsCount) ====
    public AreaDTO recalc(Integer areaId) {
        Area a = areaRepository.findById(areaId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Area id: " + areaId));
        recalcAndPersist(a);
        return toDTO(a);
    }

    public int recalcAll() {
        List<Area> areas = areaRepository.findAll();
        for (Area a : areas) {
            recalcAndPersist(a);
        }
        return areas.size();
    }

    private void recalcAndPersist(Area a) {
        Integer id = a.getAreaId();
        long countHotels = hotelRepository.countByArea_AreaId(id);
        long countRestaurants = restaurantRepository.countByArea_AreaId(id);
        long countAttractions = attractionRepository.countByArea_AreaId(id);
        long countTours = tourRepository.countByArea_AreaId(id);

        long total = countHotels + countRestaurants + countAttractions + countTours;

        BigDecimal sum = BigDecimal.ZERO;
        Double sH = hotelRepository.sumRatingAverageByArea(id);
        Double sR = restaurantRepository.sumRatingAverageByArea(id);
        Double sA = attractionRepository.sumRatingAverageByArea(id);
        Double sT = tourRepository.sumRatingAverageByArea(id);
        if (sH != null)
            sum = sum.add(BigDecimal.valueOf(sH));
        if (sR != null)
            sum = sum.add(BigDecimal.valueOf(sR));
        if (sA != null)
            sum = sum.add(BigDecimal.valueOf(sA));
        if (sT != null)
            sum = sum.add(BigDecimal.valueOf(sT));

        BigDecimal avg = total > 0 ? sum.divide(BigDecimal.valueOf(total), 2, RoundingMode.HALF_UP)
                : new BigDecimal("0.00");

        a.setAvgRating(avg);
        a.setRatingsCount((int) total);
        areaRepository.save(a);
    }
}
