package com.vn.tripfinity.backend.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.vn.tripfinity.backend.dto.AreaDTO;
import com.vn.tripfinity.backend.service.AreaService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/areas")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class AreaController {

    private final AreaService areaService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    @GetMapping
    public ResponseEntity<List<AreaDTO>> getAll(@RequestHeader("Authorization") String authorization) {
        requireBearer(authorization);
        return ResponseEntity.ok(areaService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AreaDTO> getById(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        return ResponseEntity.ok(areaService.getById(id));
    }

    @GetMapping("/slug/{slug}")
    public ResponseEntity<AreaDTO> getBySlug(@RequestHeader("Authorization") String authorization,
            @PathVariable String slug) {
        requireBearer(authorization);
        return ResponseEntity.ok(areaService.getBySlug(slug));
    }

    @PostMapping
    public ResponseEntity<AreaDTO> create(@RequestHeader("Authorization") String authorization,
            @Valid @RequestBody AreaDTO dto) {
        requireBearer(authorization);
        AreaDTO created = areaService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AreaDTO> update(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @Valid @RequestBody AreaDTO dto) {
        requireBearer(authorization);
        return ResponseEntity.ok(areaService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        areaService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
