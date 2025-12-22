package com.vn.tripfinity.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BlogDTO {

    private Integer blogId;

    private Integer bloggerId;

    @NotBlank(message = "Title không được để trống")
    @Size(max = 255, message = "Title tối đa 255 ký tự")
    private String title;

    @Size(max = 255, message = "Slug tối đa 255 ký tự")
    private String slug;

    @NotBlank(message = "Content không được để trống")
    private String content;

    @Size(max = 512, message = "Cover image URL tối đa 512 ký tự")
    private String coverImageUrl;

    @Size(max = 255, message = "Tags tối đa 255 ký tự")
    private String tags;

    private Integer viewsCount;

    private Integer likesCount;

    private String blogStatus; // "published" hoặc "archived"

    private LocalDateTime publishedAt;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    // Thông tin blogger để hiển thị
    private String bloggerName;
    private String bloggerAvatar;
}
