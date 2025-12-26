import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, Star, Filter, Search } from "lucide-react";
import { useLanguage } from "../../../hooks/useLanguage";
import { getProviderByUserId } from "../../../services/providerService";
import { getToursByProvider, getTourRatingSummaryByTour } from "../../../services/tourService";
import type { TourDTO, TourRatingSummaryDTO } from "../../../types";

interface TourWithRating extends TourDTO {
  ratingSummary?: TourRatingSummaryDTO;
}

const AllReviewsPage: React.FC = () => {
  const navigate = useNavigate();
  const { t } = useLanguage();
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
      <div className="min-h-screen theme-bg-primary flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-brand-primary"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen theme-bg-primary">
      {/* Header */}
      <div className="theme-bg-card border-b theme-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="py-6">
            <button
              onClick={() => navigate(-1)}
              className="flex items-center theme-text-secondary hover:theme-text-primary mb-4"
            >
              <ArrowLeft className="w-5 h-5 mr-2" />
              {t("back")}
            </button>
            <div>
              <h1 className="text-3xl font-bold theme-text-primary">
                {t("tour_review_manage_title")}
              </h1>
              <p className="mt-2 text-sm theme-text-secondary">
                {t("tour_review_manage_subtitle")}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Search and Filter Bar */}
        <div className="theme-bg-card rounded-lg shadow-sm p-4 mb-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 theme-text-secondary w-5 h-5" />
              <input
                type="text"
                placeholder={t("tour_review_search_placeholder")}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-brand-primary focus:border-transparent theme-bg-primary theme-text-primary"
              />
            </div>
            <div className="flex items-center gap-2">
              <Filter className="w-5 h-5 theme-text-secondary" />
              <select
                value={sortBy}
                onChange={(e) =>
                  setSortBy(e.target.value as "rating" | "reviews")
                }
                className="px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-brand-primary focus:border-transparent theme-bg-primary theme-text-primary"
              >
                <option value="rating">{t("tour_review_sort_rating")}</option>
                <option value="reviews">{t("tour_review_sort_count")}</option>
              </select>
            </div>
          </div>
        </div>

        {/* Tours Table */}
        {filteredTours.length === 0 ? (
          <div className="theme-bg-card rounded-lg shadow-sm p-12 text-center">
            <div className="theme-text-secondary mb-4">
              <Star className="w-16 h-16 mx-auto" />
            </div>
            <h3 className="text-lg font-medium theme-text-primary mb-2">
              {t("tour_review_no_tours")}
            </h3>
            <p className="theme-text-secondary">
              {searchQuery
                ? t("tour_review_no_search_result")
                : t("tour_review_no_tours_yet")}
            </p>
          </div>
        ) : (
          <div className="theme-bg-card rounded-lg shadow-sm overflow-hidden">
            <table className="min-w-full divide-y theme-divide">
              <thead className="theme-bg-secondary">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium theme-text-secondary uppercase tracking-wider">
                    {t("tour_col_name")}
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium theme-text-secondary uppercase tracking-wider">
                    {t("tour_col_location")}
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium theme-text-secondary uppercase tracking-wider">
                    {t("tour_col_rating")}
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium theme-text-secondary uppercase tracking-wider">
                    {t("tour_review_count")}
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium theme-text-secondary uppercase tracking-wider">
                    {t("status")}
                  </th>
                </tr>
              </thead>
              <tbody className="theme-bg-card divide-y theme-divide">
                {filteredTours.map((tour) => (
                  <tr
                    key={tour.tourId}
                    onClick={() =>
                      navigate(`/supplier/services/tour/reviews/${tour.tourId}`)
                    }
                    className="theme-hover cursor-pointer transition-colors"
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
                          <div className="text-sm font-medium theme-text-primary">
                            {tour.title}
                          </div>
                          <div className="text-sm theme-text-secondary">
                            {tour.tourType === 'group' ? t("tour_type_group") :
                             tour.tourType === 'private' ? t("tour_type_private") :
                             tour.tourType === 'custom' ? t("tour_type_custom") :
                             tour.tourType}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm theme-text-primary">
                        {tour.location}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <Star className="w-5 h-5 text-yellow-400 fill-current mr-1" />
                        <span className="text-sm font-medium theme-text-primary">
                          {tour.ratingSummary?.avgRating?.toFixed(1) || t("tour_na")}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="text-sm theme-text-primary">
                        {tour.ratingSummary?.totalReviews || 0}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span
                        className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          tour.ratingSummary &&
                          tour.ratingSummary.totalReviews > 0
                            ? "theme-bg-success theme-text-success"
                            : "theme-bg-secondary theme-text-secondary"
                        }`}
                      >
                        {tour.ratingSummary &&
                        tour.ratingSummary.totalReviews > 0
                          ? t("tour_review_has_reviews")
                          : t("tour_review_no_reviews")}
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
