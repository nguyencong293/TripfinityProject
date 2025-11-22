package com.vn.tripfinity.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.ReviewReply;

@Repository
public interface ReviewReplyRepository extends JpaRepository<ReviewReply, Integer> {
    List<ReviewReply> findByReviewTypeAndReviewIdOrderByCreatedAtDesc(ReviewReply.ReviewType reviewType,
            Integer reviewId);

    int countByReviewTypeAndReviewId(ReviewReply.ReviewType reviewType, Integer reviewId);
}
