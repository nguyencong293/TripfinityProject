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
  Map,
  Eye,
  EyeOff,
  Award,
  Image as ImageIcon,
  Clock,
} from "lucide-react";
import { useAttractionView } from "../../../hooks/useAttractionView";

/* ================= Constants ================= */
// Attraction features dictionary (must stay in-sync with backend/create/edit pages)
const FEATURES_DICT: Record<number, string> = {
  1: "Có hướng dẫn viên",
  2: "Tự tham quan",
  3: "Hướng dẫn âm thanh",
  4: "WiFi miễn phí",
  5: "Bãi đỗ xe",
  6: "Nhà vệ sinh công cộng",
  7: "Khu ăn uống",
  8: "Cửa hàng quà tặng",
  9: "Thang máy/Thang cuốn",
  10: "Tiện nghi cho người khuyết tật",
  11: "Khu vui chơi trẻ em",
  12: "Khu nghỉ ngơi có mái che",
  13: "Dịch vụ cho thuê thiết bị",
  14: "Trạm sơ cứu",
  15: "An ninh 24/7",
};

// Highlights dictionary
const HIGHLIGHTS_DICT: Record<number, string> = {
  1: "Phong cảnh tuyệt đẹp",
  2: "Kiến trúc độc đáo",
  3: "Di sản văn hóa",
  4: "Hoạt động ngoài trời",
  5: "Phù hợp gia đình",
  6: "Thú vị cho trẻ em",
  7: "Lý tưởng cho cặp đôi",
  8: "Phù hợp nhóm đông",
  9: "Trải nghiệm văn hóa",
  10: "Chụp ảnh đẹp",
};

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
const AttractionViewPage: React.FC = () => {
  const { attractionId } = useParams<{ attractionId: string }>();
  const navigate = useNavigate();
  const { attraction, loading, deleting, error, handleDelete } =
    useAttractionView(attractionId);

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
      published: "Đã xuất bản",
      archived: "Đã lưu trữ",
      disabled: "Vô hiệu hóa",
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
            Công khai
          </>
        ) : (
          <>
            <EyeOff className="w-3 h-3" />
            Riêng tư
          </>
        )}
      </span>
    );
  };

  const getAttractionTypeLabel = (type: string | undefined): string => {
    const labels: Record<string, string> = {
      museum: "Bảo tàng",
      park: "Công viên",
      temple: "Chùa/Đền",
      landmark: "Địa danh",
      theme_park: "Công viên giải trí",
      cultural_site: "Di tích văn hóa",
      natural_attraction: "Danh lam thiên nhiên",
      entertainment: "Giải trí",
      historical_site: "Di tích lịch sử",
      other: "Khác",
    };
    return labels[type || ""] || type || "—";
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="w-8 h-8 animate-spin icon-brand" />
      </div>
    );
  }

  if (error || !attraction) {
    return (
      <div className="max-w-5xl mx-auto px-6 py-8">
        <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-6">
          <h2 className="text-lg font-semibold text-red-700 dark:text-red-300 mb-2">
            Lỗi
          </h2>
          <p className="text-red-600 dark:text-red-400">
            {error || "Không tìm thấy điểm tham quan"}
          </p>
          <button
            onClick={() => navigate("/supplier/service/attraction")}
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
            onClick={() => navigate("/supplier/service/attraction")}
            className="p-2 rounded-lg hover:bg-light-secondary dark:hover:bg-dark-secondary transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className={pageTitle}>{attraction.title}</h1>
            <div className="flex items-center gap-2 mt-2">
              {getStatusBadge(attraction.attractionStatus)}
              {getVisibilityBadge(attraction.visibility || "public_")}
              {attraction.isFeatured && (
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
            onClick={() =>
              navigate(`/supplier/service/attraction/${attractionId}/edit`)
            }
            className="btn-primary px-4 py-2 flex items-center gap-2"
          >
            <Edit className="w-4 h-4" />
            Chỉnh sửa
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
            Xóa
          </button>
        </div>
      </div>

      {/* Thumbnail */}
      {attraction.thumbnailUrl && (
        <div className="rounded-xl overflow-hidden border theme-border">
          <img
            src={attraction.thumbnailUrl}
            alt={attraction.title}
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
              <div className={labelCls}>Loại hình</div>
              <div className={valueCls + " flex items-center gap-2 mt-1"}>
                <Map className="w-4 h-4" />
                {getAttractionTypeLabel(attraction.attractionType)}
              </div>
            </div>

            <div>
              <div className={labelCls}>Giá vé</div>
              <div
                className={valueCls + " flex items-center gap-2 mt-1"}
              >
                <DollarSign className="w-4 h-4" />
                <span>{formatCurrency(attraction.price)}</span>
              </div>
            </div>

            {attraction.location && (
              <div>
                <div className={labelCls}>Khu vực</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <MapPin className="w-4 h-4" />
                  {attraction.location}
                </div>
              </div>
            )}

            {attraction.address && (
              <div>
                <div className={labelCls}>Địa chỉ</div>
                <div className={valueCls + " mt-1"}>{attraction.address}</div>
              </div>
            )}

            {attraction.averageVisitMinutes && (
              <div>
                <div className={labelCls}>Thời gian tham quan trung bình</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Clock className="w-4 h-4" />
                  {attraction.averageVisitMinutes} phút
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Capacity & Time */}
        <div className="theme-bg-card border theme-border rounded-xl p-6 flex flex-col gap-4">
          <h2 className={sectionTitle}>Sức chứa & Thời gian</h2>

          <div className="space-y-3">
            {attraction.capacity && (
              <div>
                <div className={labelCls}>Sức chứa</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Users className="w-4 h-4" />
                  {attraction.capacity} người
                </div>
              </div>
            )}

            {(attraction.minParticipants || attraction.maxParticipants) && (
              <div>
                <div className={labelCls}>Số lượng khách</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Users className="w-4 h-4" />
                  {attraction.minParticipants || 0} -{" "}
                  {attraction.maxParticipants || "∞"} người
                </div>
              </div>
            )}

            {(attraction.startDate || attraction.endDate) && (
              <div>
                <div className={labelCls}>Thời gian hoạt động</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Calendar className="w-4 h-4" />
                  {formatDate(attraction.startDate)} -{" "}
                  {formatDate(attraction.endDate)}
                </div>
              </div>
            )}

            {attraction.ratingAverage !== undefined &&
              attraction.ratingAverage > 0 && (
                <div>
                  <div className={labelCls}>Đánh giá trung bình</div>
                  <div className={valueCls + " flex items-center gap-2 mt-1"}>
                    <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                    {attraction.ratingAverage.toFixed(1)} / 5.0
                  </div>
                </div>
              )}
          </div>
        </div>
      </div>

      {/* Description */}
      {attraction.serviceDescription && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Mô tả</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {attraction.serviceDescription}
          </p>
        </div>
      )}

      {/* Opening Hours */}
      {attraction.openingHoursJson &&
        Object.keys(attraction.openingHoursJson).length > 0 && (
          <div className="theme-bg-card border theme-border rounded-xl p-6">
            <h2 className={sectionTitle + " mb-4"}>Giờ mở cửa</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {Object.entries(attraction.openingHoursJson).map(
                ([day, hours]) => {
                  const dayLabels: Record<string, string> = {
                    monday: "Thứ 2",
                    tuesday: "Thứ 3",
                    wednesday: "Thứ 4",
                    thursday: "Thứ 5",
                    friday: "Thứ 6",
                    saturday: "Thứ 7",
                    sunday: "Chủ nhật",
                  };
                  return (
                    <div
                      key={day}
                      className="flex justify-between p-3 rounded-lg theme-bg-secondary"
                    >
                      <span className="font-medium">
                        {dayLabels[day] || day}:
                      </span>
                      <span>{hours || "Đóng cửa"}</span>
                    </div>
                  );
                }
              )}
            </div>
          </div>
        )}

      {/* Visit Types */}
      {attraction.visitTypesJson && attraction.visitTypesJson.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Loại hình tham quan</h2>
          <div className="flex flex-wrap gap-2">
            {attraction.visitTypesJson.map((type) => {
              const typeLabels: Record<string, string> = {
                guided_tour: "Tour có hướng dẫn viên",
                self_guided: "Tự tham quan",
                audio_guide: "Hướng dẫn âm thanh",
                virtual_tour: "Tour ảo",
              };
              return (
                <span
                  key={type}
                  className="px-3 py-1 rounded-full bg-light-secondary dark:bg-dark-secondary border theme-border text-sm"
                >
                  {typeLabels[type] || type}
                </span>
              );
            })}
          </div>
        </div>
      )}

      {/* Available Times */}
      {attraction.availableTimesJson &&
        attraction.availableTimesJson.length > 0 && (
          <div className="theme-bg-card border theme-border rounded-xl p-6">
            <h2 className={sectionTitle + " mb-4"}>Thời gian có thể tham quan</h2>
            <div className="flex flex-wrap gap-2">
              {attraction.availableTimesJson.map((time) => {
                const timeLabels: Record<string, string> = {
                  morning: "Buổi sáng",
                  afternoon: "Buổi chiều",
                  evening: "Buổi tối",
                  night: "Ban đêm",
                };
                return (
                  <span
                    key={time}
                    className="px-3 py-1 rounded-full bg-light-secondary dark:bg-dark-secondary border theme-border text-sm"
                  >
                    {timeLabels[time] || time}
                  </span>
                );
              })}
            </div>
          </div>
        )}

      {/* Suitable For */}
      {attraction.suitableForJson && attraction.suitableForJson.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Phù hợp cho</h2>
          <div className="flex flex-wrap gap-2">
            {attraction.suitableForJson.map((audience) => {
              const audienceLabels: Record<string, string> = {
                family: "Gia đình",
                kids: "Trẻ em",
                elderly: "Người cao tuổi",
                couples: "Cặp đôi",
                groups: "Nhóm đông",
                solo: "Du khách đơn lẻ",
                pets: "Thú cưng",
              };
              return (
                <span
                  key={audience}
                  className="px-3 py-1 rounded-full bg-light-secondary dark:bg-dark-secondary border theme-border text-sm"
                >
                  {audienceLabels[audience] || audience}
                </span>
              );
            })}
          </div>
        </div>
      )}

      {/* Highlights */}
      {attraction.highlightsJson && attraction.highlightsJson.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Điểm nổi bật</h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
            {attraction.highlightsJson.map((id) => (
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

      {/* Features */}
      {attraction.featuresJson && attraction.featuresJson.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Tiện nghi</h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
            {attraction.featuresJson.map((id) => (
              <div
                key={id}
                className="flex items-center gap-2 p-3 rounded-lg theme-bg-secondary"
              >
                <div className="w-2 h-2 rounded-full bg-light-primary dark:bg-dark-primary" />
                <span className="text-sm">
                  {FEATURES_DICT[id] || `ID: ${id}`}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Badges */}
      {attraction.badges && attraction.badges.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Huy hiệu</h2>
          <div className="flex flex-wrap gap-2">
            {attraction.badges.map((badge) => (
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
      {attraction.imageUrls && attraction.imageUrls.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4 flex items-center gap-2"}>
            <ImageIcon className="w-5 h-5" />
            Thư viện ảnh ({attraction.imageUrls.length})
          </h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
            {attraction.imageUrls.map((url, index) => (
              <div
                key={index}
                className="aspect-video rounded-lg overflow-hidden border theme-border"
              >
                <img
                  src={url}
                  alt={`${attraction.title} - ${index + 1}`}
                  className="w-full h-full object-cover hover:scale-105 transition-transform"
                />
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tips */}
      {attraction.tipsText && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Lời khuyên cho du khách</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {attraction.tipsText}
          </p>
        </div>
      )}

      {/* Policies */}
      {attraction.policiesText && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Chính sách</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {attraction.policiesText}
          </p>
        </div>
      )}

      {/* SEO Info */}
      <div className="theme-bg-card border theme-border rounded-xl p-6">
        <h2 className={sectionTitle + " mb-4"}>Thông tin SEO</h2>
        <div className="space-y-3">
          {attraction.slug && (
            <div>
              <div className={labelCls}>Slug</div>
              <div className={valueCls + " mt-1 font-mono text-sm"}>
                /{attraction.slug}
              </div>
            </div>
          )}
          {attraction.seoTitle && (
            <div>
              <div className={labelCls}>Tiêu đề SEO</div>
              <div className={valueCls + " mt-1"}>{attraction.seoTitle}</div>
            </div>
          )}
          {attraction.seoDescription && (
            <div>
              <div className={labelCls}>Mô tả SEO</div>
              <div className={valueCls + " mt-1"}>
                {attraction.seoDescription}
              </div>
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
            <span className={valueCls}>{attraction.attractionId}</span>
          </div>
          <div>
            <span className={labelCls}>Provider ID:</span>{" "}
            <span className={valueCls}>{attraction.providerId}</span>
          </div>
          <div>
            <span className={labelCls}>Area ID:</span>{" "}
            <span className={valueCls}>{attraction.areaId}</span>
          </div>
          {attraction.publishedAt && (
            <div>
              <span className={labelCls}>Ngày xuất bản:</span>{" "}
              <span className={valueCls}>
                {formatDate(attraction.publishedAt)}
              </span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default AttractionViewPage;
