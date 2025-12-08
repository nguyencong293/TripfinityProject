import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, Star, Filter, Search } from "lucide-react";
import { getProviderByUserId } from "../../../services/providerService";
import { getRestaurantsByProvider, getRestaurantRatingSummaryByRestaurant } from "../../../services/restaurantService";
import type { RestaurantDTO, RestaurantRatingSummaryDTO } from "../../../types";

interface RestaurantWithRating extends RestaurantDTO {
  ratingSummary?: RestaurantRatingSummaryDTO;
}

const AllReviewsPage: React.FC = () => {
  const navigate = useNavigate();
  const [restaurants, setRestaurants] = useState<RestaurantWithRating[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortBy, setSortBy] = useState<"rating" | "reviews">("rating");

  useEffect(() => {
    const loadData = async () => {
      try {
        const userStr = localStorage.getItem("user");
        if (!userStr) return;
        const user = JSON.parse(userStr);

        const provider = await getProviderByUserId(user.userId);
        if (!provider?.providerId) return;
        const restaurantsData = await getRestaurantsByProvider(provider.providerId);

        // Fetch rating summary for each restaurant
        const restaurantsWithRatings = await Promise.all(
          restaurantsData.map(async (restaurant) => {
            try {
              if (!restaurant.restaurantId) return null;
              const summary = await getRestaurantRatingSummaryByRestaurant(restaurant.restaurantId);
              return { ...restaurant, ratingSummary: summary };
            } catch {
              return { ...restaurant, ratingSummary: undefined };
            }
          })
        );

        setRestaurants(restaurantsWithRatings.filter((r): r is RestaurantWithRating => r !== null));
      } catch (error) {
        console.error("Error loading restaurants:", error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, []);

  const filteredRestaurants = restaurants
    .filter((restaurant) =>
      restaurant.title.toLowerCase().includes(searchQuery.toLowerCase())
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
        <h1 className="text-3xl font-bold text-gray-900">
          Tất cả đánh giá khách sạn
        </h1>
        <p className="text-gray-600 mt-2">
          Xem tổng quan đánh giá của các khách sạn
        </p>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
        <div className="flex flex-col md:flex-row gap-4">
          {/* Search */}
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              placeholder="Tìm kiếm khách sạn..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
            />
          </div>

          {/* Sort */}
          <div className="flex items-center gap-2">
            <Filter className="w-5 h-5 text-gray-400" />
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as "rating" | "reviews")}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
            >
              <option value="rating">Sắp xếp theo điểm</option>
              <option value="reviews">Sắp xếp theo số lượng</option>
            </select>
          </div>
        </div>
      </div>

      {/* Table */}
      {loading ? (
        <div className="flex justify-center items-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-600"></div>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow-sm overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Khách sạn
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Vị trí
                </th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Điểm trung bình
                </th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Số đánh giá
                </th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Trạng thái
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredRestaurants.map((restaurant) => {
                const rating = restaurant.ratingSummary?.avgRating || 0;
                const totalReviews = restaurant.ratingSummary?.totalReviews || 0;
                const statusColor =
                  rating >= 4.5
                    ? "text-green-600 bg-green-100"
                    : rating >= 4.0
                    ? "text-emerald-600 bg-emerald-100"
                    : rating >= 3.0
                    ? "text-yellow-600 bg-yellow-100"
                    : "text-red-600 bg-red-100";

                return (
                  <tr
                    key={restaurant.restaurantId}
                    className="hover:bg-gray-50"
                  >
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 h-10 w-10">
                          <img
                            className="h-10 w-10 rounded-lg object-cover"
                            src={restaurant.thumbnailUrl || "/placeholder.jpg"}
                            alt={restaurant.title}
                          />
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {restaurant.title}
                          </div>
                          <div className="text-sm text-gray-500">
                            {restaurant.cuisinesJson?.[0] || "Nhà hàng"}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900">{restaurant.location}</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <div className="flex items-center justify-center">
                        <Star className="w-5 h-5 text-yellow-400 fill-current mr-1" />
                        <span className="text-lg font-semibold text-gray-900">
                          {rating.toFixed(1)}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-sm font-medium text-gray-900">
                        {totalReviews} đánh giá
                      </span>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span
                        className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${statusColor}`}
                      >
                        {rating >= 4.5
                          ? "Xuất sắc"
                          : rating >= 4.0
                          ? "Tốt"
                          : rating >= 3.0
                          ? "Trung bình"
                          : "Cần cải thiện"}
                      </span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>

          {filteredRestaurants.length === 0 && (
            <div className="text-center py-12">
              <p className="text-gray-500">Không tìm thấy nhà hàng nào</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default AllReviewsPage;
