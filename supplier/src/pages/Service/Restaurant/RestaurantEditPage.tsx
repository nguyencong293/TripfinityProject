import React, { useState, useMemo } from "react";
import { useNavigate, useParams } from "react-router-dom";
import {
  ChevronLeft,
  ChevronRight,
  Loader2,
  Upload,
  Trash2,
  ArrowLeft,
} from "lucide-react";
import { useRestaurantEdit } from "../../../hooks/useRestaurants";
import MapPicker, { type LocationData } from "../../../components/common/MapPicker";

/* ================= Copy all constants from RestaurantCreatePage ================= */
const PRICE_LEVELS = [
  { value: "cheap", label: "Bình dân" },
  { value: "moderate", label: "Trung bình" },
  { value: "expensive", label: "Cao cấp" },
  { value: "luxury", label: "Sang trọng" },
] as const;

const AREAS = [
  { id: 1, name: "An Giang" },
  { id: 2, name: "Bà Rịa - Vũng Tàu" },
  { id: 3, name: "Bắc Kạn" },
  { id: 4, name: "Bắc Giang" },
  { id: 5, name: "Bạc Liêu" },
  { id: 6, name: "Bắc Ninh" },
  { id: 7, name: "Bến Tre" },
  { id: 8, name: "Bình Định" },
  { id: 9, name: "Bình Dương" },
  { id: 10, name: "Bình Phước" },
  { id: 11, name: "Bình Thuận" },
  { id: 12, name: "Cà Mau" },
  { id: 13, name: "Cần Thơ" },
  { id: 14, name: "Cao Bằng" },
  { id: 15, name: "Đà Nẵng" },
  { id: 16, name: "Đắk Lắk" },
  { id: 17, name: "Đắk Nông" },
  { id: 18, name: "Điện Biên" },
  { id: 19, name: "Đồng Nai" },
  { id: 20, name: "Đồng Tháp" },
  { id: 21, name: "Gia Lai" },
  { id: 22, name: "Hà Giang" },
  { id: 23, name: "Hà Nam" },
  { id: 24, name: "Hà Nội" },
  { id: 25, name: "Hà Tĩnh" },
  { id: 26, name: "Hải Dương" },
  { id: 27, name: "Hải Phòng" },
  { id: 28, name: "Hậu Giang" },
  { id: 29, name: "Hòa Bình" },
  { id: 30, name: "Hưng Yên" },
  { id: 31, name: "Khánh Hòa" },
  { id: 32, name: "Kiên Giang" },
  { id: 33, name: "Kon Tum" },
  { id: 34, name: "Lai Châu" },
  { id: 35, name: "Lâm Đồng" },
  { id: 36, name: "Lạng Sơn" },
  { id: 37, name: "Lào Cai" },
  { id: 38, name: "Long An" },
  { id: 39, name: "Nam Định" },
  { id: 40, name: "Nghệ An" },
  { id: 41, name: "Ninh Bình" },
  { id: 42, name: "Ninh Thuận" },
  { id: 43, name: "Phú Thọ" },
  { id: 44, name: "Phú Yên" },
  { id: 45, name: "Quảng Bình" },
  { id: 46, name: "Quảng Nam" },
  { id: 47, name: "Quảng Ngãi" },
  { id: 48, name: "Quảng Ninh" },
  { id: 49, name: "Quảng Trị" },
  { id: 50, name: "Sóc Trăng" },
  { id: 51, name: "Sơn La" },
  { id: 52, name: "Tây Ninh" },
  { id: 53, name: "Thái Bình" },
  { id: 54, name: "Thái Nguyên" },
  { id: 55, name: "Thanh Hóa" },
  { id: 56, name: "Thừa Thiên Huế" },
  { id: 57, name: "Tiền Giang" },
  { id: 58, name: "TP. Hồ Chí Minh" },
  { id: 59, name: "Trà Vinh" },
  { id: 60, name: "Tuyên Quang" },
  { id: 61, name: "Vĩnh Long" },
  { id: 62, name: "Vĩnh Phúc" },
  { id: 63, name: "Yên Bái" },
];

