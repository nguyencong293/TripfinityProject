package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.HotelPriceOptionDTO;
import com.vn.tripfinity.backend.service.HotelPriceOptionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/hotel-price-options")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelPriceOptionController {

    private final HotelPriceOptionService optionService;

    @GetMapping
    public ResponseEntity<List<HotelPriceOptionDTO>> getAllOptions() {
        log.info("GET /api/hotel-price-options - Lấy toàn bộ price options");
        List<HotelPriceOptionDTO> options = optionService.getAllOptions();
        return ResponseEntity.ok(options);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HotelPriceOptionDTO> getOptionById(@PathVariable Integer id) {
        log.info("GET /api/hotel-price-options/{} - Lấy price option theo ID", id);
        HotelPriceOptionDTO option = optionService.getOptionById(id);
        return ResponseEntity.ok(option);
    }

    @GetMapping("/hotel/{hotelId}")
    public ResponseEntity<List<HotelPriceOptionDTO>> getOptionsByHotel(@PathVariable Integer hotelId) {
        log.info("GET /api/hotel-price-options/hotel/{} - Lấy price options của hotel", hotelId);
        List<HotelPriceOptionDTO> options = optionService.getOptionsByHotel(hotelId);
        return ResponseEntity.ok(options);
    }

    @PostMapping
    public ResponseEntity<HotelPriceOptionDTO> createOption(@Valid @RequestBody HotelPriceOptionDTO dto) {
        log.info("POST /api/hotel-price-options - Tạo price option mới");
        HotelPriceOptionDTO createdOption = optionService.createOption(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdOption);
    }

    @PutMapping("/{id}")
    public ResponseEntity<HotelPriceOptionDTO> updateOption(
            @PathVariable Integer id,
            @Valid @RequestBody HotelPriceOptionDTO dto) {
        log.info("PUT /api/hotel-price-options/{} - Cập nhật price option", id);
        HotelPriceOptionDTO updatedOption = optionService.updateOption(id, dto);
        return ResponseEntity.ok(updatedOption);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteOption(@PathVariable Integer id) {
        log.info("DELETE /api/hotel-price-options/{} - Xóa price option", id);
        optionService.deleteOption(id);
        return ResponseEntity.noContent().build();
    }
}