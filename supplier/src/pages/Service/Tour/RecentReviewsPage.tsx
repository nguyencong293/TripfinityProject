import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, Star, User, ThumbsUp } from "lucide-react";
import { useLanguage } from "../../../hooks/useLanguage";
import { getProviderByUserId, getUserById } from "../../../services/providerService";
import { getToursByProvider, getTourReviewsByTour } from "../../../services/tourService";
import { toggleReviewLike, checkIsLiked } from "../../../services/reviewService";
import type { TourReviewDTO, UserDTO } from "../../../types";

interface ReviewWithUser extends TourReviewDTO {
  user?: UserDTO;
  tourName?: string;
  isLikedByCurrentUser?: boolean;
}

const RecentReviewsPage: React.FC = () => {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [reviews, setReviews] = useState<ReviewWithUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedStar, setSelectedStar] = useState<number | "all">("all");
  const [currentUserId, setCurrentUserId] = useState<number | null>(null);

  useEffect(() => {
    const init = async () => {
      const userStr = localStorage.getItem("user");
      if (!userStr) return;
      const user = JSON.parse(userStr);
      setCurrentUserId(user.userId);
    };
    init();
  }, []);

  useEffect(() => {
    const loadData = async () => {
      try {
        const userStr = localStorage.getItem("user");
        if (!userStr) return;
        const user = JSON.parse(userStr);

        const provider = await getProviderByUserId(user.userId);
        if (!provider?.providerId) return;
        const toursData = await getToursByProvider(provider.providerId);

        // Fetch reviews for all tours
        const allReviews: ReviewWithUser[] = [];
        for (const tour of toursData) {
          if (!tour.tourId) continue;
          const tourReviews = await getTourReviewsByTour(tour.tourId);
          
          // Fetch user info and like status for each review
          for (const review of tourReviews) {
            try {
              const userData = await getUserById(review.userId);
              
              // Check if current user liked this review
              let isLiked = false;
              if (user.userId && review.reviewId) {
                try {
                  isLiked = await checkIsLiked(
                    user.userId,
                    "tour",
                    review.reviewId
                  );
                } catch (err) {
                  console.error("Error checking like status:", err);
                }
              }
              
              allReviews.push({
                ...review,
                user: userData,
                tourName: tour.title,
                isLikedByCurrentUser: isLiked,
              });
            } catch (error) {
              console.error(`Error fetching user ${review.userId}:`, error);
              allReviews.push({
                ...review,
                tourName: tour.title,
                isLikedByCurrentUser: false,
              });
            }
          }
        }

        // Sort by newest first
        allReviews.sort((a, b) => {
          const dateA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
          const dateB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
          return dateB - dateA;
        });

        setReviews(allReviews);
      } catch (error) {
        console.error("Error loading reviews:", error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, []);

  const filteredReviews = reviews.filter((review) =>
    selectedStar === "all" ? true : review.rating === selectedStar
  );

  // Count reviews by star
  const starCounts = {
    5: reviews.filter((r) => r.rating === 5).length,
    4: reviews.filter((r) => r.rating === 4).length,
    3: reviews.filter((r) => r.rating === 3).length,
    2: reviews.filter((r) => r.rating === 2).length,
    1: reviews.filter((r) => r.rating === 1).length,
  };

  return (
    <div className="min-h-screen theme-bg-primary p-6">
      {/* Header */}
      <div className="mb-6">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center theme-text-secondary hover:theme-text-primary mb-4"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          {t("back")}
        </button>
        <h1 className="text-3xl font-bold theme-text-primary">{t("tour_review_recent_title")}</h1>
        <p className="theme-text-secondary mt-2">
          {t("tour_review_recent_subtitle")}
        </p>
      </div>

      {/* Stats bar */}
      <div className="theme-bg-card rounded-lg shadow-sm p-4 mb-6">
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() => setSelectedStar("all")}
            className={`px-4 py-2 rounded-lg font-medium transition-colors ${
              selectedStar === "all"
                ? "theme-bg-brand theme-text-brand-contrast"
                : "theme-bg-secondary theme-text-secondary theme-hover"
            }`}
          >
            {t("tour_review_filter_all")} ({reviews.length})
          </button>
          {[5, 4, 3, 2, 1].map((star) => (
            <button
              key={star}
              onClick={() => setSelectedStar(star)}
              className={`px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2 ${
                selectedStar === star
                  ? "theme-bg-brand theme-text-brand-contrast"
                  : "theme-bg-secondary theme-text-secondary theme-hover"
              }`}
            >
              <Star className="w-4 h-4 fill-current text-yellow-400" />
              {star} ({starCounts[star as keyof typeof starCounts]})
            </button>
          ))}
        </div>
      </div>

      {/* Reviews list */}
      {loading ? (
        <div className="flex justify-center items-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-brand-primary"></div>
        </div>
      ) : filteredReviews.length === 0 ? (
        <div className="theme-bg-card rounded-lg shadow-sm p-12 text-center">
          <p className="theme-text-secondary">{t("tour_review_no_reviews")}</p>
        </div>
      ) : (
        <div className="space-y-4">
          {filteredReviews.map((review) => (
            <div
              key={review.reviewId}
              className="theme-bg-card rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow"
            >
              {/* User info */}
              <div className="flex items-start gap-4 mb-4">
                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center text-white font-semibold flex-shrink-0">
                  {review.user?.fullName?.[0]?.toUpperCase() || <User className="w-6 h-6" />}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between flex-wrap gap-2">
                    <div>
                      <h3 className="font-semibold theme-text-primary">
                        {review.user?.fullName || t("tour_review_customer")}
                      </h3>
                      <p className="text-sm theme-text-secondary">{review.tourName}</p>
                    </div>
                    <div className="flex items-center gap-1">
                      {Array.from({ length: 5 }).map((_, i) => (
                        <Star
                          key={i}
                          className={`w-5 h-5 ${
                            i < (review.rating || 0)
                              ? "fill-yellow-400 text-yellow-400"
                              : "text-gray-300"
                          }`}
                        />
                      ))}
                    </div>
                  </div>
                  <p className="text-sm theme-text-secondary mt-1">
                    {review.createdAt
                      ? new Date(review.createdAt).toLocaleDateString("vi-VN", {
                          year: "numeric",
                          month: "long",
                          day: "numeric",
                        })
                      : ""}
                  </p>
                </div>
              </div>

              {/* Review content */}
              {review.title && (
                <h4 className="font-semibold theme-text-primary mb-2">
                  {review.title}
                </h4>
              )}
              <p className="theme-text-primary mb-4 line-clamp-3">{review.content}</p>

              {/* Review images */}
              {review.imageUrls && review.imageUrls.length > 0 && (
                <div className="flex gap-2 mb-4 overflow-x-auto">
                  {review.imageUrls.slice(0, 4).map((url, idx) => (
                    <img
                      key={idx}
                      src={url}
                      alt={`${t("tour_review_image")} ${idx + 1}`}
                      className="h-20 w-20 rounded-lg object-cover flex-shrink-0"
                    />
                  ))}
                  {review.imageUrls.length > 4 && (
                    <div className="h-20 w-20 rounded-lg theme-bg-secondary flex items-center justify-center flex-shrink-0">
                      <span className="theme-text-secondary font-medium">
                        +{review.imageUrls.length - 4}
                      </span>
                    </div>
                  )}
                </div>
              )}

              {/* Footer */}
              <div className="flex items-center justify-between pt-4 border-t theme-border">
                <div className="flex items-center gap-4">
                  <button
                    onClick={async () => {
                      if (!currentUserId) return;
                      try {
                        const result = await toggleReviewLike({
                          userId: currentUserId,
                          reviewType: "tour",
                          reviewId: review.reviewId!,
                        });
                        // Update review like status in list
                        setReviews((prev) =>
                          prev.map((r) =>
                            r.reviewId === review.reviewId
                              ? { ...r, isLikedByCurrentUser: result.isLiked }
                              : r
                          )
                        );
                      } catch (error) {
                        console.error("Error toggling like:", error);
                      }
                    }}
                    className={`flex items-center gap-1 text-sm transition-colors ${
                      review.isLikedByCurrentUser
                        ? "theme-text-brand"
                        : "theme-text-secondary hover:theme-text-brand"
                    }`}
                    title={review.isLikedByCurrentUser ? t("tour_review_liked") : t("tour_review_like")}
                  >
                    <ThumbsUp
                      className={`w-4 h-4 ${
                        review.isLikedByCurrentUser ? "fill-current" : ""
                      }`}
                    />
                  </button>
                  <span className="text-sm theme-text-secondary">
                    {review.replyCount || 0} {t("tour_review_replies")}
                  </span>
                </div>
                <button
                  onClick={() => navigate(`/supplier/service/tour/reviews/${review.reviewId}`)}
                  className="theme-text-brand hover:opacity-80 font-medium text-sm"
                >
                  {t("view_detail")} →
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default RecentReviewsPage;
