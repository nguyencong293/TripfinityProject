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
  Utensils,
  Eye,
  EyeOff,
  Award,
  Image as ImageIcon,
  Phone,
  Globe,
} from "lucide-react";
import { useRestaurantView } from "../../../hooks/useRestaurantView";

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
const RestaurantViewPage: React.FC = () => {
  const { restaurantId } = useParams<{ restaurantId: string }>();
  const navigate = useNavigate();
  const { restaurant, loading, deleting, error, handleDelete } =
    useRestaurantView(restaurantId);

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

  const getPriceLevelLabel = (level: string | undefined): string => {
    const labels: Record<string, string> = {
      cheap: "Rẻ ($)",
      moderate: "Trung bình ($$)",
      expensive: "Cao ($$$)",
      luxury: "Sang trọng ($$$$)",
    };
    return labels[level || ""] || level || "—";
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="w-8 h-8 animate-spin icon-brand" />
      </div>
    );
  }

  if (error || !restaurant) {
    return (
      <div className="max-w-5xl mx-auto px-6 py-8">
        <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-6">
          <h2 className="text-lg font-semibold text-red-700 dark:text-red-300 mb-2">
            Lỗi
          </h2>
          <p className="text-red-600 dark:text-red-400">
            {error || "Không tìm thấy nhà hàng"}
          </p>
          <button
            onClick={() => navigate("/supplier/service/restaurant")}
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
            onClick={() => navigate("/supplier/service/restaurant")}
            className="p-2 rounded-lg hover:bg-light-secondary dark:hover:bg-dark-secondary transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className={pageTitle}>{restaurant.title}</h1>
            <div className="flex items-center gap-2 mt-2">
              {getStatusBadge(restaurant.restaurantStatus)}
              {getVisibilityBadge(restaurant.visibility || "public_")}
              {restaurant.isFeatured && (
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
              navigate(`/supplier/service/restaurant/${restaurantId}/edit`)
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
      {restaurant.thumbnailUrl && (
        <div className="rounded-xl overflow-hidden border theme-border">
          <img
            src={restaurant.thumbnailUrl}
            alt={restaurant.title}
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
              <div className={labelCls}>Mức giá</div>
              <div className={valueCls + " flex items-center gap-2 mt-1"}>
                <DollarSign className="w-4 h-4" />
                {getPriceLevelLabel(restaurant.priceLevel)}
              </div>
            </div>

            <div>
              <div className={labelCls}>Giá trung bình/người</div>
              <div className={valueCls + " flex items-center gap-2 mt-1"}>
                <DollarSign className="w-4 h-4" />
                <span>{formatCurrency(restaurant.price)}</span>
              </div>
            </div>

            {restaurant.location && (
              <div>
                <div className={labelCls}>Khu vực</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <MapPin className="w-4 h-4" />
                  {restaurant.location}
                </div>
              </div>
            )}

            {restaurant.address && (
              <div>
                <div className={labelCls}>Địa chỉ</div>
                <div className={valueCls + " mt-1"}>{restaurant.address}</div>
              </div>
            )}

            {restaurant.phone && (
              <div>
                <div className={labelCls}>Số điện thoại</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Phone className="w-4 h-4" />
                  {restaurant.phone}
                </div>
              </div>
            )}

            {restaurant.website && (
              <div>
                <div className={labelCls}>Website</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Globe className="w-4 h-4" />
                  <a
                    href={restaurant.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-600 hover:underline"
                  >
                    {restaurant.website}
                  </a>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Capacity & Time */}
        <div className="theme-bg-card border theme-border rounded-xl p-6 flex flex-col gap-4">
          <h2 className={sectionTitle}>Sức chứa & Thời gian</h2>

          <div className="space-y-3">
            {restaurant.capacity && (
              <div>
                <div className={labelCls}>Số chỗ ngồi</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Utensils className="w-4 h-4" />
                  {restaurant.capacity} chỗ
                </div>
              </div>
            )}

            {(restaurant.minParticipants || restaurant.maxParticipants) && (
              <div>
                <div className={labelCls}>Đặt bàn theo nhóm</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Users className="w-4 h-4" />
                  {restaurant.minParticipants || 0} -{" "}
                  {restaurant.maxParticipants || "∞"} người
                </div>
              </div>
            )}

            {(restaurant.startDate || restaurant.endDate) && (
              <div>
                <div className={labelCls}>Thời gian hoạt động</div>
                <div className={valueCls + " flex items-center gap-2 mt-1"}>
                  <Calendar className="w-4 h-4" />
                  {formatDate(restaurant.startDate)} -{" "}
                  {formatDate(restaurant.endDate)}
                </div>
              </div>
            )}

            {restaurant.ratingAverage !== undefined &&
              typeof restaurant.ratingAverage === 'number' && restaurant.ratingAverage > 0 && (
                <div>
                  <div className={labelCls}>Đánh giá trung bình</div>
                  <div className={valueCls + " flex items-center gap-2 mt-1"}>
                    <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                    {restaurant.ratingAverage.toFixed(1)} / 5.0
                    {restaurant.totalReviews && (
                      <span className="text-sm theme-text-secondary">
                        ({restaurant.totalReviews} đánh giá)
                      </span>
                    )}
                  </div>
                </div>
              )}
          </div>
        </div>
      </div>

      {/* Description */}
      {restaurant.serviceDescription && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Mô tả</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {restaurant.serviceDescription}
          </p>
        </div>
      )}

      {/* Opening Hours */}
      {restaurant.openingHoursJson &&
        Object.keys(restaurant.openingHoursJson).length > 0 && (
          <div className="theme-bg-card border theme-border rounded-xl p-6">
            <h2 className={sectionTitle + " mb-4"}>Giờ mở cửa</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {Object.entries(restaurant.openingHoursJson).map(
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

      {/* Cuisines */}
      {restaurant.cuisinesJson && restaurant.cuisinesJson.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Ẩm thực</h2>
          <div className="flex flex-wrap gap-2">
            {restaurant.cuisinesJson.map((cuisine) => {
              const cuisineLabels: Record<string, string> = {
                vietnamese: "Việt Nam",
                chinese: "Trung Hoa",
                japanese: "Nhật Bản",
                korean: "Hàn Quốc",
                thai: "Thái Lan",
                italian: "Ý",
                french: "Pháp",
                american: "Mỹ",
                indian: "Ấn Độ",
                seafood: "Hải sản",
                bbq: "BBQ",
                hotpot: "Lẩu",
                fusion: "Fusion",
              };
              return (
                <span
                  key={cuisine}
                  className="px-3 py-1 rounded-full bg-light-secondary dark:bg-dark-secondary border theme-border text-sm"
                >
                  {cuisineLabels[cuisine] || cuisine}
                </span>
              );
            })}
          </div>
        </div>
      )}

      {/* Services */}
      {restaurant.servicesJson && restaurant.servicesJson.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Dịch vụ</h2>
          <div className="flex flex-wrap gap-2">
            {restaurant.servicesJson.map((service) => {
              const serviceLabels: Record<string, string> = {
                dine_in: "Dùng bữa tại chỗ",
                takeaway: "Mang đi",
                delivery: "Giao hàng",
                reservation: "Đặt bàn trước",
                private_room: "Phòng riêng",
                catering: "Tiệc buffet",
                outdoor_seating: "Chỗ ngồi ngoài trời",
              };
              return (
                <span
                  key={service}
                  className="px-3 py-1 rounded-full bg-light-secondary dark:bg-dark-secondary border theme-border text-sm"
                >
                  {serviceLabels[service] || service}
                </span>
              );
            })}
          </div>
        </div>
      )}

      {/* Diets */}
      {restaurant.dietsJson && restaurant.dietsJson.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Lựa chọn ăn kiêng</h2>
          <div className="flex flex-wrap gap-2">
            {restaurant.dietsJson.map((diet) => {
              const dietLabels: Record<string, string> = {
                vegetarian: "Chay",
                vegan: "Thuần chay",
                halal: "Halal",
                gluten_free: "Không gluten",
                dairy_free: "Không sữa",
                keto: "Keto",
                low_carb: "Ít carb",
              };
              return (
                <span
                  key={diet}
                  className="px-3 py-1 rounded-full bg-light-secondary dark:bg-dark-secondary border theme-border text-sm"
                >
                  {dietLabels[diet] || diet}
                </span>
              );
            })}
          </div>
        </div>
      )}

      {/* Menu Highlights */}
      {restaurant.menuHighlightsJson &&
        restaurant.menuHighlightsJson.length > 0 && (
          <div className="theme-bg-card border theme-border rounded-xl p-6">
            <h2 className={sectionTitle + " mb-4"}>Món ăn đặc trưng</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {restaurant.menuHighlightsJson.map((dish, index) => (
                <div
                  key={index}
                  className="flex items-center gap-2 p-3 rounded-lg theme-bg-secondary"
                >
                  <div className="w-2 h-2 rounded-full bg-light-primary dark:bg-dark-primary" />
                  <span className="text-sm">{dish}</span>
                </div>
              ))}
            </div>
          </div>
        )}

      {/* Ambiance Tags */}
      {restaurant.ambianceTagsJson &&
        restaurant.ambianceTagsJson.length > 0 && (
          <div className="theme-bg-card border theme-border rounded-xl p-6">
            <h2 className={sectionTitle + " mb-4"}>Không gian</h2>
            <div className="flex flex-wrap gap-2">
              {restaurant.ambianceTagsJson.map((tag) => {
                const ambianceLabels: Record<string, string> = {
                  romantic: "Lãng mạn",
                  family_friendly: "Phù hợp gia đình",
                  casual: "Thoải mái",
                  formal: "Trang trọng",
                  cozy: "Ấm cúng",
                  modern: "Hiện đại",
                  traditional: "Truyền thống",
                  rooftop: "Trên sân thượng",
                  garden: "Vườn",
                  beachfront: "Ven biển",
                  view: "View đẹp",
                };
                return (
                  <span
                    key={tag}
                    className="px-3 py-1 rounded-full bg-light-secondary dark:bg-dark-secondary border theme-border text-sm"
                  >
                    {ambianceLabels[tag] || tag}
                  </span>
                );
              })}
            </div>
          </div>
        )}

      {/* Payment Methods */}
      {restaurant.paymentMethodsJson &&
        restaurant.paymentMethodsJson.length > 0 && (
          <div className="theme-bg-card border theme-border rounded-xl p-6">
            <h2 className={sectionTitle + " mb-4"}>Phương thức thanh toán</h2>
            <div className="flex flex-wrap gap-2">
              {restaurant.paymentMethodsJson.map((method) => {
                const paymentLabels: Record<string, string> = {
                  cash: "Tiền mặt",
                  credit_card: "Thẻ tín dụng",
                  debit_card: "Thẻ ghi nợ",
                  momo: "MoMo",
                  zalopay: "ZaloPay",
                  vnpay: "VNPay",
                  banking: "Chuyển khoản",
                };
                return (
                  <span
                    key={method}
                    className="px-3 py-1 rounded-full bg-light-secondary dark:bg-dark-secondary border theme-border text-sm"
                  >
                    {paymentLabels[method] || method}
                  </span>
                );
              })}
            </div>
          </div>
        )}

      {/* Badges */}
      {restaurant.badges && restaurant.badges.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Huy hiệu</h2>
          <div className="flex flex-wrap gap-2">
            {restaurant.badges.map((badge) => (
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
      {restaurant.imageUrls && restaurant.imageUrls.length > 0 && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4 flex items-center gap-2"}>
            <ImageIcon className="w-5 h-5" />
            Thư viện ảnh ({restaurant.imageUrls.length})
          </h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
            {restaurant.imageUrls.map((url, index) => (
              <div
                key={index}
                className="aspect-video rounded-lg overflow-hidden border theme-border"
              >
                <img
                  src={url}
                  alt={`${restaurant.title} - ${index + 1}`}
                  className="w-full h-full object-cover hover:scale-105 transition-transform"
                />
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Policies */}
      {restaurant.policiesText && (
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <h2 className={sectionTitle + " mb-4"}>Chính sách</h2>
          <p className={valueCls + " whitespace-pre-wrap"}>
            {restaurant.policiesText}
          </p>
        </div>
      )}

      {/* SEO Info */}
      <div className="theme-bg-card border theme-border rounded-xl p-6">
        <h2 className={sectionTitle + " mb-4"}>Thông tin SEO</h2>
        <div className="space-y-3">
          {restaurant.slug && (
            <div>
              <div className={labelCls}>Slug</div>
              <div className={valueCls + " mt-1 font-mono text-sm"}>
                /{restaurant.slug}
              </div>
            </div>
          )}
          {restaurant.seoTitle && (
            <div>
              <div className={labelCls}>Tiêu đề SEO</div>
              <div className={valueCls + " mt-1"}>{restaurant.seoTitle}</div>
            </div>
          )}
          {restaurant.seoDescription && (
            <div>
              <div className={labelCls}>Mô tả SEO</div>
              <div className={valueCls + " mt-1"}>
                {restaurant.seoDescription}
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
            <span className={valueCls}>{restaurant.restaurantId}</span>
          </div>
          <div>
            <span className={labelCls}>Provider ID:</span>{" "}
            <span className={valueCls}>{restaurant.providerId}</span>
          </div>
          <div>
            <span className={labelCls}>Area ID:</span>{" "}
            <span className={valueCls}>{restaurant.areaId}</span>
          </div>
          {restaurant.publishedAt && (
            <div>
              <span className={labelCls}>Ngày xuất bản:</span>{" "}
              <span className={valueCls}>
                {formatDate(restaurant.publishedAt)}
              </span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default RestaurantViewPage;
