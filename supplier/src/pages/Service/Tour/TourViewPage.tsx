import React, { type JSX } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  Edit,
  Trash2,
  Loader2,
  MapPin,
  Calendar,
  Users,
  Star,
  DollarSign,
  Eye,
  EyeOff,
  Award,
  Image as ImageIcon,
  Clock,
  Compass,
  TrendingUp,
  Globe,
} from "lucide-react";

import { useLanguage } from "../../../hooks/useLanguage";
import { useTourView } from "../../../hooks/useTourView";

/* ================= Constants ================= */
// Categories labels
const CATEGORIES_DICT: Record<string, string> = {
  culture: "Văn hóa",
  nature: "Thiên nhiên",
  adventure: "Phiêu lưu",
  food: "Ẩm thực",
  beach: "Biển",
  mountain: "Núi",
  city: "Thành phố",
  historical: "Lịch sử",
};

// Services labels
const SERVICES_DICT: Record<string, string> = {
  pickup: "Đón tại khách sạn",
  airport_transfer: "Đưa đón sân bay",
  photography: "Chụp ảnh chuyên nghiệp",
  bike_rental: "Thuê xe đạp",
  special_meals: "Bữa ăn đặc biệt",
};

// Guide languages
const LANGUAGES_DICT: Record<string, string> = {
  vietnamese: "Tiếng Việt",
  english: "Tiếng Anh",
  chinese: "Tiếng Trung",
  japanese: "Tiếng Nhật",
  korean: "Tiếng Hàn",
  french: "Tiếng Pháp",
  german: "Tiếng Đức",
  spanish: "Tiếng Tây Ban Nha",
};

// Included/Excluded items
const INCLUDED_DICT: Record<string, string> = {
  hotel: "Khách sạn",
  meals: "Bữa ăn",
  transport: "Phương tiện di chuyển",
  guide: "Hướng dẫn viên",
  insurance: "Bảo hiểm",
  entrance_fees: "Vé tham quan",
};

const EXCLUDED_DICT: Record<string, string> = {
  flights: "Vé máy bay",
  visa: "Visa",
  tips: "Tiền tip",
  personal_expenses: "Chi phí cá nhân",
};