const CUISINES = [
  { value: "vietnamese", label: "Việt Nam" },
  { value: "chinese", label: "Trung Quốc" },
  { value: "japanese", label: "Nhật Bản" },
  { value: "korean", label: "Hàn Quốc" },
  { value: "italian", label: "Ý" },
  { value: "french", label: "Pháp" },
  { value: "thai", label: "Thái Lan" },
  { value: "indian", label: "Ấn Độ" },
  { value: "american", label: "Mỹ" },
  { value: "mexican", label: "Mexico" },
  { value: "seafood", label: "Hải sản" },
  { value: "vegetarian", label: "Chay" },
  { value: "fusion", label: "Fusion" },
  { value: "bbq", label: "Nướng/BBQ" },
  { value: "hotpot", label: "Lẩu" },
];

const SERVICES = [
  { value: "dine_in", label: "Dùng tại chỗ" },
  { value: "takeaway", label: "Mang về" },
  { value: "delivery", label: "Giao hàng" },
  { value: "reservation", label: "Đặt bàn" },
  { value: "private_room", label: "Phòng riêng" },
  { value: "buffet", label: "Buffet" },
  { value: "outdoor_seating", label: "Chỗ ngồi ngoài trời" },
  { value: "live_music", label: "Nhạc sống" },
  { value: "wifi", label: "WiFi" },
  { value: "parking", label: "Bãi đỗ xe" },
];

const DIETS = [
  { value: "vegetarian", label: "Chay" },
  { value: "vegan", label: "Thuần chay" },
  { value: "halal", label: "Halal" },
  { value: "kosher", label: "Kosher" },
  { value: "gluten_free", label: "Không gluten" },
  { value: "dairy_free", label: "Không sữa" },
  { value: "nut_free", label: "Không hạt" },
  { value: "low_carb", label: "Ít carb" },
  { value: "keto", label: "Keto" },
];

const AMBIANCE_TAGS = [
  { value: "romantic", label: "Lãng mạn" },
  { value: "family_friendly", label: "Thân thiện gia đình" },
  { value: "business", label: "Kinh doanh" },
  { value: "casual", label: "Thoải mái" },
  { value: "formal", label: "Trang trọng" },
  { value: "cozy", label: "Ấm cúng" },
  { value: "modern", label: "Hiện đại" },
  { value: "traditional", label: "Truyền thống" },
  { value: "rooftop", label: "Rooftop" },
  { value: "beachfront", label: "Ven biển" },
];

const PAYMENT_METHODS = [
  { value: "cash", label: "Tiền mặt" },
  { value: "credit_card", label: "Thẻ tín dụng" },
  { value: "debit_card", label: "Thẻ ghi nợ" },
  { value: "momo", label: "MoMo" },
  { value: "zalopay", label: "ZaloPay" },
  { value: "vnpay", label: "VNPay" },
];

const BADGES_OPTIONS = [
  { value: "Bestseller", label: "Bestseller" },
  { value: "New", label: "Mới" },
  { value: "Hot Deal", label: "Hot Deal" },
  { value: "Recommended", label: "Được đề xuất" },
  { value: "Popular", label: "Phổ biến" },
  { value: "Michelin Star", label: "Michelin Star" },
  { value: "Halal Certified", label: "Chứng nhận Halal" },
  { value: "Organic", label: "Hữu cơ" },
  { value: "Farm to Table", label: "Farm to Table" },
  { value: "Eco-Friendly", label: "Thân thiện môi trường" },
];

const DAYS_OF_WEEK = [
  { key: "monday", label: "Thứ Hai" },
  { key: "tuesday", label: "Thứ Ba" },
  { key: "wednesday", label: "Thứ Tư" },
  { key: "thursday", label: "Thứ Năm" },
  { key: "friday", label: "Thứ Sáu" },
  { key: "saturday", label: "Thứ Bảy" },
  { key: "sunday", label: "Chủ Nhật" },
];

const MAX_PRICE = 1000000000;

const matchAreaFromAddress = (address: string): number | null => {
  const normalizedAddress = address.toLowerCase();
  for (const area of AREAS) {
    const areaName = area.name.toLowerCase();
    const areaNameSimple = areaName.replace(/^(thành phố|tp\.?)\s*/i, '').trim();
    if (normalizedAddress.includes(areaName) || normalizedAddress.includes(areaNameSimple)) {
      return area.id;
    }
  }
  return null;
};

