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
      published:
        "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300",
      archived:
        "bg-gray-100 text-gray-700 dark:bg-gray-900/30 dark:text-gray-300",
      draft: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300",
    };
    const labels = {
      published: "Đã xuất bản",
      archived: "Lưu trữ",
      draft: "Nháp",
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
      <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300">
        <Eye className="w-3 h-3" />
        Công khai
      </span>
    ) : (
      <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium bg-gray-100 text-gray-700 dark:bg-gray-900/30 dark:text-gray-300">
        <EyeOff className="w-3 h-3" />
        Riêng tư
      </span>
    );
  };

  const formatDate = (dateString?: string) => {
    if (!dateString) return "N/A";
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
          <p className="theme-text-secondary">Đang tải thông tin tour...</p>
        </div>
      </div>
    );
  }

  if (error || !tour) {
    return (
      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="theme-bg-card border theme-border rounded-xl p-8 text-center">
          <p className="text-red-500 mb-4">{error || "Không tìm thấy tour"}</p>
          <button
            onClick={() => navigate("/supplier/service/tour")}
            className="mt-4 btn-outline px-4 py-2"
          >
            Quay lại
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
            className="p-2 rounded-lg hover:bg-light-secondary dark:hover:bg-dark-secondary transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className={pageTitle}>{tour.title}</h1>
            <div className="flex items-center gap-2 mt-2">
              {getStatusBadge(tour.tourStatus)}
              {getVisibilityBadge(tour.visibility || "public")}
              {tour.isFeatured && (
                <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300">
                  <Award className="w-3 h-3" />
                  Nổi bật
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
          <h2 className={sectionTitle}>Thông tin cơ bản</h2>

          <div className="space-y-3">
            <div>
              <div className={labelCls}>Loại tour</div>
              <div className={valueCls + " flex items-center gap-2 mt-1"}>
                <Compass className="w-4 h-4" />
                {tour.tourType === "group"
                  ? "Tour nhóm"
                  : tour.tourType === "private"
                  ? "Tour riêng"
                  : "Tour tùy chỉnh"}
              </div>
            </div>

            {tour.difficultyLevel && (
              <div>
                <div className={labelCls}>Độ khó</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <TrendingUp className="w-4 h-4" />
                  {tour.difficultyLevel === "easy"
                    ? "Dễ"
                    : tour.difficultyLevel === "moderate"
                    ? "Trung bình"
                    : "Khó"}
                </div>
              </div>
            )}

            {tour.durationDays && (
              <div>
                <div className={labelCls}>Thời gian</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Clock className="w-4 h-4" />
                  {tour.durationDays} ngày
                </div>
              </div>
            )}

            <div>
              <div className={labelCls}>Giá tour</div>
              <div className={valueCls + " flex items-center gap-2 mt-1"}>
                <DollarSign className="w-4 h-4" />
                <span className="text-lg font-bold text-emerald-600 dark:text-emerald-400">
                  {tour.price?.toLocaleString("vi-VN")} {tour.currencyCode}
                </span>
              </div>
            </div>

            {typeof tour.ratingAverage === 'number' && tour.ratingAverage > 0 && (
              <div>
                <div className={labelCls}>Đánh giá trung bình</div>
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
          <h2 className={sectionTitle}>Địa điểm & Lịch trình</h2>

          <div className="space-y-3">
            {tour.location && (
              <div>
                <div className={labelCls}>Địa điểm</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <MapPin className="w-4 h-4" />
                  {tour.location}
                </div>
              </div>
            )}

            {tour.address && (
              <div>
                <div className={labelCls}>Địa chỉ</div>
                <div className={valueCls + " mt-1"}>{tour.address}</div>
              </div>
            )}

            {tour.departureLocation && (
              <div>
                <div className={labelCls}>Điểm khởi hành</div>
                <div className={valueCls + " mt-1"}>{tour.departureLocation}</div>
              </div>
            )}

            {tour.meetingPoint && (
              <div>
                <div className={labelCls}>Điểm tập trung</div>
                <div className={valueCls + " mt-1"}>{tour.meetingPoint}</div>
              </div>
            )}

            {tour.startDate && (
              <div>
                <div className={labelCls}>Ngày bắt đầu</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Calendar className="w-4 h-4" />
                  {formatDate(tour.startDate)}
                </div>
              </div>
            )}

            {tour.endDate && (
              <div>
                <div className={labelCls}>Ngày kết thúc</div>
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
          <h2 className={sectionTitle}>Sức chứa</h2>

          <div className="space-y-3">
            {tour.capacity && (
              <div>
                <div className={labelCls}>Sức chứa tối đa</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Users className="w-4 h-4" />
                  {tour.capacity} người
                </div>
              </div>
            )}

            {tour.minParticipants && (
              <div>
                <div className={labelCls}>Tối thiểu</div>
                <div className={valueCls + " mt-1"}>
                  {tour.minParticipants} người
                </div>
              </div>
            )}

            {tour.maxParticipants && (
              <div>
                <div className={labelCls}>Tối đa</div>
                <div className={valueCls + " mt-1"}>
                  {tour.maxParticipants} người
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Guide Languages */}
        {tour.guideLanguagesJson && parseJsonArray<string>(tour.guideLanguagesJson).length > 0 && (
          <div className="theme-bg-card border theme-border rounded-xl p-6 flex flex-col gap-4">
            <h2 className={sectionTitle}>Ngôn ngữ hướng dẫn</h2>
            <div className="flex flex-wrap gap-2">
              {parseJsonArray<string>(tour.guideLanguagesJson).map((lang) => (
                <span
                  key={lang}
                  className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-light-secondary dark:bg-dark-secondary border theme-border text-sm font-medium"
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
          <h2 className={sectionTitle + " mb-4"}>Mô tả tour</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {tour.serviceDescription}
          </p>
        </div>
      )}

      {/* Itinerary Overview */}
      {tour.itineraryOverview && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Tổng quan lịch trình</h2>
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
            <h2 className={sectionTitle + " mb-4"}>Chi tiết lịch trình</h2>
            <div className="space-y-4">
              {details.map((item, idx) => (
                <div key={idx} className="border-l-4 border-light-primary dark:border-dark-primary pl-4">
                  <h3 className="font-semibold theme-text-primary mb-2">
                    Ngày {item.day}: {item.title}
                  </h3>
                  <ul className="space-y-1">
                    {item.activities.map((activity, aIdx) => (
                      <li key={aIdx} className="text-sm theme-text-secondary flex items-start gap-2">
                        <span className="w-1.5 h-1.5 rounded-full bg-light-primary dark:bg-dark-primary mt-1.5" />
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
            <h2 className={sectionTitle + " mb-4"}>Bao gồm</h2>
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
            <h2 className={sectionTitle + " mb-4"}>Không bao gồm</h2>
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
          <h2 className={sectionTitle + " mb-4"}>Danh mục</h2>
          <div className="flex flex-wrap gap-2">
            {parseJsonArray<string>(tour.categoriesJson).map((cat) => (
              <span
                key={cat}
                className="px-3 py-1 rounded-full bg-light-secondary dark:bg-dark-secondary border theme-border text-sm font-medium"
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
          <h2 className={sectionTitle + " mb-4"}>Dịch vụ</h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
            {parseJsonArray<string>(tour.servicesJson).map((service) => (
              <div
                key={service}
                className="flex items-center gap-2 p-3 rounded-lg theme-bg-secondary"
              >
                <div className="w-2 h-2 rounded-full bg-light-primary dark:bg-dark-primary" />
                <span className="text-sm">{SERVICES_DICT[service] || service}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Badges */}
      {tour.badges && parseJsonArray<string>(tour.badges).length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Huy hiệu</h2>
          <div className="flex flex-wrap gap-2">
            {parseJsonArray<string>(tour.badges).map((badge) => (
              <span
                key={badge}
                className="px-3 py-1 rounded-full bg-light-secondary dark:bg-dark-secondary border theme-border text-sm font-medium"
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
            Thư viện ảnh ({parseJsonArray<string>(tour.imageUrls).length})
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
          <h2 className={sectionTitle + " mb-4"}>Chính sách hủy tour</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {tour.cancellationPolicy}
          </p>
        </div>
      )}

      {/* Policies */}
      {tour.policiesText && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Chính sách khác</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {tour.policiesText}
          </p>
        </div>
      )}

      {/* SEO Info */}
      <div className="theme-bg-card border theme-border rounded-xl p-6">
        <h2 className={sectionTitle + " mb-4"}>Thông tin SEO</h2>
        <div className="space-y-3">
          {tour.slug && (
            <div>
              <div className={labelCls}>Slug</div>
              <div className={valueCls + " mt-1 font-mono text-sm"}>
                /{tour.slug}
              </div>
            </div>
          )}
          {tour.seoTitle && (
            <div>
              <div className={labelCls}>SEO Title</div>
              <div className={valueCls + " mt-1"}>{tour.seoTitle}</div>
            </div>
          )}
          {tour.seoDescription && (
            <div>
              <div className={labelCls}>SEO Description</div>
              <div className={valueCls + " mt-1"}>{tour.seoDescription}</div>
            </div>
          )}
        </div>
      </div>

      {/* Metadata */}
      <div className="theme-bg-card border theme-border rounded-xl p-6">
        <h2 className={sectionTitle + " mb-4"}>Thông tin hệ thống</h2>
        <div className="grid md:grid-cols-2 gap-4 text-sm">
          <div>
            <span className={labelCls}>ID:</span>{" "}
            <span className={valueCls}>{tour.tourId}</span>
          </div>
          <div>
            <span className={labelCls}>Provider ID:</span>{" "}
            <span className={valueCls}>{tour.providerId}</span>
          </div>
          <div>
            <span className={labelCls}>Area ID:</span>{" "}
            <span className={valueCls}>{tour.areaId}</span>
          </div>
          {tour.publishedAt && (
            <div>
              <span className={labelCls}>Ngày xuất bản:</span>{" "}
              <span className={valueCls}>{formatDate(tour.publishedAt)}</span>
            </div>
          )}
          {tour.createdAt && (
            <div>
              <span className={labelCls}>Ngày tạo:</span>{" "}
              <span className={valueCls}>{formatDate(tour.createdAt)}</span>
            </div>
          )}
          {tour.updatedAt && (
            <div>
              <span className={labelCls}>Cập nhật lần cuối:</span>{" "}
              <span className={valueCls}>{formatDate(tour.updatedAt)}</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default TourViewPage;
