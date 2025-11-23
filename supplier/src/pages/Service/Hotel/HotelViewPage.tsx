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
  Building2,
  Eye,
  EyeOff,
  Award,
  Image as ImageIcon,
  Clock,
  Hotel,
} from "lucide-react";
import { useHotelView } from "../../../hooks/useHotelView";
import { useLanguage } from "../../../hooks/useLanguage";

/* ================= Constants ================= */
// Must stay in-sync with HIGHLIGHTS_OPTIONS in HotelCreatePage/HotelEditPage
const HIGHLIGHTS_DICT: Record<number, string> = {
  1: "View biển",
  2: "View núi",
  3: "Trung tâm thành phố",
  4: "Gần sân bay",
  5: "Hồ bơi ngoài trời",
  6: "Hồ bơi trong nhà",
  7: "Spa & Massage",
  8: "Phòng gym",
  9: "Nhà hàng cao cấp",
  10: "Bar & Lounge",
  // Bổ sung dành cho resort/khách sạn
  11: "Bãi biển riêng",
  12: "Hồ bơi vô cực",
  13: "Bar hồ bơi",
  14: "Câu lạc bộ trẻ em (Kids Club)",
  15: "Dịch vụ trông trẻ",
  16: "Sân tennis",
  17: "Sân golf gần kề",
  18: "Thể thao dưới nước",
  19: "Lặn biển / Snorkeling",
  20: "Kayak / Chèo SUP",
  21: "Công viên nước mini",
  22: "Rooftop bar",
  23: "Nhà hàng buffet",
  24: "Trung tâm hội nghị / phòng họp",
  25: "Dịch vụ đưa đón sân bay",
  26: "Dịch vụ đưa đón trong khu",
  27: "Bãi đỗ xe có nhân viên (valet)",
  28: "Xông hơi / Sauna",
  29: "Bể sục / Jacuzzi",
  30: "Khu vui chơi trẻ em",
};

// Must stay in-sync with AMENITIES_OPTIONS in HotelCreatePage/HotelEditPage
const AMENITIES_DICT: Record<number, string> = {
  1: "WiFi miễn phí",
  2: "Điều hòa",
  3: "Tivi màn hình phẳng",
  4: "Minibar",
  5: "Két an toàn",
  6: "Máy sấy tóc",
  7: "Dịch vụ phòng 24/7",
  8: "Bãi đậu xe miễn phí",
  9: "Đưa đón sân bay",
  10: "Cho phép thú cưng",
  // Bổ sung tiện nghi phổ biến
  11: "Máy pha cà phê / Ấm đun",
  12: "Áo choàng tắm & Dép đi trong phòng",
  13: "Ban công / Sân hiên",
  14: "Tầm nhìn ra biển / hồ / núi",
  15: "Góc bếp (kitchenette)",
  16: "Máy giặt",
  17: "Bàn ủi / Bàn là",
  18: "Lễ tân 24/7",
  19: "Dịch vụ Concierge",
  20: "Giữ hành lý",
  21: "Thang máy",
  22: "Phòng/tiện nghi cho người khuyết tật",
  23: "Đổi tiền / ATM",
  24: "Trạm sạc xe điện",
  25: "Phòng xông hơi / Sauna",
  26: "Phòng tắm hơi ướt / Steam",
  27: "Bồn tắm nóng / Jacuzzi",
  28: "Hồ bơi trẻ em",
  29: "Sân chơi trẻ em",
  30: "Sân tennis / Thuê vợt",
  31: "Thuê xe đạp",
  32: "Dịch vụ thuê xe / taxi",
  33: "Bãi biển gần",
  34: "Phòng họp / Tiệc",
  35: "Ăn sáng miễn phí",
};

// Property type labels are localized via i18n keys

/* ================= Styles ================= */
const pageTitle =
  "font-bold theme-text-primary text-h1-mobile sm:text-h1-tablet lg:text-h1-desktop";
