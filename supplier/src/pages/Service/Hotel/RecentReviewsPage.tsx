import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, Star, User, ThumbsUp } from "lucide-react";
import { getProviderByUserId, getUserById } from "../../../services/providerService";
import { getHotelsByProvider, getHotelReviewsByHotel } from "../../../services/hotelService";
import { toggleReviewLike, checkIsLiked } from "../../../services/reviewService";
import type { HotelReviewDTO, UserDTO } from "../../../types";

interface ReviewWithUser extends HotelReviewDTO {
  user?: UserDTO;
  hotelName?: string;
  isLikedByCurrentUser?: boolean;
}

const RecentReviewsPage: React.FC = () => {
  const navigate = useNavigate();
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
        const hotelsData = await getHotelsByProvider(provider.providerId);

        // Fetch reviews for all hotels
        const allReviews: ReviewWithUser[] = [];
        for (const hotel of hotelsData) {
          if (!hotel.hotelId) return [];
          const hotelReviews = await getHotelReviewsByHotel(hotel.hotelId);
          
          // Fetch user info and like status for each review
          for (const review of hotelReviews) {
            try {
              const userData = await getUserById(review.userId);
              
              // Check if current user liked this review
              let isLiked = false;
              if (user.userId && review.reviewId) {
                try {
                  isLiked = await checkIsLiked(
                    user.userId,
                    "hotel",
                    review.reviewId
                  );
                } catch (err) {
                  console.error("Error checking like status:", err);
                }
              }
              
              allReviews.push({
                ...review,
                user: userData,
                hotelName: hotel.title,
                isLikedByCurrentUser: isLiked,
              });
            } catch (error) {
              console.error(`Error fetching user ${review.userId}:`, error);
              allReviews.push({
                ...review,
                hotelName: hotel.title,
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
    <div className="min-h-screen bg-gray-50 p-6">
      {/* Header */}
      <div className="mb-6">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center text-gray-600 hover:text-gray-900 mb-4"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Quay lại
        </button>
        <h1 className="text-3xl font-bold text-gray-900">Nhận xét gần đây</h1>
        <p className="text-gray-600 mt-2">
          Xem tất cả đánh giá mới nhất từ khách hàng
        </p>
      </div>

      {/* Stats bar */}
      <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() => setSelectedStar("all")}
            className={`px-4 py-2 rounded-lg font-medium transition-colors ${
              selectedStar === "all"
                ? "bg-emerald-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            Tất cả ({reviews.length})
          </button>
          {[5, 4, 3, 2, 1].map((star) => (
            <button
              key={star}
              onClick={() => setSelectedStar(star)}
              className={`px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2 ${
                selectedStar === star
                  ? "bg-emerald-600 text-white"
                  : "bg-gray-100 text-gray-700 hover:bg-gray-200"
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
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-600"></div>
        </div>
      ) : filteredReviews.length === 0 ? (
        <div className="bg-white rounded-lg shadow-sm p-12 text-center">
          <p className="text-gray-500">Không có đánh giá nào</p>
        </div>
      ) : (
        <div className="space-y-4">
          {filteredReviews.map((review) => (
            <div
              key={review.reviewId}
              className="bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow"
            >
              {/* User info */}
              <div className="flex items-start gap-4 mb-4">
                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center text-white font-semibold flex-shrink-0">
                  {review.user?.fullName?.[0]?.toUpperCase() || <User className="w-6 h-6" />}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between flex-wrap gap-2">
                    <div>
                      <h3 className="font-semibold text-gray-900">
                        {review.user?.fullName || "Khách hàng"}
                      </h3>
                      <p className="text-sm text-gray-600">{review.hotelName}</p>
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
                  <p className="text-sm text-gray-500 mt-1">
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
                <h4 className="font-semibold text-gray-900 mb-2">
                  {review.title}
                </h4>
              )}
              <p className="text-gray-700 mb-4 line-clamp-3">{review.content}</p>

              {/* Review images */}
              {review.imageUrls && review.imageUrls.length > 0 && (
                <div className="flex gap-2 mb-4 overflow-x-auto">
                  {review.imageUrls.slice(0, 4).map((url, idx) => (
                    <img
                      key={idx}
                      src={url}
                      alt={`Review ${idx + 1}`}
                      className="h-20 w-20 rounded-lg object-cover flex-shrink-0"
                    />
                  ))}
                  {review.imageUrls.length > 4 && (
                    <div className="h-20 w-20 rounded-lg bg-gray-200 flex items-center justify-center flex-shrink-0">
                      <span className="text-gray-600 font-medium">
                        +{review.imageUrls.length - 4}
                      </span>
                    </div>
                  )}
                </div>
              )}

              {/* Footer */}
              <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                <div className="flex items-center gap-4">
                  <button
                    onClick={async () => {
                      if (!currentUserId) return;
                      try {
                        const result = await toggleReviewLike({
                          userId: currentUserId,
                          reviewType: "hotel",
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
                        ? "text-emerald-600"
                        : "text-gray-400 hover:text-emerald-600"
                    }`}
                    title={review.isLikedByCurrentUser ? "Đã thích" : "Thích đánh giá"}
                  >
                    <ThumbsUp
                      className={`w-4 h-4 ${
                        review.isLikedByCurrentUser ? "fill-current" : ""
                      }`}
                    />
                  </button>
                  <span className="text-sm text-gray-600">
                    {review.replyCount || 0} phản hồi
                  </span>
                </div>
                <button
                  onClick={() => navigate(`/supplier/service/hotel/reviews/${review.reviewId}`)}
                  className="text-emerald-600 hover:text-emerald-700 font-medium text-sm"
                >
                  Xem chi tiết →
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
