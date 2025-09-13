package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TourReviewReplyDTO {
    private Integer replyId;

    // Provided by path param in controller
    private Integer reviewId;

    @NotNull(message = "replierId không được để trống")
    @JsonAlias({ "replier_id" })
    private Integer replierId;

    @NotBlank
    private String content;

    @JsonAlias({ "is_public" })
    private Boolean isPublic;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