const sectionTitle =
  "font-semibold theme-text-primary text-h2-mobile sm:text-h2-tablet lg:text-h2-desktop";
const labelCls =
  "font-medium theme-text-secondary text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop";
const valueCls =
  "theme-text-primary text-body1-mobile sm:text-body1-tablet lg:text-body1-desktop";

/* ================= Component ================= */
const HotelViewPage: React.FC = () => {
  const { hotelId } = useParams<{ hotelId: string }>();
  const navigate = useNavigate();
  const { hotel, loading, deleting, error, handleDelete } =
    useHotelView(hotelId);
  const { t } = useLanguage();

  const formatCurrency = (value: number): string => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
      minimumFractionDigits: 0,
    }).format(value);
  };

  const formatDate = (dateStr: string | undefined): string => {
    if (!dateStr) return "—";
    return new Date(dateStr).toLocaleDateString("vi-VN");
  };

  const getStatusBadge = (status: string): JSX.Element => {
    const styles: Record<string, string> = {
      published:
        "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
      archived:
        "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
      disabled: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300",
    };
    const labels: Record<string, string> = {
      published: t("hotelPage.list.status.published"),
      archived: t("hotelPage.list.status.archived"),
      disabled: t("hotelPage.list.status.disabled"),
    };
    return (
      <span
        className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium ${
          styles[status] || styles.disabled
        }`}
      >
        {labels[status] || status}
      </span>
    );
  };

  const getVisibilityBadge = (visibility: string): JSX.Element => {
    const isPublic = visibility === "public_";
    return (
      <span
        className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium ${
          isPublic
            ? "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300"
            : "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300"
        }`}
      >
        {isPublic ? (
          <>
            <Eye className="w-3 h-3" />
            {t("hotel_view_public")}
          </>
        ) : (
          <>
            <EyeOff className="w-3 h-3" />
            {t("hotel_view_private")}
          </>
        )}
      </span>
    );
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="w-8 h-8 animate-spin icon-brand" />
      </div>
    );
  }

  if (error || !hotel) {
    return (
      <div className="max-w-5xl mx-auto px-6 py-8">
        <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-6">
          <h2 className="text-lg font-semibold text-red-700 dark:text-red-300 mb-2">
            {t("error")}
          </h2>
          <p className="text-red-600 dark:text-red-400">
            {error || t("hotel_view_not_found")}
          </p>
          <button
            onClick={() => navigate("/supplier/service/hotel")}
            className="mt-4 btn-outline px-4 py-2"
          >
            {t("hotel_back")}
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
            onClick={() => navigate("/supplier/service/hotel")}
            className="p-2 rounded-lg hover:bg-light-secondary dark:hover:bg-dark-secondary transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className={pageTitle}>{hotel.title}</h1>
            <div className="flex items-center gap-2 mt-2">
              {getStatusBadge(hotel.hotelStatus)}
              {getVisibilityBadge(hotel.visibility || "public_")}
              {hotel.isFeatured && (
                <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300">
                  <Award className="w-3 h-3" />
                  {t("hotel_view_featured")}
                </span>
              )}
            </div>
          </div>
        </div>

        <div className="flex gap-3">
          <button
            onClick={() => navigate(`/supplier/service/hotel/${hotelId}/edit`)}
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
      {hotel.thumbnailUrl && (
        <div className="rounded-xl overflow-hidden border theme-border">
          <img
            src={hotel.thumbnailUrl}
            alt={hotel.title}
            className="w-full h-96 object-cover"
          />
        </div>
      )}

      {/* Main Info Grid */}
      <div className="grid md:grid-cols-2 gap-6">
        {/* Basic Info */}
        <div className="theme-bg-card border theme-border rounded-xl p-6 flex flex-col gap-4">
          <h2 className={sectionTitle}>{t("hotel_view_basic_info")}</h2>

          <div className="space-y-3">
            <div>
              <div className={labelCls}>{t("hotel_view_property_type")}</div>
              <div className={valueCls + " flex items-center gap-2 mt-1"}>
                <Building2 className="w-4 h-4" />
                {t(`hotel_view_property_${hotel.propertyType || "hotel"}`)}
              </div>
            </div>

            {hotel.starRating && (
              <div>
                <div className={labelCls}>{t("hotel_view_star_rating")}</div>
                <div className={valueCls + " flex items-center gap-1 mt-1"}>
                  {Array.from({ length: hotel.starRating }).map((_, i) => (
                    <Star
                      key={i}
                      className="w-4 h-4 fill-yellow-400 text-yellow-400"
                    />
                  ))}
                </div>
              </div>
            )}

            <div>
              <div className={labelCls}>{t("hotel_view_price")}</div>
              <div
                className={valueCls + " flex items-center gap-2 mt-1 flex-wrap"}
              >
                <div className="flex items-center gap-2">
                  <DollarSign className="w-4 h-4" />
                  <span>{formatCurrency(hotel.price)}</span>
                </div>
                {hotel.pricePerNight !== undefined &&
                  hotel.pricePerNight !== null && (
                    <span className="theme-text-secondary text-sm">{`+ ${formatCurrency(
                      hotel.pricePerNight
                    )} / đêm`}</span>
                  )}
              </div>
            </div>

            {hotel.location && (
              <div>
                <div className={labelCls}>{t("hotel_view_location")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <MapPin className="w-4 h-4" />
                  {hotel.location}
                </div>
              </div>
            )}

            {hotel.address && (
              <div>
                <div className={labelCls}>{t("hotel_view_address")}</div>
                <div className={valueCls + " mt-1"}>{hotel.address}</div>
              </div>
            )}
          </div>
        </div>

        {/* Capacity & Time */}
        <div className="theme-bg-card border theme-border rounded-xl p-6 flex flex-col gap-4">
          <h2 className={sectionTitle}>{t("hotel_view_capacity_time")}</h2>

          <div className="space-y-3">
            {hotel.capacity && (
              <div>
                <div className={labelCls}>{t("hotel_view_capacity")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Building2 className="w-4 h-4" />
                  {hotel.capacity} người
                </div>
              </div>
            )}

            {hotel.totalRooms && (
              <div>
                <div className={labelCls}>Tổng số phòng</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Hotel className="w-4 h-4" />
                  {hotel.totalRooms} phòng
                </div>
              </div>
            )}

            {(hotel.minParticipants || hotel.maxParticipants) && (
              <div>
                <div className={labelCls}>{t("hotel_view_guests")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Users className="w-4 h-4" />
                  {hotel.minParticipants || 0} - {hotel.maxParticipants || "∞"}{" "}
                  {t("hotel_view_persons")}
                </div>
              </div>
            )}

            {(hotel.checkinTime || hotel.checkoutTime) && (
              <div>
                <div className={labelCls}>
                  {t("hotel_view_checkin_checkout")}
                </div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Clock className="w-4 h-4" />
                  {hotel.checkinTime || "—"} / {hotel.checkoutTime || "—"}
                </div>
              </div>
            )}

            {(hotel.startDate || hotel.endDate) && (
              <div>
                <div className={labelCls}>{t("hotel_view_operation_time")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Calendar className="w-4 h-4" />
                  {formatDate(hotel.startDate)} - {formatDate(hotel.endDate)}
                </div>
              </div>
            )}

            {hotel.ratingAverage !== undefined && hotel.ratingAverage > 0 && (
              <div>
                <div className={labelCls}>{t("hotel_view_avg_rating")}</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                  {hotel.ratingAverage.toFixed(1)} / 5.0
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Description */}
      {hotel.serviceDescription && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>
            {t("hotel_view_description")}
          </h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {hotel.serviceDescription}
          </p>
        </div>
      )}

      {/* Highlights */}
      {hotel.highlightsJson && hotel.highlightsJson.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>
            {t("hotel_view_highlights")}
          </h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
            {hotel.highlightsJson.map((id) => (
              <div
                key={id}
                className="flex items-center gap-2 p-3 rounded-lg theme-bg-secondary"
              >
                <div className="w-2 h-2 rounded-full bg-light-primary dark:bg-dark-primary" />
                <span className="text-sm">
                  {HIGHLIGHTS_DICT[id] || `ID: ${id}`}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Amenities */}
      {hotel.amenitiesJson && hotel.amenitiesJson.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>
            {t("hotel_view_amenities")}
          </h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
            {hotel.amenitiesJson.map((id) => (
              <div
                key={id}
                className="flex items-center gap-2 p-3 rounded-lg theme-bg-secondary"
              >
                <div className="w-2 h-2 rounded-full bg-light-primary dark:bg-dark-primary" />
                <span className="text-sm">
                  {AMENITIES_DICT[id] || `ID: ${id}`}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Badges */}
      {hotel.badges && hotel.badges.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>{t("hotel_view_badges")}</h2>
          <div className="flex flex-wrap gap-2">
            {hotel.badges.map((badge) => (
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
      {hotel.imageUrls && hotel.imageUrls.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4 flex items-center gap-2"}>
            <ImageIcon className="w-5 h-5" />
            {t("hotel_view_gallery")} ({hotel.imageUrls.length})
          </h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
            {hotel.imageUrls.map((url, index) => (
              <div
                key={index}
                className="aspect-video rounded-lg overflow-hidden border theme-border"
              >
                <img
                  src={url}
                  alt={`${hotel.title} - ${index + 1}`}
                  className="w-full h-full object-cover hover:scale-105 transition-transform"
                />
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Policies */}
      {hotel.policiesText && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>{t("hotel_view_policies")}</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {hotel.policiesText}
          </p>
        </div>
      )}

      {/* SEO Info */}
      <div className="theme-bg-card border theme-border rounded-xl p-6">
        <h2 className={sectionTitle + " mb-4"}>{t("hotel_view_seo_info")}</h2>
        <div className="space-y-3">
          {hotel.slug && (
            <div>
              <div className={labelCls}>Slug</div>
              <div className={valueCls + " mt-1 font-mono text-sm"}>
                /{hotel.slug}
              </div>
            </div>
          )}
          {hotel.seoTitle && (
            <div>
              <div className={labelCls}>{t("hotel_view_seo_title")}</div>
              <div className={valueCls + " mt-1"}>{hotel.seoTitle}</div>
            </div>
          )}
          {hotel.seoDescription && (
            <div>
              <div className={labelCls}>{t("hotel_view_seo_description")}</div>
              <div className={valueCls + " mt-1"}>{hotel.seoDescription}</div>
            </div>
          )}
        </div>
      </div>

      {/* Metadata */}
      <div className="theme-bg-card border theme-border rounded-xl p-6">
        <h2 className={sectionTitle + " mb-4"}>
          {t("hotel_view_system_info")}
        </h2>
        <div className="grid md:grid-cols-2 gap-4 text-sm">
          <div>
            <span className={labelCls}>ID:</span>{" "}
            <span className={valueCls}>{hotel.hotelId}</span>
          </div>
          <div>
            <span className={labelCls}>Provider ID:</span>{" "}
            <span className={valueCls}>{hotel.providerId}</span>
          </div>
          <div>
            <span className={labelCls}>Area ID:</span>{" "}
            <span className={valueCls}>{hotel.areaId}</span>
          </div>
          {hotel.publishedAt && (
            <div>
              <span className={labelCls}>{t("hotel_view_published_at")}:</span>{" "}
              <span className={valueCls}>{formatDate(hotel.publishedAt)}</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default HotelViewPage;