// Helper function to generate slug from title
const generateSlugFromTitle = (title: string): string => {
  if (!title || !title.trim()) return '';
  
  const slugBase = title
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/\u0111/g, 'd')
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
  
  const randomDigits = Math.floor(100000000 + Math.random() * 900000000);
  return `${slugBase}-${randomDigits}`;
};

/* ================= Styles ================= */
const baseInput =
  "border theme-border rounded px-3 py-2 bg-white dark:bg-dark-card theme-text-primary focus-ring-primary text-body2-mobile sm:text-body2-tablet lg:text-body2-desktop placeholder:theme-text-secondary";
const baseTextarea =
  "border theme-border rounded px-3 py-2 bg-white dark:bg-dark-card theme-text-primary focus-ring-primary resize-y text-body2-mobile sm:text-body2-tablet lg:text-body2-desktop placeholder:theme-text-secondary";
const labelCls =
  "font-medium theme-text-primary text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop";
const errorText =
  "theme-text-error text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop mt-1";
const sectionTitle =
  "font-semibold theme-text-primary text-h3-mobile sm:text-h3-tablet lg:text-h3-desktop";
const pageTitle =
  "font-bold theme-text-primary text-h1-mobile sm:text-h1-tablet lg:text-h1-desktop";

/* ================= Multi-Select Checkbox Component for Strings ================= */
const MultiSelectCheckboxString: React.FC<{
  options: { value: string; label: string }[];
  selectedValues: string[];
  onChange: (selectedValues: string[]) => void;
}> = React.memo(({ options, selectedValues, onChange }) => {
  const handleToggle = (value: string) => {
    const newSelectedValues = selectedValues.includes(value)
      ? selectedValues.filter((v) => v !== value)
      : [...selectedValues, value];

    onChange(newSelectedValues);
  };

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
      {options.map((option) => (
        <label
          key={option.value}
          className="flex items-center gap-2 p-2 rounded border theme-border hover:bg-light-secondary dark:hover:bg-dark-secondary cursor-pointer transition-colors"
        >
          <input
            type="checkbox"
            checked={selectedValues.includes(option.value)}
            onChange={() => handleToggle(option.value)}
            className="w-4 h-4 accent-light-primary dark:accent-dark-primary"
          />
          <span className="theme-text-primary text-body2-mobile sm:text-body2-tablet">
            {option.label}
          </span>
        </label>
      ))}
    </div>
  );
});

MultiSelectCheckboxString.displayName = "MultiSelectCheckboxString";