const TourViewPage: React.FC = (): JSX.Element => {
  const { tourId } = useParams<{ tourId: string }>();
  const navigate = useNavigate();
  const { t } = useLanguage();
  const { tour, loading, error, deleting, handleDelete } = useTourView(
    Number(tourId)
  );

  /* ================= Styles ================= */
  const pageTitle = "text-2xl font-bold theme-text-primary";
  const sectionTitle = "text-lg font-semibold theme-text-primary";
  const labelCls = "text-sm font-medium theme-text-secondary";
  const valueCls = "text-base theme-text-primary";

  /* ================= Status & Visibility Badges ================= */
  const getStatusBadge = (status?: string) => {
    if (!status) return null;
    const colors = {
      published: "theme-bg-success theme-text-success",
      archived: "theme-bg-secondary theme-text-secondary",
      draft: "theme-bg-error theme-text-error",
    };
    const labels = {
      published: t("tour_status_published"),
      archived: t("tour_status_archived"),
      draft: t("tour_status_draft"),
    };
    return (
      <span
        className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${
          colors[status as keyof typeof colors] || colors.draft
        }`}
      >
        {labels[status as keyof typeof labels] || status}
      </span>
    );
  };

  const getVisibilityBadge = (visibility: string) => {
    return visibility === "public" ? (
      <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium theme-bg-info theme-text-info">
        <Eye className="w-3 h-3" />
        {t("tour_visibility_public")}
      </span>
    ) : (
      <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium theme-bg-secondary theme-text-secondary">
        <EyeOff className="w-3 h-3" />
        {t("tour_visibility_private")}
      </span>
    );
  };

  const formatDate = (dateString?: string) => {
    if (!dateString) return t("tour_na");
    return new Date(dateString).toLocaleDateString("vi-VN", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  const parseJsonArray = <T,>(value: string | T[] | undefined | null): T[] => {
    if (!value) return [];
    if (Array.isArray(value)) return value;
    if (typeof value === "string") {
      try {
        const parsed = JSON.parse(value);
        return Array.isArray(parsed) ? parsed : [];
      } catch {
        return [];
      }
    }
    return [];
  };

  /* ================= Loading & Error States ================= */
  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="flex flex-col items-center gap-3">
          <Loader2 className="w-8 h-8 animate-spin theme-text-primary" />
          <p className="theme-text-secondary">{t("tour_view_loading")}</p>
        </div>
      </div>
    );
  }

  if (error || !tour) {
    return (
      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="theme-bg-card border theme-border rounded-xl p-8 text-center">
          <p className="theme-text-error mb-4">{error || t("tour_view_not_found")}</p>
          <button
            onClick={() => navigate("/supplier/service/tour")}
            className="mt-4 btn-outline px-4 py-2"
          >
            {t("back")}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-6 py-8 flex flex-col gap-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate("/supplier/service/tour")}
            className="p-2 rounded-lg theme-hover transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className={pageTitle}>{tour.title}</h1>
            <div className="flex items-center gap-2 mt-2">
              {getStatusBadge(tour.tourStatus)}
              {getVisibilityBadge(tour.visibility || "public")}
              {tour.isFeatured && (
                <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium theme-bg-warning theme-text-warning">
                  <Award className="w-3 h-3" />
                  {t("tour_featured")}
                </span>
              )}
            </div>
          </div>
        </div>

        <div className="flex gap-3">
          <button
            onClick={() => navigate(`/supplier/service/tour/${tourId}/edit`)}
            className="btn-primary px-4 py-2 flex items-center gap-2"
          >
            <Edit className="w-4 h-4" />
            {t("edit")}
          </button>
          <button
            onClick={handleDelete}
            disabled={deleting}
            className="btn-outline border-red-500 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 px-4 py-2 flex items-center gap-2 disabled:opacity-50"
          >
            {deleting ? (
              <Loader2 className="w-4 h-4 animate-spin" />
            ) : (
              <Trash2 className="w-4 h-4" />
            )}
            {t("delete")}
          </button>
        </div>
      </div>

      {/* Thumbnail */}
      {tour.thumbnailUrl && (
        <div className="rounded-xl overflow-hidden border theme-border">
          <img
            src={tour.thumbnailUrl}
            alt={tour.title}
            className="w-full h-96 object-cover"
          />
        </div>
      )}

      {/* Main Info Grid */}
      <div className="grid md:grid-cols-2 gap-6">
        {/* Basic Info */}
        <div className="theme-bg-card border theme-border rounded-xl p-6 flex flex-col gap-4">
          <h2 className={sectionTitle}>{t("tour_view_basic_info")}</h2>

          <div className="space-y-3">
            <div>
              <div className={labelCls}>{t("tour_col_type")}</div>
              <div className={valueCls + " flex items-center gap-2 mt-1"}>
                <Compass className="w-4 h-4" />
                {tour.tourType === "group"
                  ? t("tour_type_group")
                  : tour.tourType === "private"
                  ? t("tour_type_private")
                  : t("tour_type_custom")}
              </div>
            </div>

            {tour.difficultyLevel && (
              <div>
                <div className={labelCls}>{t("tour_difficulty")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <TrendingUp className="w-4 h-4" />
                  {tour.difficultyLevel === "easy"
                    ? t("tour_difficulty_easy")
                    : tour.difficultyLevel === "moderate"
                    ? t("tour_difficulty_moderate")
                    : t("tour_difficulty_hard")}
                </div>
              </div>
            )}

            {tour.durationDays && (
              <div>
                <div className={labelCls}>{t("tour_duration")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Clock className="w-4 h-4" />
                  {tour.durationDays} {t("tour_days")}
                </div>
              </div>
            )}

            <div>
              <div className={labelCls}>{t("tour_col_price")}</div>
              <div className={valueCls + " flex items-center gap-2 mt-1"}>
                <DollarSign className="w-4 h-4" />
                <span className="text-lg font-bold theme-text-success">
                  {tour.price?.toLocaleString("vi-VN")} {tour.currencyCode}
                </span>
              </div>
            </div>

            {typeof tour.ratingAverage === 'number' && tour.ratingAverage > 0 && (
              <div>
                <div className={labelCls}>{t("tour_col_rating")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                  {tour.ratingAverage.toFixed(1)} / 5.0
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Location & Schedule */}
        <div className="theme-bg-card border theme-border rounded-xl p-6 flex flex-col gap-4">
          <h2 className={sectionTitle}>{t("tour_view_location_schedule")}</h2>

          <div className="space-y-3">
            {tour.location && (
              <div>
                <div className={labelCls}>{t("tour_col_location")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <MapPin className="w-4 h-4" />
                  {tour.location}
                </div>
              </div>
            )}

            {tour.address && (
              <div>
                <div className={labelCls}>{t("tour_address")}</div>
                <div className={valueCls + " mt-1"}>{tour.address}</div>
              </div>
            )}

            {tour.departureLocation && (
              <div>
                <div className={labelCls}>{t("tour_departure_location")}</div>
                <div className={valueCls + " mt-1"}>{tour.departureLocation}</div>
              </div>
            )}

            {tour.meetingPoint && (
              <div>
                <div className={labelCls}>{t("tour_meeting_point")}</div>
                <div className={valueCls + " mt-1"}>{tour.meetingPoint}</div>
              </div>
            )}

            {tour.startDate && (
              <div>
                <div className={labelCls}>{t("tour_col_start_date")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Calendar className="w-4 h-4" />
                  {formatDate(tour.startDate)}
                </div>
              </div>
            )}

            {tour.endDate && (
              <div>
                <div className={labelCls}>{t("tour_col_end_date")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Calendar className="w-4 h-4" />
                  {formatDate(tour.endDate)}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Capacity Info */}
        <div className="theme-bg-card border theme-border rounded-xl p-6 flex flex-col gap-4">
          <h2 className={sectionTitle}>{t("tour_view_capacity")}</h2>

          <div className="space-y-3">
            {tour.capacity && (
              <div>
                <div className={labelCls}>{t("tour_capacity")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Users className="w-4 h-4" />
                  {tour.capacity} {t("tour_guest")}
                </div>
              </div>
            )}

            {tour.minParticipants && (
              <div>
                <div className={labelCls}>{t("tour_min_participants")}</div>
                <div className={valueCls + " mt-1"}>
                  {tour.minParticipants} {t("tour_guest")}
                </div>
              </div>
            )}

            {tour.maxParticipants && (
              <div>
                <div className={labelCls}>{t("tour_max_participants")}</div>
                <div className={valueCls + " mt-1"}>
                  {tour.maxParticipants} {t("tour_guest")}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Guide Languages */}
        {tour.guideLanguagesJson && parseJsonArray<string>(tour.guideLanguagesJson).length > 0 && (
          <div className="theme-bg-card border theme-border rounded-xl p-6 flex flex-col gap-4">
            <h2 className={sectionTitle}>{t("tour_guide_languages")}</h2>
            <div className="flex flex-wrap gap-2">
              {parseJsonArray<string>(tour.guideLanguagesJson).map((lang) => (
                <span
                  key={lang}
                  className="inline-flex items-center gap-1 px-3 py-1 rounded-full theme-bg-secondary border theme-border text-sm font-medium"
                >
                  <Globe className="w-3 h-3" />
                  {LANGUAGES_DICT[lang] || lang}
                </span>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Description */}
      {tour.serviceDescription && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>{t("tour_description")}</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {tour.serviceDescription}
          </p>
        </div>
      )}

      {/* Itinerary Overview */}
      {tour.itineraryOverview && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>{t("tour_itinerary_overview")}</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {tour.itineraryOverview}
          </p>
        </div>
      )}

      {/* Itinerary Details */}
      {tour.itineraryDetailsJson && (() => {
        const details = parseJsonArray<{ day: number; title: string; activities: string[] }>(tour.itineraryDetailsJson);
        return details.length > 0 ? (
          <div className="theme-bg-card border theme-border rounded-xl p-6">
            <h2 className={sectionTitle + " mb-4"}>{t("tour_itinerary_details")}</h2>
            <div className="space-y-4">
              {details.map((item, idx) => (
                <div key={idx} className="border-l-4 theme-border-brand pl-4">
                  <h3 className="font-semibold theme-text-primary mb-2">
                    {t("tour_day")} {item.day}: {item.title}
                  </h3>
                  <ul className="space-y-1">
                    {item.activities.map((activity, aIdx) => (
                      <li key={aIdx} className="text-sm theme-text-secondary flex items-start gap-2">
                        <span className="w-1.5 h-1.5 rounded-full theme-bg-brand mt-1.5" />
                        {activity}
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>
          </div>
        ) : null;
      })()}

      {/* Included & Excluded */}
      <div className="grid md:grid-cols-2 gap-6">
        {tour.includedJson && parseJsonArray<string>(tour.includedJson).length > 0 && (
          <div className="theme-bg-card border theme-border rounded-xl p-6">
            <h2 className={sectionTitle + " mb-4"}>{t("tour_included")}</h2>
            <div className="space-y-2">
              {parseJsonArray<string>(tour.includedJson).map((item) => (
                <div key={item} className="flex items-start gap-2">
                  <div className="w-2 h-2 rounded-full bg-emerald-500 mt-1.5" />
                  <span className="text-sm">{INCLUDED_DICT[item] || item}</span>
                </div>
              ))}
            </div>
          </div>
        )}

        {tour.excludedJson && parseJsonArray<string>(tour.excludedJson).length > 0 && (
          <div className="theme-bg-card border theme-border rounded-xl p-6">
            <h2 className={sectionTitle + " mb-4"}>{t("tour_excluded")}</h2>
            <div className="space-y-2">
              {parseJsonArray<string>(tour.excludedJson).map((item) => (
                <div key={item} className="flex items-start gap-2">
                  <div className="w-2 h-2 rounded-full bg-red-500 mt-1.5" />
                  <span className="text-sm">{EXCLUDED_DICT[item] || item}</span>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Categories */}
      {tour.categoriesJson && parseJsonArray<string>(tour.categoriesJson).length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>{t("tour_categories")}</h2>
          <div className="flex flex-wrap gap-2">
            {parseJsonArray<string>(tour.categoriesJson).map((cat) => (
              <span
                key={cat}
                className="px-3 py-1 rounded-full theme-bg-secondary border theme-border text-sm font-medium"
              >
                {CATEGORIES_DICT[cat] || cat}
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Services */}
      {tour.servicesJson && parseJsonArray<string>(tour.servicesJson).length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>{t("tour_services")}</h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
            {parseJsonArray<string>(tour.servicesJson).map((service) => (
              <div
                key={service}
                className="flex items-center gap-2 p-3 rounded-lg theme-bg-secondary"
              >
                <div className="w-2 h-2 rounded-full theme-bg-brand" />
                <span className="text-sm">{SERVICES_DICT[service] || service}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Badges */}
      {tour.badges && parseJsonArray<string>(tour.badges).length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>{t("tour_badges")}</h2>
          <div className="flex flex-wrap gap-2">
            {parseJsonArray<string>(tour.badges).map((badge) => (
              <span
                key={badge}
                className="px-3 py-1 rounded-full theme-bg-secondary border theme-border text-sm font-medium"
              >
                {badge}
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Images Gallery */}
      {tour.imageUrls && parseJsonArray<string>(tour.imageUrls).length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4 flex items-center gap-2"}>
            <ImageIcon className="w-5 h-5" />
            {t("tour_gallery")} ({parseJsonArray<string>(tour.imageUrls).length})
          </h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
            {parseJsonArray<string>(tour.imageUrls).map((url, index) => (
              <div
                key={index}
                className="aspect-video rounded-lg overflow-hidden border theme-border"
              >
                <img
                  src={url}
                  alt={`${tour.title} - ${index + 1}`}
                  className="w-full h-full object-cover hover:scale-105 transition-transform"
                />
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Cancellation Policy */}
      {tour.cancellationPolicy && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>{t("tour_cancellation_policy")}</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {tour.cancellationPolicy}
          </p>
        </div>
      )}

      {/* Policies */}
      {tour.policiesText && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>{t("tour_policies")}</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {tour.policiesText}
          </p>
        </div>
      )}

      {/* SEO Info */}
      <div className="theme-bg-card border theme-border rounded-xl p-6">
        <h2 className={sectionTitle + " mb-4"}>{t("tour_seo_info")}</h2>
        <div className="space-y-3">
          {tour.slug && (
            <div>
              <div className={labelCls}>{t("tour_slug")}</div>
              <div className={valueCls + " mt-1 font-mono text-sm"}>
                /{tour.slug}
              </div>
            </div>
          )}
          {tour.seoTitle && (
            <div>
              <div className={labelCls}>{t("tour_seo_title")}</div>
              <div className={valueCls + " mt-1"}>{tour.seoTitle}</div>
            </div>
          )}
          {tour.seoDescription && (
            <div>
              <div className={labelCls}>{t("tour_seo_description")}</div>
              <div className={valueCls + " mt-1"}>{tour.seoDescription}</div>
            </div>
          )}
        </div>
      </div>

      {/* Metadata */}
      <div className="theme-bg-card border theme-border rounded-xl p-6">
        <h2 className={sectionTitle + " mb-4"}>{t("tour_system_info")}</h2>
        <div className="grid md:grid-cols-2 gap-4 text-sm">
          <div>
            <span className={labelCls}>{t("tour_col_id")}:</span>{" "}
            <span className={valueCls}>{tour.tourId}</span>
          </div>
          <div>
            <span className={labelCls}>{t("tour_provider_id")}:</span>{" "}
            <span className={valueCls}>{tour.providerId}</span>
          </div>
          <div>
            <span className={labelCls}>{t("tour_area_id")}:</span>{" "}
            <span className={valueCls}>{tour.areaId}</span>
          </div>
          {tour.publishedAt && (
            <div>
              <span className={labelCls}>{t("tour_published_at")}:</span>{" "}
              <span className={valueCls}>{formatDate(tour.publishedAt)}</span>
            </div>
          )}
          {tour.createdAt && (
            <div>
              <span className={labelCls}>{t("tour_created_at")}:</span>{" "}
              <span className={valueCls}>{formatDate(tour.createdAt)}</span>
            </div>
          )}
          {tour.updatedAt && (
            <div>
              <span className={labelCls}>{t("tour_updated_at")}:</span>{" "}
              <span className={valueCls}>{formatDate(tour.updatedAt)}</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default TourViewPage;
