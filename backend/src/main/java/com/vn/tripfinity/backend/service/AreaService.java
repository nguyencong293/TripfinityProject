package com.vn.tripfinity.backend.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.AreaDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Area;
import com.vn.tripfinity.backend.repository.AreaRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AreaService {

    private final AreaRepository areaRepository;

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
                .createdAt(a.getCreatedAt())
                .updatedAt(a.getUpdatedAt())
                .build();
    }

    // Build DTO with aggregates
    private AreaDTO toDTOWithAggregates(Area a) {
        return toDTO(a);
    }

}
