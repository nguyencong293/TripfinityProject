import React, { useState, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import {
  ChevronLeft,
  ChevronRight,
  Loader2,
  Upload,
  Trash2,
  ArrowLeft,
} from "lucide-react";
import { useAttractionCreate } from "../../../hooks/useAttractions";
import MapPicker, { type LocationData } from "../../../components/common/MapPicker";

/* ================= Constants ================= */
const ATTRACTION_TYPES = [
  { value: "museum", label: "Bảo tàng" },
  { value: "park", label: "Công viên" },
  { value: "temple", label: "Chùa/Đền" },
  { value: "landmark", label: "Địa danh" },
  { value: "theme_park", label: "Công viên giải trí" },
  { value: "cultural_site", label: "Di tích văn hóa" },
  { value: "natural_attraction", label: "Điểm tự nhiên" },
  { value: "entertainment", label: "Giải trí" },
  { value: "historical_site", label: "Di tích lịch sử" },
  { value: "other", label: "Khác" },
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

const VISIT_TYPES = [
  { value: "guided_tour", label: "Tham quan có hướng dẫn viên" },
  { value: "self_guided", label: "Tự do tham quan" },
  { value: "audio_guide", label: "Hướng dẫn âm thanh" },
  { value: "virtual_tour", label: "Tham quan ảo" },
];

const AVAILABLE_TIMES = [
  { value: "morning", label: "Sáng" },
  { value: "afternoon", label: "Chiều" },
  { value: "evening", label: "Tối" },
  { value: "night", label: "Đêm" },
];

const SUITABLE_FOR = [
  { value: "family", label: "Gia đình" },
  { value: "kids", label: "Trẻ em" },
  { value: "elderly", label: "Người cao tuổi" },
  { value: "couples", label: "Cặp đôi" },
  { value: "groups", label: "Nhóm" },
  { value: "solo", label: "Một mình" },
  { value: "pets", label: "Thú cưng" },
];

// Price constraints for attraction price input
const MAX_PRICE = 1000000000; // 1,000,000,000 VND

// Helper function to match province from address string
const matchAreaFromAddress = (address: string): number | null => {
  const normalizedAddress = address.toLowerCase();
  
  // Tìm tỉnh/thành phố trong danh sách AREAS
  for (const area of AREAS) {
    const areaName = area.name.toLowerCase();
    // Remove "thành phố" prefix for matching
    const areaNameSimple = areaName.replace(/^(thành phố|tp\.?)\s*/i, '').trim();
    
    if (normalizedAddress.includes(areaName) || normalizedAddress.includes(areaNameSimple)) {
      return area.id;
    }
  }
  
  return null;
};

// Highlights Dictionary (ID-based) - Reused from hotel
const HIGHLIGHTS_OPTIONS = [
  { id: 1, label: "View biển" },
  { id: 2, label: "View núi" },
  { id: 3, label: "Trung tâm thành phố" },
  { id: 4, label: "Gần sân bay" },
  { id: 5, label: "Hồ bơi ngoài trời" },
  { id: 6, label: "Hồ bơi trong nhà" },
  { id: 7, label: "Spa & Massage" },
  { id: 8, label: "Phòng gym" },
  { id: 9, label: "Nhà hàng cao cấp" },
  { id: 10, label: "Bar & Lounge" },
  { id: 11, label: "Bãi biển riêng" },
  { id: 12, label: "Hồ bơi vô cực" },
  { id: 13, label: "Bar hồ bơi" },
  { id: 14, label: "Câu lạc bộ trẻ em (Kids Club)" },
  { id: 15, label: "Dịch vụ trông trẻ" },
  { id: 16, label: "Sân tennis" },
  { id: 17, label: "Sân golf gần kề" },
  { id: 18, label: "Thể thao dưới nước" },
  { id: 19, label: "Lặn biển / Snorkeling" },
  { id: 20, label: "Kayak / Chèo SUP" },
  { id: 21, label: "Công viên nước mini" },
  { id: 22, label: "Rooftop bar" },
  { id: 23, label: "Nhà hàng buffet" },
  { id: 24, label: "Trung tâm hội nghị / phòng họp" },
  { id: 25, label: "Dịch vụ đưa đón sân bay" },
  { id: 26, label: "Dịch vụ đưa đón trong khu" },
  { id: 27, label: "Bãi đỗ xe có nhân viên (valet)" },
  { id: 28, label: "Xông hơi / Sauna" },
  { id: 29, label: "Bể sục / Jacuzzi" },
  { id: 30, label: "Khu vui chơi trẻ em" },
];

// Features Dictionary (ID-based) - Adapted for attractions
const FEATURES_OPTIONS = [
  { id: 1, label: "WiFi miễn phí" },
  { id: 2, label: "Điều hòa" },
  { id: 3, label: "Nhà vệ sinh công cộng" },
  { id: 4, label: "Quầy thông tin" },
  { id: 5, label: "Cửa hàng lưu niệm" },
  { id: 6, label: "Nhà hàng/Quán ăn" },
  { id: 7, label: "Quầy cà phê" },
  { id: 8, label: "Bãi đậu xe miễn phí" },
  { id: 9, label: "Bãi đậu xe có phí" },
  { id: 10, label: "Cho phép thú cưng" },
  { id: 11, label: "Hướng dẫn viên" },
  { id: 12, label: "Audio guide" },
  { id: 13, label: "Phòng trưng bày" },
  { id: 14, label: "Khu vui chơi trẻ em" },
  { id: 15, label: "Khu picnic" },
  { id: 16, label: "Máy bán hàng tự động" },
  { id: 17, label: "Phòng khám y tế" },
  { id: 18, label: "Lễ tân/Quầy vé" },
  { id: 19, label: "Thang máy" },
  { id: 20, label: "Tiện nghi cho người khuyết tật" },
  { id: 21, label: "Đổi tiền / ATM" },
  { id: 22, label: "Trạm sạc xe điện" },
  { id: 23, label: "Khu vực chụp ảnh" },
  { id: 24, label: "Sân khấu/Biểu diễn" },
  { id: 25, label: "Phòng chiếu phim" },
  { id: 26, label: "Thư viện" },
  { id: 27, label: "Phòng VR/AR" },
  { id: 28, label: "Khu vườn" },
  { id: 29, label: "Đài quan sát" },
  { id: 30, label: "Bảo vệ 24/7" },
];

// Badges Options (string-based for selection) - Reused from hotel
const BADGES_OPTIONS = [
  { value: "Bestseller", label: "Bestseller" },
  { value: "New", label: "Mới" },
  { value: "Hot Deal", label: "Hot Deal" },
  { value: "Recommended", label: "Được đề xuất" },
  { value: "Popular", label: "Phổ biến" },
  { value: "Luxury", label: "Cao cấp" },
  { value: "Budget-Friendly", label: "Giá tốt" },
  { value: "Family-Friendly", label: "Thân thiện gia đình" },
  { value: "Pet-Friendly", label: "Cho phép thú cưng" },
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

/* ================= Multi-Select Checkbox Component (for number[] - IDs) ================= */
const MultiSelectCheckbox: React.FC<{
  options: { id: number; label: string }[];
  selectedIds: number[];
  onChange: (selectedIds: number[]) => void;
}> = React.memo(({ options, selectedIds, onChange }) => {
  const handleToggle = (id: number) => {
    const newSelectedIds = selectedIds.includes(id)
      ? selectedIds.filter((i) => i !== id)
      : [...selectedIds, id];

    onChange(newSelectedIds);
  };

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
      {options.map((option) => (
        <label
          key={option.id}
          className="flex items-center gap-2 p-2 rounded border theme-border hover:bg-light-secondary dark:hover:bg-dark-secondary cursor-pointer transition-colors"
        >
          <input
            type="checkbox"
            checked={selectedIds.includes(option.id)}
            onChange={() => handleToggle(option.id)}
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

MultiSelectCheckbox.displayName = "MultiSelectCheckbox";

/* ================= Multi-Select Checkbox Component for Strings (for string[] - Badges, Visit Types, etc) ================= */
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
const AttractionCreatePage: React.FC = () => {
  const navigate = useNavigate();
  const [currentStep, setCurrentStep] = useState(1);
  const {
    formData,
    errors,
    loading,
    submitting,
    imageFiles,
    thumbnailPreview,
    imagePreviews,
    updateField,
    updateArrayField,
    updateOpeningHours,
    setThumbnailFile,
    setImageFiles,
    removeImageFile,
    handleSubmit,
  } = useAttractionCreate();

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
            className="cursor-pointer theme-text-secondary text-body2-mobile sm:text-body2-tablet"
          >
            {label}
          </label>
        </div>

        {preview && (
          <div className="grid gap-3 grid-cols-2 sm:grid-cols-3 md:grid-cols-4 mt-2">
            {Array.isArray(preview) ? (
              preview.map((url, index) => (
                <div key={index} className="relative group">
                  <img
                    src={url}
                    alt={`Preview ${index}`}
                    className="w-full h-28 object-cover rounded border theme-border"
                  />
                  {onRemoveMultiple && (
                    <button
                      onClick={() => onRemoveMultiple(index)}
                      className="absolute top-1 right-1 p-1 bg-white/90 rounded hover:bg-white"
                      type="button"
                    >
                      <Trash2 className="w-3 h-3 theme-text-error" />
                    </button>
                  )}
                </div>
              ))
            ) : (
              <div className="relative group">
                <img
                  src={preview}
                  alt="Preview"
                  className="w-full h-28 object-cover rounded border theme-border"
                />
                {onRemove && (
                  <button
                    onClick={() => onRemove()}
                    className="absolute top-1 right-1 p-1 bg-white/90 rounded hover:bg-white"
                    type="button"
                  >
                    <Trash2 className="w-3 h-3 theme-text-error" />
                  </button>
                )}
              </div>
            )}
          </div>
        )}
      </div>
    );
  };

  /* ================= STEP 1: Thông tin cơ bản ================= */
  const renderBasicInfo = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Thông tin cơ bản</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Nhập các thông tin bắt buộc và cơ bản về điểm tham quan
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          {/* Title - REQUIRED */}
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>
              Tên điểm tham quan <span className="theme-text-error">*</span>
            </label>
            <input
              value={formData.title || ""}
              onChange={(e) => {
                const newTitle = e.target.value;
                updateField("title", newTitle);

                // Tự động tạo slug từ title + 9 số random
                if (newTitle.trim()) {
                  const slugBase = newTitle
                    .toLowerCase()
                    .normalize("NFD")
                    .replace(/[\u0300-\u036f]/g, "") // Remove accents
                    .replace(/đ/g, "d")
                    .replace(/[^a-z0-9\s-]/g, "")
                    .replace(/\s+/g, "-")
                    .replace(/-+/g, "-")
                    .replace(/^-|-$/g, "");
                  
                  // Generate 9 random digits
                  const randomDigits = Math.floor(100000000 + Math.random() * 900000000);
                  const slug = `${slugBase}-${randomDigits}`;
                  
                  updateField("slug", slug);
                }
              }}
              className={baseInput}
              placeholder="VD: Bảo tàng Hồ Chí Minh"
              maxLength={255}
            />
            {errors.title && <span className={errorText}>{errors.title}</span>}
          </div>

          {/* Area - REQUIRED */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Khu vực <span className="theme-text-error">*</span>
            </label>
            <select
              value={formData.areaId || ""}
              onChange={(e) => {
                const newAreaId = Number(e.target.value) || null;
                updateField("areaId", newAreaId);
                
                // Tự động set location field với tên tỉnh
                if (newAreaId) {
                  const selectedArea = AREAS.find(a => a.id === newAreaId);
                  if (selectedArea) {
                    updateField("location", selectedArea.name);
                  }
                } else {
                  updateField("location", "");
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
            {errors.areaId && (
              <span className={errorText}>{errors.areaId}</span>
            )}
          </div>

          {/* Price - REQUIRED */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Giá vé (VND) <span className="theme-text-error">*</span>
            </label>
            <input
              type="number"
              value={formData.price ?? ""}
              onChange={(e) => {
                const raw = e.target.value;
                if (raw === "") {
                  updateField("price", 0);
                  return;
                }
                const parsed = Math.floor(Number(raw));
                const clamped = Math.min(Math.max(parsed || 0, 0), MAX_PRICE);
                updateField("price", clamped);
              }}
              className={baseInput}
              placeholder="0"
              min={0}
              max={MAX_PRICE}
              step={1}
              inputMode="numeric"
            />
            <span className="text-xs theme-text-secondary">
              Tối đa: {MAX_PRICE.toLocaleString("vi-VN")} VND
            </span>
            {errors.price && <span className={errorText}>{errors.price}</span>}
          </div>

          {/* Attraction Type */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Loại hình <span className="theme-text-error">*</span>
            </label>
            <select
              value={formData.attractionType || "other"}
              onChange={(e) => {
                const value = e.target.value as
                  | "museum"
                  | "park"
                  | "temple"
                  | "landmark"
                  | "theme_park"
                  | "cultural_site"
                  | "natural_attraction"
                  | "entertainment"
                  | "historical_site"
                  | "other";
                updateField("attractionType", value);
              }}
              className={baseInput}
            >
              {ATTRACTION_TYPES.map((type) => (
                <option key={type.value} value={type.value}>
                  {type.label}
                </option>
              ))}
            </select>
            {errors.attractionType && (
              <span className={errorText}>{errors.attractionType}</span>
            )}
          </div>

          {/* Average Visit Minutes */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Thời gian tham quan (phút) <span className="theme-text-error">*</span>
            </label>
            <input
              type="number"
              value={formData.averageVisitMinutes ?? ""}
              onChange={(e) => {
                const raw = e.target.value;
                const val = raw === "" ? null : Math.max(0, Number(raw) || 0);
                updateField("averageVisitMinutes", val);
              }}
              className={baseInput}
              placeholder="VD: 120"
              min="0"
            />
            {errors.averageVisitMinutes && (
              <span className={errorText}>{errors.averageVisitMinutes}</span>
            )}
          </div>

          {/* Location & Address - Map Picker */}
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>
              Vị trí & Địa chỉ <span className="theme-text-error">*</span>
            </label>
            <MapPicker
              onLocationSelect={(data: LocationData) => {
                updateField("address", data.address);
                updateField("latitude", data.latitude);
                updateField("longitude", data.longitude);
                
                // Tự động match và set areaId từ address
                const matchedAreaId = matchAreaFromAddress(data.address);
                if (matchedAreaId) {
                  updateField("areaId", matchedAreaId);
                  
                  // Cũng set location field
                  const matchedArea = AREAS.find(a => a.id === matchedAreaId);
                  if (matchedArea) {
                    updateField("location", matchedArea.name);
                  }
                }
              }}
              initialLocation={
                formData.latitude && formData.longitude
                  ? {
                      address: formData.address || "",
                      location: "",
                      latitude: formData.latitude,
                      longitude: formData.longitude,
                    }
                  : undefined
              }
            />
            {formData.address && (
              <div className="text-caption-mobile theme-text-secondary">
                <strong>Địa chỉ:</strong> {formData.address}
              </div>
            )}
            {errors.address && (
              <span className={errorText}>{errors.address}</span>
            )}
            {errors.location && (
              <span className={errorText}>{errors.location}</span>
            )}
          </div>

          {/* Service Description */}
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>
              Mô tả dịch vụ <span className="theme-text-error">*</span>
            </label>
            <textarea
              value={formData.serviceDescription || ""}
              onChange={(e) => {
                updateField("serviceDescription", e.target.value);
              }}
              className={baseTextarea}
              rows={6}
              placeholder="Mô tả chi tiết về điểm tham quan..."
              maxLength={5000}
            />
            <span className="theme-text-secondary text-caption-mobile ml-auto">
              {(formData.serviceDescription || "").length}/5000
            </span>
            {errors.serviceDescription && (
              <span className={errorText}>{errors.serviceDescription}</span>
            )}
          </div>
        </div>
      </div>
    ),
    [formData, errors, updateField]
  );

  /* ================= STEP 2: Chi tiết sức chứa & thời gian ================= */
  const renderCapacityTime = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Sức chứa & Thời gian</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Thông tin về sức chứa, số lượng khách và thời gian hoạt động
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Sức chứa (số khách) <span className="theme-text-error">*</span>
            </label>
            <input
              type="number"
              value={formData.capacity || ""}
              onChange={(e) => {
                const raw = e.target.value;
                const newCapacity =
                  raw === "" ? null : Math.max(0, Number(raw) || 0);
                updateField("capacity", newCapacity);
                
                // Tự động điều chỉnh min/max cho phù hợp
                const cap = newCapacity ?? 0;
                const currentMin = formData.minParticipants ?? 0;
                const currentMax = formData.maxParticipants ?? 0;
                const adjMin = Math.min(Math.max(0, currentMin), cap);
                const adjMax = Math.min(Math.max(adjMin, currentMax), cap);
                if (adjMin !== currentMin)
                  updateField("minParticipants", adjMin);
                if (adjMax !== currentMax)
                  updateField("maxParticipants", adjMax);
              }}
              className={baseInput}
              placeholder="VD: 200"
              min="0"
            />
            {errors.capacity && (
              <span className={errorText}>{errors.capacity}</span>
            )}
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Đơn vị tiền tệ</label>
            <input
              value={formData.currencyCode || "VND"}
              className={baseInput}
              disabled
            />
            <span className="theme-text-secondary text-caption-mobile">
              Mặc định: VND
            </span>
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Số lượng tối thiểu</label>
            <input
              type="number"
              value={formData.minParticipants || ""}
              onChange={(e) => {
                const raw = e.target.value;
                const cap = formData.capacity ?? 0;
                let next = raw === "" ? null : Number(raw) || 0;
                if (next !== null) next = Math.min(Math.max(0, next), cap);
                updateField("minParticipants", next);
                
                // Đảm bảo max >= min
                const currentMax = formData.maxParticipants ?? 0;
                if (next !== null && currentMax < next) {
                  updateField("maxParticipants", next);
                }
              }}
              className={baseInput}
              placeholder="VD: 1"
              min={0}
              max={formData.capacity ?? undefined}
            />
            <span className="text-xs theme-text-secondary">
              0 ≤ tối thiểu ≤ sức chứa
            </span>
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Số lượng tối đa</label>
            <input
              type="number"
              value={formData.maxParticipants || ""}
              onChange={(e) => {
                const raw = e.target.value;
                const cap = formData.capacity ?? 0;
                const currentMin = formData.minParticipants ?? 0;
                let next = raw === "" ? null : Number(raw) || 0;
                if (next !== null)
                  next = Math.min(Math.max(currentMin, next), cap);
                updateField("maxParticipants", next);
              }}
              className={baseInput}
              placeholder="VD: 50"
              min={formData.minParticipants ?? 0}
              max={formData.capacity ?? undefined}
            />
            <span className="text-xs theme-text-secondary">
              tối thiểu ≤ tối đa ≤ sức chứa
            </span>
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Ngày bắt đầu hoạt động <span className="theme-text-error">*</span>
            </label>
            <input
              type="date"
              value={formData.startDate || ""}
              onChange={(e) => {
                updateField("startDate", e.target.value);
              }}
              className={baseInput}
            />
            {errors.startDate && (
              <span className={errorText}>{errors.startDate}</span>
            )}
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Ngày kết thúc hoạt động <span className="theme-text-error">*</span>
            </label>
            <input
              type="date"
              value={formData.endDate || ""}
              onChange={(e) => {
                updateField("endDate", e.target.value);
              }}
              className={baseInput}
            />
            {errors.endDate && (
              <span className={errorText}>{errors.endDate}</span>
            )}
          </div>

          {/* Opening Hours - Per Day of Week */}
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

          {/* Visit Types */}
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>
              Loại hình tham quan
            </label>
            <MultiSelectCheckboxString
              options={VISIT_TYPES}
              selectedValues={formData.visitTypesJson || []}
              onChange={(selectedValues) => {
                updateArrayField("visitTypesJson", selectedValues);
              }}
            />
            <span className="theme-text-secondary text-caption-mobile">
              Chọn các loại hình tham quan có sẵn. Đã chọn:{" "}
              {formData.visitTypesJson?.length || 0} mục
            </span>
          </div>

          {/* Available Times */}
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>
              Khung giờ tham quan
            </label>
            <MultiSelectCheckboxString
              options={AVAILABLE_TIMES}
              selectedValues={formData.availableTimesJson || []}
              onChange={(selectedValues) => {
                updateArrayField("availableTimesJson", selectedValues);
              }}
            />
            <span className="theme-text-secondary text-caption-mobile">
              Chọn các khung giờ có thể tham quan. Đã chọn:{" "}
              {formData.availableTimesJson?.length || 0} mục
            </span>
          </div>
        </div>
      </div>
    ),
    [formData, errors, updateField, updateArrayField, updateOpeningHours]
  );

  /* ================= STEP 3: Tiện nghi & Hình ảnh ================= */
  const renderFeaturesMedia = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Tiện nghi & Hình ảnh</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Các điểm nổi bật, tiện nghi, đối tượng phù hợp, huy hiệu và hình ảnh
          </p>
        </div>

        <div className="grid gap-6">
          {/* Highlights - Multi-select (ID-based) */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Điểm nổi bật
              {formData.highlightsJson &&
                formData.highlightsJson.length > 0 && (
                  <span className="ml-2 text-green-600">
                    ({formData.highlightsJson.length} mục)
                  </span>
                )}
            </label>
            <MultiSelectCheckbox
              options={HIGHLIGHTS_OPTIONS}
              selectedIds={formData.highlightsJson || []}
              onChange={(selectedIds) => {
                updateArrayField("highlightsJson", selectedIds);
              }}
            />
            <span className="theme-text-secondary text-caption-mobile">
              Chọn các điểm nổi bật của điểm tham quan. Đã chọn:{" "}
              {formData.highlightsJson?.length || 0} mục
            </span>
          </div>

          {/* Features - Multi-select (ID-based) */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Tiện nghi
              {formData.featuresJson && formData.featuresJson.length > 0 && (
                <span className="ml-2 text-green-600">
                  ({formData.featuresJson.length} mục)
                </span>
              )}
            </label>
            <MultiSelectCheckbox
              options={FEATURES_OPTIONS}
              selectedIds={formData.featuresJson || []}
              onChange={(selectedIds) => {
                updateArrayField("featuresJson", selectedIds);
              }}
            />
            <span className="theme-text-secondary text-caption-mobile">
              Chọn các tiện nghi có sẵn. Đã chọn:{" "}
              {formData.featuresJson?.length || 0} mục
            </span>
          </div>

          {/* Suitable For - Multi-select (String-based) */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Phù hợp cho
              {formData.suitableForJson &&
                formData.suitableForJson.length > 0 && (
                  <span className="ml-2 text-green-600">
                    ({formData.suitableForJson.length} mục)
                  </span>
                )}
            </label>
            <MultiSelectCheckboxString
              options={SUITABLE_FOR}
              selectedValues={formData.suitableForJson || []}
              onChange={(selectedValues) => {
                updateArrayField("suitableForJson", selectedValues);
              }}
            />
            <span className="theme-text-secondary text-caption-mobile">
              Chọn đối tượng phù hợp. Đã chọn:{" "}
              {formData.suitableForJson?.length || 0} mục
            </span>
          </div>

          {/* Badges - Multi-select (String-based) */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Huy hiệu (Badges)
              {formData.badges && formData.badges.length > 0 && (
                <span className="ml-2 text-green-600">
                  ({formData.badges.length} mục)
                </span>
              )}
            </label>
            <MultiSelectCheckboxString
              options={BADGES_OPTIONS}
              selectedValues={formData.badges || []}
              onChange={(selectedValues) => {
                updateArrayField("badges", selectedValues);
              }}
            />
            <span className="theme-text-secondary text-caption-mobile">
              Chọn các huy hiệu cho điểm tham quan. Đã chọn:{" "}
              {formData.badges?.length || 0} mục
            </span>
          </div>

          <div>
            <ImageUpload
              label="Ảnh đại diện"
              onSelect={(files) => {
                setThumbnailFile(files[0]);
              }}
              preview={thumbnailPreview}
              onRemove={() => {
                setThumbnailFile(null);
              }}
            />
          </div>

          <div>
            <ImageUpload
              label="Thư viện ảnh"
              multiple
              onSelect={(files) => {
                setImageFiles([...imageFiles, ...files]);
              }}
              preview={imagePreviews}
              onRemoveMultiple={(index) => {
                removeImageFile(index);
              }}
            />
          </div>
        </div>
      </div>
    ),
    [
      formData,
      updateArrayField,
      setThumbnailFile,
      setImageFiles,
      removeImageFile,
      thumbnailPreview,
      imagePreviews,
      imageFiles,
    ]
  );

  /* ================= STEP 4: Chính sách & SEO ================= */
  const renderPoliciesSEO = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Chính sách & SEO</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Chính sách, lời khuyên và tối ưu hóa SEO
          </p>
        </div>

        <div className="grid gap-6">
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Chính sách & Quy định <span className="theme-text-error">*</span>
            </label>
            <textarea
              value={formData.policiesText || ""}
              onChange={(e) => {
                updateField("policiesText", e.target.value);
              }}
              className={baseTextarea}
              rows={5}
              placeholder="Các chính sách hủy vé, quy định về an toàn, giờ mở cửa..."
            />
            {errors.policiesText && (
              <span className={errorText}>{errors.policiesText}</span>
            )}
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Lời khuyên cho du khách</label>
            <textarea
              value={formData.tipsText || ""}
              onChange={(e) => {
                updateField("tipsText", e.target.value);
              }}
              className={baseTextarea}
              rows={4}
              placeholder="Những lời khuyên hữu ích cho du khách khi đến tham quan..."
            />
            <span className="theme-text-secondary text-caption-mobile">
              VD: Nên mặc trang phục lịch sự, mang theo ô dù, tránh giờ cao điểm...
            </span>
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Đường dẫn (Slug)
              <span className="ml-2 text-xs theme-text-secondary">(Tự động tạo)</span>
            </label>
            <input
              value={formData.slug || ""}
              className={`${baseInput} bg-gray-100 dark:bg-gray-800 cursor-not-allowed`}
              placeholder="Tự động tạo từ tên điểm tham quan"
              disabled
              readOnly
            />
            <span className="theme-text-secondary text-caption-mobile">
              Slug sẽ được tạo tự động: tên-điểm-tham-quan-123456789 (9 số ngẫu nhiên)
            </span>
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Tiêu đề SEO</label>
            <input
              value={formData.seoTitle || ""}
              onChange={(e) => {
                updateField("seoTitle", e.target.value);
              }}
              className={baseInput}
              placeholder="Tiêu đề tối ưu cho công cụ tìm kiếm"
              maxLength={255}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Mô tả SEO</label>
            <textarea
              value={formData.seoDescription || ""}
              onChange={(e) => {
                updateField("seoDescription", e.target.value);
              }}
              className={baseTextarea}
              rows={3}
              placeholder="Mô tả ngắn gọn hiển thị trên kết quả tìm kiếm..."
              maxLength={512}
            />
            <span className="theme-text-secondary text-caption-mobile ml-auto">
              {(formData.seoDescription || "").length}/512
            </span>
          </div>

          <div className="flex flex-col gap-3 border theme-border rounded p-4">
            <h3 className="font-semibold theme-text-primary">
              Cài đặt hiển thị
            </h3>

            <label className="flex items-center gap-2 theme-text-primary cursor-pointer">
              <input
                type="checkbox"
                checked={formData.isFeatured || false}
                onChange={(e) => {
                  updateField("isFeatured", e.target.checked);
                }}
                className="w-4 h-4"
              />
              <span>Nổi bật (Hiển thị ưu tiên trên trang chủ)</span>
            </label>

            <div className="flex items-center gap-3">
              <label className={labelCls}>Chế độ hiển thị:</label>
              <select
                value={formData.visibility || "public_"}
                onChange={(e) => {
                  updateField(
                    "visibility",
                    e.target.value as "public_" | "private_"
                  );
                }}
                className={baseInput + " !py-1"}
              >
                <option value="public_">Công khai</option>
                <option value="private_">Riêng tư</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    ),
    [formData, errors, updateField]
  );

  // Loading state
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
          onClick={() => navigate(-1)}
          className="btn-outline px-4 py-2 mb-4 flex items-center gap-2 hover:bg-light-secondary dark:hover:bg-dark-secondary transition-colors"
        >
          <ArrowLeft className="w-4 h-4" />
          Quay lại
        </button>
        <h1 className={pageTitle}>Tạo điểm tham quan mới</h1>
        <p className="theme-text-secondary text-body1-mobile sm:text-body1-tablet mt-2">
          Các trường có dấu <span className="theme-text-error">*</span> là bắt
          buộc
        </p>
      </div>

      <div className="flex items-center justify-between gap-2 pb-4 border-b theme-border">
        {[
          { step: 1, label: "Thông tin cơ bản" },
          { step: 2, label: "Sức chứa & Thời gian" },
          { step: 3, label: "Tiện nghi & Media" },
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
        {currentStep === 3 && renderFeaturesMedia}
        {currentStep === 4 && renderPoliciesSEO}
      </div>

      <div className="flex justify-between items-center gap-4">
        <button
          onClick={() => setCurrentStep((prev) => Math.max(1, prev - 1))}
          disabled={currentStep === 1}
          className="btn-outline btn-text-responsive px-6 py-3 disabled:opacity-50 flex items-center gap-2"
        >
          <ChevronLeft className="w-4 h-4" />
          Quay lại
        </button>

        <div className="flex gap-3">
          <button
            onClick={() => {
              handleSubmit("archived");
            }}
            disabled={submitting}
            className="btn-secondary btn-text-responsive px-6 py-3 disabled:opacity-60 flex items-center gap-2"
          >
            {submitting && <Loader2 className="w-4 h-4 animate-spin" />}
            Lưu nháp
          </button>

          {currentStep < 4 ? (
            <button
              onClick={() => setCurrentStep((prev) => Math.min(4, prev + 1))}
              className="btn-primary btn-text-responsive px-6 py-3 flex items-center gap-2"
            >
              Tiếp theo
              <ChevronRight className="w-4 h-4" />
            </button>
          ) : (
            <button
              onClick={() => {
                handleSubmit("published");
              }}
              disabled={submitting}
              className="btn-primary btn-text-responsive px-6 py-3 disabled:opacity-60 flex items-center gap-2"
            >
              {submitting && <Loader2 className="w-4 h-4 animate-spin" />}
              Xuất bản
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default AttractionCreatePage;
