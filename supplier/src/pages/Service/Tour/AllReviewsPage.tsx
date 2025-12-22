import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, Star, Filter, Search } from "lucide-react";
import { getProviderByUserId } from "../../../services/providerService";
import { getToursByProvider, getTourRatingSummaryByTour } from "../../../services/tourService";
import type { TourDTO, TourRatingSummaryDTO } from "../../../types";

interface TourWithRating extends TourDTO {
  ratingSummary?: TourRatingSummaryDTO;
}

const AllReviewsPage: React.FC = () => {
  const navigate = useNavigate();
  const [tours, setTours] = useState<TourWithRating[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortBy, setSortBy] = useState<"rating" | "reviews">("rating");

  useEffect(() => {
    const loadData = async () => {
      try {
        const userStr = localStorage.getItem("user");
        if (!userStr) {
          navigate("/login");
          return;
        }

        const user = JSON.parse(userStr);
        const provider = await getProviderByUserId(user.userId);
        if (!provider?.providerId) return;
        const toursData = await getToursByProvider(provider.providerId);

        // Fetch rating summary for each tour
        const toursWithRatings = await Promise.all(
          toursData.map(async (tour) => {
            try {
              if (!tour.tourId) return null;
              const summary = await getTourRatingSummaryByTour(tour.tourId);
              return { ...tour, ratingSummary: summary };
            } catch {
              return { ...tour, ratingSummary: undefined };
            }
          })
        );

        setTours(toursWithRatings.filter((t): t is TourWithRating => t !== null));
      } catch (error) {
        console.error("Error loading tours:", error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [navigate]);

  const filteredTours = tours
    .filter((tour) =>
      tour.title.toLowerCase().includes(searchQuery.toLowerCase())
    )
    .sort((a, b) => {
      if (sortBy === "rating") {
        const ratingA = a.ratingSummary?.avgRating || 0;
        const ratingB = b.ratingSummary?.avgRating || 0;
        return ratingB - ratingA;
      } else {
        const reviewsA = a.ratingSummary?.totalReviews || 0;
        const reviewsB = b.ratingSummary?.totalReviews || 0;
        return reviewsB - reviewsA;
      }
    });

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-orange-600"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="py-6">
            <button
              onClick={() => navigate(-1)}
              className="flex items-center text-gray-600 hover:text-gray-900 mb-4"
            >
              <ArrowLeft className="w-5 h-5 mr-2" />
              Quay lại
            </button>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">
                Quản lý đánh giá tour
              </h1>
              <p className="mt-2 text-sm text-gray-600">
                Xem và quản lý tất cả đánh giá từ khách hàng
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Search and Filter Bar */}
        <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Tìm kiếm tour..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>
            <div className="flex items-center gap-2">
              <Filter className="w-5 h-5 text-gray-400" />
              <select
                value={sortBy}
                onChange={(e) =>
                  setSortBy(e.target.value as "rating" | "reviews")
                }
                className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              >
                <option value="rating">Đánh giá cao nhất</option>
                <option value="reviews">Nhiều đánh giá nhất</option>
              </select>
            </div>
          </div>
        </div>

        {/* Tours Table */}
        {filteredTours.length === 0 ? (
          <div className="bg-white rounded-lg shadow-sm p-12 text-center">
            <div className="text-gray-400 mb-4">
              <Star className="w-16 h-16 mx-auto" />
            </div>
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              Chưa có tour nào
            </h3>
            <p className="text-gray-500">
              {searchQuery
                ? "Không tìm thấy tour phù hợp với từ khóa tìm kiếm"
                : "Hiện tại chưa có tour nào trong hệ thống"}
            </p>
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow-sm overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Tour
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Địa điểm
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Đánh giá
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Số đánh giá
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Trạng thái
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredTours.map((tour) => (
                  <tr
                    key={tour.tourId}
                    onClick={() =>
                      navigate(`/supplier/services/tour/reviews/${tour.tourId}`)
                    }
                    className="hover:bg-gray-50 cursor-pointer transition-colors"
                  >
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <img
                          src={
                            tour.thumbnailUrl ||
                            "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800"
                          }
                          alt={tour.title}
                          className="h-12 w-12 rounded-lg object-cover"
                        />
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {tour.title}
                          </div>
                          <div className="text-sm text-gray-500">
                            {tour.tourType}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">
                        {tour.location}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <Star className="w-5 h-5 text-yellow-400 fill-current mr-1" />
                        <span className="text-sm font-medium text-gray-900">
                          {tour.ratingSummary?.avgRating?.toFixed(1) || "N/A"}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="text-sm text-gray-900">
                        {tour.ratingSummary?.totalReviews || 0}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span
                        className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          tour.ratingSummary &&
                          tour.ratingSummary.totalReviews > 0
                            ? "bg-green-100 text-green-800"
                            : "bg-gray-100 text-gray-800"
                        }`}
                      >
                        {tour.ratingSummary &&
                        tour.ratingSummary.totalReviews > 0
                          ? "Có đánh giá"
                          : "Chưa có đánh giá"}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

export default AllReviewsPage;
