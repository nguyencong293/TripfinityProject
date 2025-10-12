import React, { useState, useEffect, useMemo } from "react";
import {
  ChevronLeft,
  ChevronRight,
  Loader2,
  Upload,
  Trash2,
} from "lucide-react";
import { useHotelCreate } from "../../../hooks/useHotels";

/* ================= Constants ================= */
const PROPERTY_TYPES = [
  { value: "hotel", label: "Khách sạn" },
  { value: "resort", label: "Resort" },
  { value: "apartment", label: "Căn hộ" },
  { value: "villa", label: "Biệt thự" },
  { value: "hostel", label: "Hostel" },
  { value: "guesthouse", label: "Nhà khách" },
  { value: "homestay", label: "Homestay" },
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

const STAR_RATINGS = [1, 2, 3, 4, 5];

// Price constraints for hotel price input
const MAX_PRICE = 1000000000; // 1,000,000,000 VND

// Highlights Dictionary (ID-based)
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
  // Bổ sung dành cho resort/khách sạn
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

// Amenities Dictionary (ID-based)
const AMENITIES_OPTIONS = [
  { id: 1, label: "WiFi miễn phí" },
  { id: 2, label: "Điều hòa" },
  { id: 3, label: "Tivi màn hình phẳng" },
  { id: 4, label: "Minibar" },
  { id: 5, label: "Két an toàn" },
  { id: 6, label: "Máy sấy tóc" },
  { id: 7, label: "Dịch vụ phòng 24/7" },
  { id: 8, label: "Bãi đậu xe miễn phí" },
  { id: 9, label: "Đưa đón sân bay" },
  { id: 10, label: "Cho phép thú cưng" },
  // Bổ sung tiện nghi phổ biến
  { id: 11, label: "Máy pha cà phê / Ấm đun" },
  { id: 12, label: "Áo choàng tắm & Dép đi trong phòng" },
  { id: 13, label: "Ban công / Sân hiên" },
  { id: 14, label: "Tầm nhìn ra biển / hồ / núi" },
  { id: 15, label: "Góc bếp (kitchenette)" },
  { id: 16, label: "Máy giặt" },
  { id: 17, label: "Bàn ủi / Bàn là" },
  { id: 18, label: "Lễ tân 24/7" },
  { id: 19, label: "Dịch vụ Concierge" },
  { id: 20, label: "Giữ hành lý" },
  { id: 21, label: "Thang máy" },
  { id: 22, label: "Phòng/tiện nghi cho người khuyết tật" },
  { id: 23, label: "Đổi tiền / ATM" },
  { id: 24, label: "Trạm sạc xe điện" },
  { id: 25, label: "Phòng xông hơi / Sauna" },
  { id: 26, label: "Phòng tắm hơi ướt / Steam" },
  { id: 27, label: "Bồn tắm nóng / Jacuzzi" },
  { id: 28, label: "Hồ bơi trẻ em" },
  { id: 29, label: "Sân chơi trẻ em" },
  { id: 30, label: "Sân tennis / Thuê vợt" },
  { id: 31, label: "Thuê xe đạp" },
  { id: 32, label: "Dịch vụ thuê xe / taxi" },
  { id: 33, label: "Bãi biển gần" },
  { id: 34, label: "Phòng họp / Tiệc" },
  { id: 35, label: "Ăn sáng miễn phí" },
];

// Badges Options (string-based for selection)
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
  fieldName: string;
}> = React.memo(({ options, selectedIds, onChange, fieldName }) => {
  const handleToggle = (id: number) => {
    const newSelectedIds = selectedIds.includes(id)
      ? selectedIds.filter((i) => i !== id)
      : [...selectedIds, id];

    console.log(
      `🔄 MultiSelect [${fieldName}] toggled ID ${id}, new array:`,
      newSelectedIds
    );
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

/* ================= Multi-Select Checkbox Component for Strings (for string[] - Badges) ================= */
const MultiSelectCheckboxString: React.FC<{
  options: { value: string; label: string }[];
  selectedValues: string[];
  onChange: (selectedValues: string[]) => void;
  fieldName: string;
}> = React.memo(({ options, selectedValues, onChange, fieldName }) => {
  const handleToggle = (value: string) => {
    const newSelectedValues = selectedValues.includes(value)
      ? selectedValues.filter((v) => v !== value)
      : [...selectedValues, value];

    console.log(
      `🔄 MultiSelectString [${fieldName}] toggled "${value}", new array:`,
      newSelectedValues
    );
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
const HotelCreatePage: React.FC = () => {
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
    setThumbnailFile,
    setImageFiles,
    removeImageFile,
    handleSubmit,
  } = useHotelCreate();

  // 🔍 DEBUG: Log formData chi tiết
  useEffect(() => {
    console.log("📋 Current formData detailed:", {
      title: formData.title,
      highlightsJson: formData.highlightsJson,
      highlightsJson_length: formData.highlightsJson?.length,
      amenitiesJson: formData.amenitiesJson,
      amenitiesJson_length: formData.amenitiesJson?.length,
      badges: formData.badges,
      badges_length: formData.badges?.length,
      policiesText: formData.policiesText,
      serviceDescription: formData.serviceDescription,
      location: formData.location,
      address: formData.address,
    });
  }, [formData]);

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
            Nhập các thông tin bắt buộc và cơ bản về khách sạn
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          {/* Title - REQUIRED */}
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>
              Tên khách sạn <span className="theme-text-error">*</span>
            </label>
            <input
              value={formData.title || ""}
              onChange={(e) => {
                const newTitle = e.target.value;
                console.log(`🔄 Title changed to: "${newTitle}"`);
                updateField("title", newTitle);

                // Auto-generate slug from title
                if (!formData.slug || formData.slug === "") {
                  const slug = newTitle
                    .toLowerCase()
                    .normalize("NFD")
                    .replace(/[\u0300-\u036f]/g, "")
                    .replace(/đ/g, "d")
                    .replace(/[^a-z0-9]+/g, "-")
                    .replace(/(^-|-$)/g, "");
                  console.log(`🔄 Auto-generated slug: "${slug}"`);
                  updateField("slug", slug);
                }
              }}
              className={baseInput}
              placeholder="VD: Khách sạn Biển Xanh"
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
                console.log(`🔄 Area changed to: ${newAreaId}`);
                updateField("areaId", newAreaId);
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
              Giá (VND) <span className="theme-text-error">*</span>
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
                console.log(
                  `🔄 Price changed to: ${parsed} -> clamped: ${clamped}`
                );
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

          {/* Property Type */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Loại hình</label>
            <select
              value={formData.propertyType || "hotel"}
              onChange={(e) => {
                const value = e.target.value as
                  | "hotel"
                  | "resort"
                  | "apartment"
                  | "villa"
                  | "hostel"
                  | "guesthouse"
                  | "homestay";
                console.log(`🔄 Property type changed to: ${value}`);
                updateField("propertyType", value);
              }}
              className={baseInput}
            >
              {PROPERTY_TYPES.map((type) => (
                <option key={type.value} value={type.value}>
                  {type.label}
                </option>
              ))}
            </select>
            <span className="theme-text-secondary text-caption-mobile">
              Mặc định: Khách sạn
            </span>
          </div>

          {/* Star Rating */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Hạng sao</label>
            <select
              value={formData.starRating || ""}
              onChange={(e) => {
                const newStarRating = Number(e.target.value) || null;
                console.log(`🔄 Star rating changed to: ${newStarRating}`);
                updateField("starRating", newStarRating);
              }}
              className={baseInput}
            >
              <option value="">-- Chọn hạng sao --</option>
              {STAR_RATINGS.map((star) => (
                <option key={star} value={star}>
                  {star} sao
                </option>
              ))}
            </select>
          </div>

          {/* Location */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Vị trí</label>
            <input
              value={formData.location || ""}
              onChange={(e) => {
                console.log(`🔄 Location changed to: "${e.target.value}"`);
                updateField("location", e.target.value);
              }}
              className={baseInput}
              placeholder="VD: Quận 1, TP.HCM"
              maxLength={255}
            />
          </div>

          {/* Address */}
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>Địa chỉ chi tiết</label>
            <input
              value={formData.address || ""}
              onChange={(e) => {
                console.log(`🔄 Address changed to: "${e.target.value}"`);
                updateField("address", e.target.value);
              }}
              className={baseInput}
              placeholder="Số nhà, tên đường..."
              maxLength={255}
            />
          </div>

          {/* Service Description */}
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>Mô tả dịch vụ</label>
            <textarea
              value={formData.serviceDescription || ""}
              onChange={(e) => {
                console.log(
                  `🔄 Service description changed, length: ${e.target.value.length}`
                );
                updateField("serviceDescription", e.target.value);
              }}
              className={baseTextarea}
              rows={6}
              placeholder="Mô tả chi tiết về khách sạn..."
              maxLength={5000}
            />
            <span className="theme-text-secondary text-caption-mobile ml-auto">
              {(formData.serviceDescription || "").length}/5000
            </span>
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
            <label className={labelCls}>Sức chứa (số khách)</label>
            <input
              type="number"
              value={formData.capacity || ""}
              onChange={(e) => {
                const raw = e.target.value;
                const newCapacity =
                  raw === "" ? null : Math.max(0, Number(raw) || 0);
                console.log(`🔄 Capacity changed to: ${newCapacity}`);
                // Cập nhật capacity trước
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
              placeholder="VD: 100"
              min="0"
            />
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
                console.log(`🔄 Min participants changed to: ${next}`);
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
                console.log(`🔄 Max participants changed to: ${next}`);
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
            <label className={labelCls}>Ngày bắt đầu hoạt động</label>
            <input
              type="date"
              value={formData.startDate || ""}
              onChange={(e) => {
                console.log(`🔄 Start date changed to: ${e.target.value}`);
                updateField("startDate", e.target.value);
              }}
              className={baseInput}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Ngày kết thúc hoạt động</label>
            <input
              type="date"
              value={formData.endDate || ""}
              onChange={(e) => {
                console.log(`🔄 End date changed to: ${e.target.value}`);
                updateField("endDate", e.target.value);
              }}
              className={baseInput}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Giờ check-in</label>
            <input
              type="time"
              value={formData.checkinTime || ""}
              onChange={(e) => {
                console.log(`🔄 Check-in time changed to: ${e.target.value}`);
                updateField("checkinTime", e.target.value);
              }}
              className={baseInput}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Giờ check-out</label>
            <input
              type="time"
              value={formData.checkoutTime || ""}
              onChange={(e) => {
                console.log(`🔄 Check-out time changed to: ${e.target.value}`);
                updateField("checkoutTime", e.target.value);
              }}
              className={baseInput}
            />
          </div>
        </div>
      </div>
    ),
    [formData, updateField]
  );

  /* ================= STEP 3: Tiện nghi & Hình ảnh ================= */
  const renderAmenitiesMedia = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Tiện nghi & Hình ảnh</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Các điểm nổi bật, tiện nghi, huy hiệu và hình ảnh của khách sạn
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
              fieldName="highlightsJson"
              options={HIGHLIGHTS_OPTIONS}
              selectedIds={formData.highlightsJson || []}
              onChange={(selectedIds) => {
                console.log(`🔄 Highlights IDs changed to:`, selectedIds);
                updateArrayField("highlightsJson", selectedIds);
              }}
            />
            <span className="theme-text-secondary text-caption-mobile">
              Chọn các điểm nổi bật của khách sạn. Đã chọn:{" "}
              {formData.highlightsJson?.length || 0} mục
            </span>
          </div>

          {/* Amenities - Multi-select (ID-based) */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Tiện nghi
              {formData.amenitiesJson && formData.amenitiesJson.length > 0 && (
                <span className="ml-2 text-green-600">
                  ({formData.amenitiesJson.length} mục)
                </span>
              )}
            </label>
            <MultiSelectCheckbox
              fieldName="amenitiesJson"
              options={AMENITIES_OPTIONS}
              selectedIds={formData.amenitiesJson || []}
              onChange={(selectedIds) => {
                console.log(`🔄 Amenities IDs changed to:`, selectedIds);
                updateArrayField("amenitiesJson", selectedIds);
              }}
            />
            <span className="theme-text-secondary text-caption-mobile">
              Chọn các tiện nghi có sẵn. Đã chọn:{" "}
              {formData.amenitiesJson?.length || 0} mục
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
              fieldName="badges"
              options={BADGES_OPTIONS}
              selectedValues={formData.badges || []}
              onChange={(selectedValues) => {
                console.log(`🔄 Badges changed to:`, selectedValues);
                updateArrayField("badges", selectedValues);
              }}
            />
            <span className="theme-text-secondary text-caption-mobile">
              Chọn các huy hiệu cho khách sạn. Đã chọn:{" "}
              {formData.badges?.length || 0} mục
            </span>
          </div>

          <div>
            <ImageUpload
              label="Ảnh đại diện"
              onSelect={(files) => {
                console.log(`🔄 Thumbnail selected:`, files[0]?.name);
                setThumbnailFile(files[0]);
              }}
              preview={thumbnailPreview}
              onRemove={() => {
                console.log(`🔄 Thumbnail removed`);
                setThumbnailFile(null);
              }}
            />
          </div>

          <div>
            <ImageUpload
              label="Thư viện ảnh"
              multiple
              onSelect={(files) => {
                console.log(
                  `🔄 Images selected:`,
                  files.map((f) => f.name)
                );
                setImageFiles([...imageFiles, ...files]);
              }}
              preview={imagePreviews}
              onRemoveMultiple={(index) => {
                console.log(`🔄 Image removed at index:`, index);
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
            Chính sách khách sạn và tối ưu hóa SEO
          </p>
        </div>

        <div className="grid gap-6">
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Chính sách & Quy định</label>
            <textarea
              value={formData.policiesText || ""}
              onChange={(e) => {
                console.log(
                  `🔄 Policies text changed, length: ${e.target.value.length}`
                );
                updateField("policiesText", e.target.value);
              }}
              className={baseTextarea}
              rows={5}
              placeholder="Các chính sách hủy đặt phòng, quy định về thời gian nhận/trả phòng..."
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Đường dẫn (Slug)</label>
            <input
              value={formData.slug || ""}
              onChange={(e) => {
                console.log(`🔄 Slug changed to: "${e.target.value}"`);
                updateField("slug", e.target.value);
              }}
              className={baseInput}
              placeholder="khach-san-bien-xanh"
              maxLength={255}
            />
            <span className="theme-text-secondary text-caption-mobile">
              Tự động tạo từ tên khách sạn
            </span>
          </div>

          <div className="flex flex-col gap-2">
            <label className={labelCls}>Tiêu đề SEO</label>
            <input
              value={formData.seoTitle || ""}
              onChange={(e) => {
                console.log(`🔄 SEO title changed to: "${e.target.value}"`);
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
                console.log(
                  `🔄 SEO description changed, length: ${e.target.value.length}`
                );
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
                  console.log(`🔄 Is featured changed to: ${e.target.checked}`);
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
                  console.log(`🔄 Visibility changed to: ${e.target.value}`);
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
    [formData, updateField]
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
        <h1 className={pageTitle}>Tạo khách sạn mới</h1>
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
        {currentStep === 3 && renderAmenitiesMedia}
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
              console.log("🔄 Saving as draft...");
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
                console.log("🔄 Publishing hotel...");
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

export default HotelCreatePage;
