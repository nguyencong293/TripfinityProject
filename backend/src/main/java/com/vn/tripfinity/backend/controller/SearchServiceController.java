package com.vn.tripfinity.backend.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import com.vn.tripfinity.backend.service.SearchService;

import java.util.Map;

@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class SearchServiceController {

    private final SearchService searchService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> search(
            @RequestHeader("Authorization") String authorization,
            @RequestParam(value = "q", required = false) String q,
            @RequestParam(value = "type", required = false) String type,
            @RequestParam(value = "status", required = false) String status) {
        requireBearer(authorization);
        Map<String, Object> result = searchService.searchAll(q, type, status);
        return ResponseEntity.ok(result);
    }
}
