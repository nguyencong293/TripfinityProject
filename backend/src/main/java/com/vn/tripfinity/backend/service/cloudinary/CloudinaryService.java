package com.vn.tripfinity.backend.service.cloudinary;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class CloudinaryService {
    private final Cloudinary cloudinary;
    private static final Logger logger = LoggerFactory.getLogger(CloudinaryService.class);
    private static final String UPLOAD_FOLDER = "assets"; // Thư mục mặc định

    public CloudinaryService(Cloudinary cloudinary) {
        this.cloudinary = cloudinary;
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> uploadImage(MultipartFile file) throws IOException {
        try {
            if (file == null || file.isEmpty()) {
                logger.error("File is null or empty");
                throw new IllegalArgumentException("File cannot be null or empty");
            }

            Map<String, Object> options = new HashMap<>();
            options.put("folder", UPLOAD_FOLDER); // Upload vào folder "assets"
            options.put("resource_type", "auto");
            options.put("public_id", UUID.randomUUID().toString());

            logger.info("Starting upload to Cloudinary folder: {}", UPLOAD_FOLDER);
            Map<String, Object> uploadResult = cloudinary.uploader().upload(file.getBytes(), options);
            logger.info("Upload successful. URL: {}", uploadResult.get("secure_url"));

            return uploadResult;
        } catch (IOException e) {
            logger.error("Error uploading file to Cloudinary", e);
            throw e;
        }
    }

    public void deleteImage(String publicId) throws IOException {
        try {
            if (publicId != null && !publicId.isEmpty()) {
                logger.info("Deleting image with public ID: {}", publicId);
                Map<String, String> options = new HashMap<>();
                options.put("resource_type", "image");
                cloudinary.uploader().destroy(publicId, options);
                logger.info("Successfully deleted image from Cloudinary");
            }
        } catch (IOException e) {
            logger.error("Error deleting image from Cloudinary", e);
            throw e;
        }
    }

    // Hàm xóa ảnh dựa trên URL
    @SuppressWarnings("unchecked")
    public void deleteImageByUrl(String imageUrl) throws IOException {
        if (imageUrl == null || imageUrl.isEmpty()) {
            throw new IllegalArgumentException("Image URL is empty");
        }
        String[] parts = imageUrl.split("/upload/");
        if (parts.length < 2) {
            throw new IllegalArgumentException("Invalid Cloudinary URL: " + imageUrl);
        }
        String rest = parts[1];
        // Loại bỏ phần version (ví dụ "v1739022636/") bằng cách lấy phần sau dấu "/"
        int slashIndex = rest.indexOf("/");
        if (slashIndex < 0) {
            throw new IllegalArgumentException("Invalid Cloudinary URL, missing version part: " + imageUrl);
        }
        String publicIdWithExtension = rest.substring(slashIndex + 1);
        // Loại bỏ phần đuôi mở rộng, lấy public id (bao gồm cả folder "assets")
        int dotIndex = publicIdWithExtension.lastIndexOf(".");
        String publicId = (dotIndex > 0)
                ? publicIdWithExtension.substring(0, dotIndex)
                : publicIdWithExtension;

        logger.info("Deleting image with public ID: {}", publicId);

        // Gọi API xóa ảnh từ Cloudinary sử dụng public id đã trích xuất
        try {
            Map<String, Object> result = cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
            logger.info("Delete result: {}", result);
        } catch (Exception e) {
            throw new IOException("Failed to delete image with publicId: " + publicId, e);
        }
    }
}