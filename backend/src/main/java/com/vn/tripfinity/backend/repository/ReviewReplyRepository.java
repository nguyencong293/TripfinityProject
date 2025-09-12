package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.ReviewReply;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewReplyRepository extends JpaRepository<ReviewReply, Integer> {
    List<ReviewReply> findByReviewTypeAndReviewIdOrderByCreatedAtAsc(ReviewReply.ReviewType reviewType,
            Integer reviewId);

    int countByReviewTypeAndReviewId(ReviewReply.ReviewType reviewType, Integer reviewId);
}
