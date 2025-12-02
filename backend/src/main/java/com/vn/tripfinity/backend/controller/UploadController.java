package com.vn.tripfinity.backend.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.vn.tripfinity.backend.service.cloudinary.CloudinaryService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/upload")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class UploadController {

    private final CloudinaryService cloudinaryService;

    /**
     * Upload single image to Cloudinary
     */
    @PostMapping("/image")
    public ResponseEntity<Map<String, String>> uploadSingleImage(
            @RequestHeader("Authorization") String authorization,
            @RequestParam("file") MultipartFile file) {
        log.info("POST /api/upload/image - Uploading single image");
        try {
            Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
            String imageUrl = (String) uploadResult.get("secure_url");
            
            Map<String, String> response = new HashMap<>();
            response.put("url", imageUrl);
            
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            log.error("Error uploading image: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Upload multiple images to Cloudinary
     */
    @PostMapping("/images")
    public ResponseEntity<Map<String, List<String>>> uploadMultipleImages(
            @RequestHeader("Authorization") String authorization,
            @RequestParam("files") List<MultipartFile> files) {
        log.info("POST /api/upload/images - Uploading {} images", files.size());
        try {
            List<String> imageUrls = new ArrayList<>();
            
            for (MultipartFile file : files) {
                Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
                String imageUrl = (String) uploadResult.get("secure_url");
                imageUrls.add(imageUrl);
            }
            
            Map<String, List<String>> response = new HashMap<>();
            response.put("urls", imageUrls);
            
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            log.error("Error uploading images: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Delete image from Cloudinary
     */
    @DeleteMapping("/image")
    public ResponseEntity<Void> deleteSingleImage(
            @RequestHeader("Authorization") String authorization,
            @RequestParam("imageUrl") String imageUrl) {
        log.info("DELETE /api/upload/image - Deleting image: {}", imageUrl);
        try {
            cloudinaryService.deleteImage(imageUrl);
            return ResponseEntity.noContent().build();
        } catch (IOException e) {
            log.error("Error deleting image: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Delete multiple images from Cloudinary
     */
    @DeleteMapping("/images")
    public ResponseEntity<Void> deleteMultipleImages(
            @RequestHeader("Authorization") String authorization,
            @RequestBody Map<String, List<String>> request) {
        List<String> imageUrls = request.get("imageUrls");
        log.info("DELETE /api/upload/images - Deleting {} images", imageUrls.size());
        try {
            for (String imageUrl : imageUrls) {
                cloudinaryService.deleteImage(imageUrl);
            }
            return ResponseEntity.noContent().build();
        } catch (IOException e) {
            log.error("Error deleting images: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