/* ================= Component ================= */
const RestaurantEditPage: React.FC = () => {
  const { restaurantId } = useParams<{ restaurantId: string }>();
  const navigate = useNavigate();
  const [currentStep, setCurrentStep] = useState(1);
  const {
    formData,
    errors,
    loading,
    submitting,
    imageFiles,
    existingImages,
    thumbnailPreview,
    imagePreviews,
    updateField,
    updateArrayField,
    updateOpeningHours,
    setThumbnailFile,
    setImageFiles,
    removeImageFile,
    removeExistingImage,
    handleSubmit,
  } = useRestaurantEdit(restaurantId);

  /* ================= Image Upload Component ================= */
  const ImageUpload: React.FC<{
    label: string;
    multiple?: boolean;
    onSelect: (files: File[]) => void;
    preview?: string | string[] | null;
    onRemove?: () => void;
    onRemoveMultiple?: (index: number) => void;
  }> = ({ label, multiple, onSelect, preview, onRemove, onRemoveMultiple }) => {
    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
      const files = Array.from(e.target.files || []);
      if (files.length > 0) {
        onSelect(files);
      }
    };

    return (
      <div className="flex flex-col gap-2">
        <label className={labelCls}>{label}</label>
        <div className="border-2 theme-border border-dashed rounded p-4 flex flex-col items-center gap-2 cursor-pointer hover:bg-light-secondary dark:hover:bg-dark-secondary">
          <Upload className="w-5 h-5 icon-brand" />
          <input
            type="file"
            accept="image/*"
            multiple={multiple}
            onChange={handleFileChange}
            className="hidden"
            id={`file-upload-${label}`}
          />
          <label
            htmlFor={`file-upload-${label}`}
            className="cursor-pointer theme-text-secondary text-body2-mobile sm:text-body2-tablet text-center"
          >
            {multiple ? "Chọn nhiều ảnh" : "Chọn ảnh"}
          </label>
        </div>

        {preview && (
          <div className="grid gap-3 grid-cols-2 sm:grid-cols-3 md:grid-cols-4 mt-2">
            {Array.isArray(preview) ? (
              preview.map((url, index) => (
                <div
                  key={index}
                  className="relative group rounded-lg overflow-hidden border theme-border"
                >
                  <img
                    src={url}
                    alt={`Preview ${index + 1}`}
                    className="w-full h-32 object-cover"
                  />
                  {onRemoveMultiple && (
                    <button
                      type="button"
                      onClick={() => onRemoveMultiple(index)}
                      className="absolute top-1 right-1 p-1 rounded bg-red-500 text-white opacity-0 group-hover:opacity-100 transition-opacity"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  )}
                </div>
              ))
            ) : (
              <div className="relative group rounded-lg overflow-hidden border theme-border">
                <img
                  src={preview}
                  alt="Preview"
                  className="w-full h-32 object-cover"
                />
                {onRemove && (
                  <button
                    type="button"
                    onClick={onRemove}
                    className="absolute top-1 right-1 p-1 rounded bg-red-500 text-white opacity-0 group-hover:opacity-100 transition-opacity"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                )}
              </div>
            )}
          </div>
        )}
      </div>
    );
  };

  /* Copy all render methods from RestaurantCreatePage with same structure */
  const renderBasicInfo = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Thông tin cơ bản</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Nhập các thông tin bắt buộc và cơ bản về nhà hàng
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>
              Tên nhà hàng <span className="theme-text-error">*</span>
            </label>
            <input
              value={formData.title || ""}
              onChange={(e) => {
                const newTitle = e.target.value;
                updateField("title", newTitle);

                // Tự động tạo slug từ title + 9 số random
                if (newTitle.trim()) {
                  const generatedSlug = generateSlugFromTitle(newTitle);
                  updateField("slug", generatedSlug);
                  updateField("seoTitle", newTitle);
                }
              }}
              className={baseInput}
              placeholder="VD: Nhà hàng Ngon Việt"
              maxLength={255}
            />
            {errors.title && <span className={errorText}>{errors.title}</span>}
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Khu vực <span className="theme-text-error">*</span>
            </label>
            <select
              value={formData.areaId || ""}
              onChange={(e) => {
                const val = e.target.value;
                const areaId = val ? Number(val) : null;
                updateField("areaId", areaId);
                if (areaId) {
                  const areaName = AREAS.find((a) => a.id === areaId)?.name || "";
                  updateField("location", areaName);
                }
              }}
              className={baseInput}
            >
              <option value="">-- Chọn khu vực --</option>
              {AREAS.map((area) => (
                <option key={area.id} value={area.id}>
                  {area.name}
                </option>
              ))}
            </select>
            {errors.areaId && <span className={errorText}>{errors.areaId}</span>}
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Giá trung bình/người (VND) <span className="theme-text-error">*</span>
            </label>
            <input
              type="number"
              value={formData.price || ""}
              onChange={(e) => {
                let val = Number(e.target.value);
                // Auto-cap to MAX_PRICE if exceeds
                if (val > MAX_PRICE) {
                  val = MAX_PRICE;
                }
                if (val >= 0) {
                  updateField("price", val);
                }
              }}
              className={baseInput}
              placeholder="VD: 150000"
              min={0}
              max={MAX_PRICE}
            />
            {errors.price && <span className={errorText}>{errors.price}</span>}
            {formData.price === MAX_PRICE && (
              <span className="text-xs theme-text-warning">
                Đã đạt giới hạn tối đa: {MAX_PRICE.toLocaleString()} VND
              </span>
            )}
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Mức giá</label>
            <select
              value={formData.priceLevel || ""}
              onChange={(e) => updateField("priceLevel", e.target.value as "cheap" | "moderate" | "expensive" | "luxury" | "")}
              className={baseInput}
            >
              <option value="">-- Chọn mức giá --</option>
              {PRICE_LEVELS.map((level) => (
                <option key={level.value} value={level.value}>
                  {level.label}
                </option>
              ))}
            </select>
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Số điện thoại</label>
            <input
              value={formData.phone || ""}
              onChange={(e) => updateField("phone", e.target.value)}
              className={baseInput}
              placeholder="VD: 0901234567"
              maxLength={20}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Website</label>
            <input
              value={formData.website || ""}
              onChange={(e) => updateField("website", e.target.value)}
              className={baseInput}
              placeholder="VD: https://example.com"
              maxLength={255}
            />
          </div>

          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>
              Chọn vị trí trên bản đồ <span className="theme-text-error">*</span>
            </label>
            <MapPicker
              onLocationSelect={(data: LocationData) => {
                updateField("address", data.address);
                updateField("latitude", data.latitude);
                updateField("longitude", data.longitude);
                
                const matchedAreaId = matchAreaFromAddress(data.address);
                if (matchedAreaId) {
                  updateField("areaId", matchedAreaId);
                  const areaName = AREAS.find((a) => a.id === matchedAreaId)?.name || "";
                  updateField("location", areaName);
                }
              }}
              initialLocation={{
                address: formData.address || "",
                location: formData.location || "",
                latitude: formData.latitude || 21.0285,
                longitude: formData.longitude || 105.8542
              }}
            />
            {errors.address && <span className={errorText}>{errors.address}</span>}
          </div>

          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>Mô tả nhà hàng</label>
            <textarea
              value={formData.serviceDescription || ""}
              onChange={(e) => updateField("serviceDescription", e.target.value)}
              className={baseTextarea}
              rows={4}
              placeholder="Nhập mô tả chi tiết về nhà hàng..."
            />
          </div>
        </div>
      </div>
    ),
    [formData, errors, updateField]
  );

  const renderCapacityTime = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Sức chứa & Thời gian</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Cấu hình thông tin về sức chứa và thời gian hoạt động
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Số chỗ ngồi tối đa</label>
            <input
              type="number"
              value={formData.capacity || ""}
              onChange={(e) => {
                const val = e.target.value ? Number(e.target.value) : null;
                updateField("capacity", val);
              }}
              className={baseInput}
              placeholder="VD: 100"
              min={1}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Số người tối thiểu (đặt bàn nhóm)</label>
            <input
              type="number"
              value={formData.minParticipants || ""}
              onChange={(e) => {
                let val = e.target.value ? Number(e.target.value) : null;
                if (val !== null) {
                  val = Math.max(1, val); // Không cho nhỏ hơn 1
                  // Nếu có maxParticipants và minParticipants > maxParticipants thì giới hạn = maxParticipants
                  if (formData.maxParticipants && val > formData.maxParticipants) {
                    val = formData.maxParticipants;
                  }
                }
                updateField("minParticipants", val);
              }}
              className={baseInput}
              placeholder="VD: 10"
              min={1}
              max={formData.maxParticipants || undefined}
            />
            {formData.maxParticipants && (
              <span className="text-xs theme-text-secondary">
                Tối đa: {formData.maxParticipants} người
              </span>
            )}
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Số người tối đa (đặt bàn nhóm)</label>
            <input
              type="number"
              value={formData.maxParticipants || ""}
              onChange={(e) => {
                let val = e.target.value ? Number(e.target.value) : null;
                if (val !== null) {
                  val = Math.max(1, val); // Không cho nhỏ hơn 1
                  // Nếu có minParticipants và maxParticipants < minParticipants thì giới hạn = minParticipants
                  if (formData.minParticipants && val < formData.minParticipants) {
                    val = formData.minParticipants;
                  }
                }
                updateField("maxParticipants", val);
              }}
              className={baseInput}
              placeholder="VD: 50"
              min={formData.minParticipants || 1}
            />
            {formData.minParticipants && (
              <span className="text-xs theme-text-secondary">
                Tối thiểu: {formData.minParticipants} người
              </span>
            )}
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Ngày bắt đầu</label>
            <input
              type="date"
              value={formData.startDate || ""}
              onChange={(e) => updateField("startDate", e.target.value)}
              className={baseInput}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Ngày kết thúc</label>
            <input
              type="date"
              value={formData.endDate || ""}
              onChange={(e) => updateField("endDate", e.target.value)}
              className={baseInput}
            />
          </div>

          <div className="flex flex-col gap-4 md:col-span-2">
            <label className={labelCls}>
              Giờ mở cửa theo ngày <span className="theme-text-error">*</span>
            </label>
            <div className="grid gap-3">
              {DAYS_OF_WEEK.map((day) => {
                const currentValue = formData.openingHoursJson?.[day.key] || "";
                const isClosed = currentValue.toLowerCase().includes("đóng") || currentValue.toLowerCase().includes("closed");
                const [openTime, closeTime] = !isClosed && currentValue.includes("-") 
                  ? currentValue.split("-").map(t => t.trim()) 
                  : ["", ""];

                return (
                  <div key={day.key} className="flex flex-col gap-2">
                    <div className="flex items-center gap-3">
                      <span className="w-24 theme-text-primary text-body2-mobile font-medium">
                        {day.label}:
                      </span>
                      <label className="flex items-center gap-2">
                        <input
                          type="checkbox"
                          checked={isClosed}
                          onChange={(e) => {
                            if (e.target.checked) {
                              updateOpeningHours(day.key, "Đóng cửa");
                            } else {
                              updateOpeningHours(day.key, "08:00-17:00");
                            }
                          }}
                          className="w-4 h-4 accent-light-primary dark:accent-dark-primary"
                        />
                        <span className="text-sm theme-text-secondary">Đóng cửa</span>
                      </label>
                    </div>
                    {!isClosed && (
                      <div className="flex items-center gap-2 ml-24">
                        <input
                          type="time"
                          value={openTime}
                          onChange={(e) => {
                            const newValue = `${e.target.value}-${closeTime || "17:00"}`;
                            updateOpeningHours(day.key, newValue);
                          }}
                          className={baseInput + " flex-1"}
                        />
                        <span className="theme-text-secondary">đến</span>
                        <input
                          type="time"
                          value={closeTime}
                          onChange={(e) => {
                            const newValue = `${openTime || "08:00"}-${e.target.value}`;
                            updateOpeningHours(day.key, newValue);
                          }}
                          className={baseInput + " flex-1"}
                        />
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
            {errors.openingHoursJson && (
              <span className={errorText}>{errors.openingHoursJson}</span>
            )}
          </div>
        </div>
      </div>
    ),
    [formData, errors, updateField, updateOpeningHours]
  );

  const renderServicesFeatures = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Dịch vụ & Đặc điểm</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Chọn các dịch vụ, ẩm thực và đặc điểm của nhà hàng
          </p>
        </div>

        <div className="grid gap-6">
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Loại ẩm thực</label>
            <MultiSelectCheckboxString
              options={CUISINES}
              selectedValues={formData.cuisinesJson || []}
              onChange={(selectedValues) => updateArrayField("cuisinesJson", selectedValues)}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Dịch vụ</label>
            <MultiSelectCheckboxString
              options={SERVICES}
              selectedValues={formData.servicesJson || []}
              onChange={(selectedValues) => updateArrayField("servicesJson", selectedValues)}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Chế độ ăn đặc biệt</label>
            <MultiSelectCheckboxString
              options={DIETS}
              selectedValues={formData.dietsJson || []}
              onChange={(selectedValues) => updateArrayField("dietsJson", selectedValues)}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Phong cách không gian</label>
            <MultiSelectCheckboxString
              options={AMBIANCE_TAGS}
              selectedValues={formData.ambianceTagsJson || []}
              onChange={(selectedValues) => updateArrayField("ambianceTagsJson", selectedValues)}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Phương thức thanh toán</label>
            <MultiSelectCheckboxString
              options={PAYMENT_METHODS}
              selectedValues={formData.paymentMethodsJson || []}
              onChange={(selectedValues) => updateArrayField("paymentMethodsJson", selectedValues)}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Món ăn đặc trưng</label>
            <textarea
              value={(formData.menuHighlightsJson || []).join("\n")}
              onChange={(e) => {
                const lines = e.target.value.split("\n").filter(line => line.trim());
                updateArrayField("menuHighlightsJson", lines);
              }}
              className={baseTextarea}
              rows={4}
              placeholder="Nhập mỗi món ăn trên một dòng. VD:&#10;Phở bò đặc biệt&#10;Bún chả Hà Nội"
            />
            <span className="theme-text-secondary text-caption-mobile">
              Nhập mỗi món ăn trên một dòng
            </span>
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Huy hiệu</label>
            <MultiSelectCheckboxString
              options={BADGES_OPTIONS}
              selectedValues={formData.badges || []}
              onChange={(selectedValues) => updateArrayField("badges", selectedValues)}
            />
          </div>

          <ImageUpload
            label="Ảnh đại diện (Thumbnail)"
            multiple={false}
            onSelect={(files) => setThumbnailFile(files[0])}
            preview={thumbnailPreview}
            onRemove={() => setThumbnailFile(null)}
          />

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Ảnh gallery hiện có</label>
            {existingImages.length > 0 && (
              <div className="grid gap-3 grid-cols-2 sm:grid-cols-3 md:grid-cols-4">
                {existingImages.map((url, index) => (
                  <div
                    key={index}
                    className="relative group rounded-lg overflow-hidden border theme-border"
                  >
                    <img
                      src={url}
                      alt={`Existing ${index + 1}`}
                      className="w-full h-32 object-cover"
                    />
                    <button
                      type="button"
                      onClick={() => removeExistingImage(index)}
                      className="absolute top-1 right-1 p-1 rounded bg-red-500 text-white opacity-0 group-hover:opacity-100 transition-opacity"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>

          <ImageUpload
            label="Thêm ảnh gallery mới"
            multiple={true}
            onSelect={(files) => setImageFiles([...imageFiles, ...files])}
            preview={imagePreviews}
            onRemoveMultiple={(index) => removeImageFile(index)}
          />
        </div>
      </div>
    ),
    [
      formData,
      updateArrayField,
      setThumbnailFile,
      setImageFiles,
      removeImageFile,
      removeExistingImage,
      thumbnailPreview,
      imagePreviews,
      imageFiles,
      existingImages,
    ]
  );

  const renderPoliciesSEO = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Chính sách & SEO</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Nhập chính sách và thông tin SEO cho nhà hàng
          </p>
        </div>

        <div className="grid gap-6">
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Chính sách nhà hàng</label>
            <textarea
              value={formData.policiesText || ""}
              onChange={(e) => updateField("policiesText", e.target.value)}
              className={baseTextarea}
              rows={6}
              placeholder="VD: Dress code, chính sách đặt bàn, chính sách hủy..."
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Slug (URL thân thiện) <span className="theme-text-error">*</span>
            </label>
            <input
              value={formData.slug || ""}
              readOnly
              className={baseInput + " bg-gray-100 dark:bg-gray-800 cursor-not-allowed"}
              placeholder="auto-generated-from-title-123456789"
            />
            <span className="theme-text-secondary text-caption-mobile">
              Tự động tạo từ tên nhà hàng
            </span>
            {errors.slug && <span className={errorText}>{errors.slug}</span>}
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>SEO Title</label>
            <input
              value={formData.seoTitle || ""}
              onChange={(e) => updateField("seoTitle", e.target.value)}
              className={baseInput}
              placeholder="Nhập SEO title"
              maxLength={255}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>SEO Description</label>
            <textarea
              value={formData.seoDescription || ""}
              onChange={(e) => updateField("seoDescription", e.target.value)}
              className={baseTextarea}
              rows={3}
              placeholder="Nhập mô tả SEO..."
              maxLength={512}
            />
          </div>

          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              checked={formData.isFeatured || false}
              onChange={(e) => updateField("isFeatured", e.target.checked)}
              className="w-4 h-4 accent-light-primary dark:accent-dark-primary"
              id="isFeatured"
            />
            <label htmlFor="isFeatured" className={labelCls + " cursor-pointer"}>
              Đánh dấu là nổi bật (Featured)
            </label>
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Chế độ hiển thị <span className="theme-text-error">*</span>
            </label>
            <div className="flex gap-4">
              <label className="flex items-center gap-2">
                <input
                  type="radio"
                  value="public_"
                  checked={formData.visibility === "public_"}
                  onChange={(e) => updateField("visibility", e.target.value as "public_" | "private_")}
                  className="w-4 h-4 accent-light-primary dark:accent-dark-primary"
                />
                <span className="theme-text-primary">Công khai</span>
              </label>
              <label className="flex items-center gap-2">
                <input
                  type="radio"
                  value="private_"
                  checked={formData.visibility === "private_"}
                  onChange={(e) => updateField("visibility", e.target.value as "public_" | "private_")}
                  className="w-4 h-4 accent-light-primary dark:accent-dark-primary"
                />
                <span className="theme-text-primary">Riêng tư</span>
              </label>
            </div>
          </div>
        </div>
      </div>
    ),
    [formData, errors, updateField]
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="w-8 h-8 animate-spin icon-brand" />
      </div>
    );
  }

  return (
    <div className="max-w-5xl mx-auto px-6 py-8 flex flex-col gap-8">
      <div>
        <button
          onClick={() => navigate("/supplier/service/restaurant")}
          className="flex items-center gap-2 theme-text-secondary hover:theme-text-primary transition-colors mb-4"
        >
          <ArrowLeft className="w-5 h-5" />
          <span>Quay lại danh sách nhà hàng</span>
        </button>
        <h1 className={pageTitle}>Chỉnh sửa nhà hàng</h1>
        <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-2">
          Cập nhật thông tin nhà hàng
        </p>
      </div>

      <div className="flex items-center justify-between gap-2 pb-4 border-b theme-border">
        {[
          { step: 1, label: "Thông tin cơ bản" },
          { step: 2, label: "Sức chứa & Thời gian" },
          { step: 3, label: "Dịch vụ & Media" },
          { step: 4, label: "Chính sách & SEO" },
        ].map(({ step, label }) => (
          <button
            key={step}
            onClick={() => setCurrentStep(step)}
            className={`flex-1 px-2 py-2 rounded-lg font-medium transition-colors text-caption-mobile sm:text-body2-tablet ${
              currentStep === step
                ? "bg-light-primary dark:bg-dark-primary text-light-buttonText dark:text-dark-buttonText"
                : "theme-bg-secondary theme-text-secondary hover:bg-light-secondary dark:hover:bg-dark-secondary"
            }`}
          >
            {step}. {label}
          </button>
        ))}
      </div>

      {errors.general && (
        <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded p-4 theme-text-error">
          {errors.general}
        </div>
      )}

      <div className="border theme-border rounded-xl p-6 theme-bg-card shadow-sm">
        {currentStep === 1 && renderBasicInfo}
        {currentStep === 2 && renderCapacityTime}
        {currentStep === 3 && renderServicesFeatures}
        {currentStep === 4 && renderPoliciesSEO}
      </div>

      <div className="flex justify-between items-center gap-4">
        <button
          onClick={() => setCurrentStep((prev) => Math.max(1, prev - 1))}
          disabled={currentStep === 1}
          className="flex items-center gap-2 px-4 py-2 rounded theme-bg-secondary theme-text-primary disabled:opacity-50 disabled:cursor-not-allowed hover:opacity-80 transition-opacity"
        >
          <ChevronLeft className="w-5 h-5" />
          <span>Quay lại</span>
        </button>

        <div className="flex gap-3">
          {currentStep < 4 ? (
            <button
              onClick={() => setCurrentStep((prev) => Math.min(4, prev + 1))}
              className="flex items-center gap-2 px-6 py-2 rounded bg-light-primary dark:bg-dark-primary text-white hover:opacity-90 transition-opacity"
            >
              <span>Tiếp theo</span>
              <ChevronRight className="w-5 h-5" />
            </button>
          ) : (
            <>
              <button
                onClick={() => handleSubmit("archived")}
                disabled={submitting}
                className="px-6 py-2 rounded border theme-border theme-text-primary hover:theme-bg-secondary transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {submitting ? "Đang lưu..." : "Lưu nháp"}
              </button>
              <button
                onClick={() => handleSubmit("published")}
                disabled={submitting}
                className="px-6 py-2 rounded bg-light-primary dark:bg-dark-primary text-white hover:opacity-90 transition-opacity disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {submitting ? "Đang cập nhật..." : "Cập nhật"}
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default RestaurantEditPage;
