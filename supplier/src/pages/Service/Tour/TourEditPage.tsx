import React, { useState, useMemo, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import {
  ChevronLeft,
  ChevronRight,
  Loader2,
  ArrowLeft,
  Plus,
  Trash2,
} from "lucide-react";
import { useTourEdit } from "../../../hooks/useTours";
import {
  MultiSelectCheckboxString,
  ImageUpload,
} from "../../../components/service";
import MapPicker, { type LocationData } from "../../../components/common/MapPicker";
import {
  TOUR_CATEGORIES,
  TOUR_SERVICES,
  GUIDE_LANGUAGES,
  DIFFICULTY_LEVELS,
  TOUR_TYPES,
  INCLUDED_ITEMS,
  EXCLUDED_ITEMS,
  TOUR_BADGES,
} from "../../../constants/tourConstants";

/* ================= Constants ================= */
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
  { id: 58, name: "TP Hồ Chí Minh" },
  { id: 59, name: "Trà Vinh" },
  { id: 60, name: "Tuyên Quang" },
  { id: 61, name: "Vĩnh Long" },
  { id: 62, name: "Vĩnh Phúc" },
  { id: 63, name: "Yên Bái" },
];

// Helper function to match province from address string
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

/* ================= Types ================= */
interface ItineraryDay {
  day: number;
  title: string;
  activities: string[];
}

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

/* ================= Component ================= */
const TourEditPage: React.FC = () => {
  const navigate = useNavigate();
  const { tourId } = useParams<{ tourId: string }>();
  const [currentStep, setCurrentStep] = useState(1);
  const [itinerary, setItinerary] = useState<ItineraryDay[]>([]);

  const {
    formData,
    errors,
    loading,
    submitting,
    existingThumbnailUrl,
    existingImageUrls,
    imageFiles,
    thumbnailPreview,
    imagePreviews,
    updateField,
    updateArrayField,
    setThumbnailFile,
    setImageFiles,
    removeImageFile,
    handleSubmit,
  } = useTourEdit(Number(tourId));

  // Sync itinerary from formData
  useEffect(() => {
    if (formData.itineraryDetailsJson.length > 0) {
      setItinerary(formData.itineraryDetailsJson);
    }
  }, [formData.itineraryDetailsJson]);

  // Itinerary management
  const addItineraryDay = () => {
    const newDay: ItineraryDay = {
      day: itinerary.length + 1,
      title: "",
      activities: [""],
    };
    const updated = [...itinerary, newDay];
    setItinerary(updated);
    updateField("itineraryDetailsJson", updated);
  };

  const removeItineraryDay = (dayIndex: number) => {
    const updated = itinerary
      .filter((_, i) => i !== dayIndex)
      .map((day, i) => ({ ...day, day: i + 1 }));
    setItinerary(updated);
    updateField("itineraryDetailsJson", updated);
  };

  const updateItineraryDay = (
    dayIndex: number,
    _field: "title",
    value: string
  ) => {
    const updated = [...itinerary];
    updated[dayIndex].title = value;
    setItinerary(updated);
    updateField("itineraryDetailsJson", updated);
  };

  const addActivity = (dayIndex: number) => {
    const updated = [...itinerary];
    updated[dayIndex].activities.push("");
    setItinerary(updated);
    updateField("itineraryDetailsJson", updated);
  };

  const updateActivity = (
    dayIndex: number,
    activityIndex: number,
    value: string
  ) => {
    const updated = [...itinerary];
    updated[dayIndex].activities[activityIndex] = value;
    setItinerary(updated);
    updateField("itineraryDetailsJson", updated);
  };

  const removeActivity = (dayIndex: number, activityIndex: number) => {
    const updated = [...itinerary];
    updated[dayIndex].activities = updated[dayIndex].activities.filter(
      (_, i) => i !== activityIndex
    );
    setItinerary(updated);
    updateField("itineraryDetailsJson", updated);
  };

  /* ================= STEP 1: Thông tin cơ bản ================= */
  const renderBasicInfo = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Thông tin cơ bản</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Chỉnh sửa các thông tin cơ bản về tour
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          {/* Title */}
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>
              Tên tour <span className="theme-text-error">*</span>
            </label>
            <input
              value={formData.title || ""}
              onChange={(e) => updateField("title", e.target.value)}
              className={baseInput}
              placeholder="VD: Tour Hà Nội - Hạ Long 3N2Đ"
              maxLength={255}
            />
            {errors.title && <span className={errorText}>{errors.title}</span>}
          </div>

          {/* Area */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Khu vực <span className="theme-text-error">*</span>
            </label>
            <select
              value={formData.areaId || ""}
              onChange={(e) => {
                const newAreaId = Number(e.target.value) || null;
                updateField("areaId", newAreaId);

                if (newAreaId) {
                  const selectedArea = AREAS.find((a) => a.id === newAreaId);
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

          {/* Price */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Giá tour (VND) <span className="theme-text-error">*</span>
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
                const clamped = Math.min(Math.max(parsed || 0, 0), 1000000000);
                updateField("price", clamped);
              }}
              className={baseInput}
              placeholder="0"
              min={0}
              max={1000000000}
              step={1}
              inputMode="numeric"
            />
            <span className="text-xs theme-text-secondary">
              Tối đa: 1,000,000,000 VND
            </span>
            {errors.price && <span className={errorText}>{errors.price}</span>}
          </div>

          {/* Tour Type */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Loại tour</label>
            <select
              value={formData.tourType || "group"}
              onChange={(e) =>
                updateField(
                  "tourType",
                  e.target.value as "group" | "private" | "custom"
                )
              }
              className={baseInput}
            >
              {TOUR_TYPES.map((type) => (
                <option key={type.value} value={type.value}>
                  {type.label}
                </option>
              ))}
            </select>
          </div>

          {/* Difficulty */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Độ khó</label>
            <select
              value={formData.difficultyLevel || "easy"}
              onChange={(e) =>
                updateField(
                  "difficultyLevel",
                  e.target.value as "easy" | "moderate" | "hard"
                )
              }
              className={baseInput}
            >
              {DIFFICULTY_LEVELS.map((level) => (
                <option key={level.value} value={level.value}>
                  {level.label}
                </option>
              ))}
            </select>
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
                
                const matchedAreaId = matchAreaFromAddress(data.address);
                if (matchedAreaId) {
                  updateField("areaId", matchedAreaId);
                  
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

          {/* Description */}
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>
              Mô tả tour <span className="theme-text-error">*</span>
            </label>
            <textarea
              value={formData.serviceDescription || ""}
              onChange={(e) =>
                updateField("serviceDescription", e.target.value)
              }
              className={baseTextarea}
              rows={6}
              placeholder="Mô tả chi tiết về tour của bạn..."
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

  /* ================= STEP 2: Lịch trình & Người tham gia ================= */
  const renderScheduleParticipants = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Lịch trình & Người tham gia</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Cập nhật thông tin về thời gian và sức chứa
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          {/* Duration */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Số ngày tour</label>
            <input
              type="number"
              min="1"
              value={formData.durationDays || ""}
              onChange={(e) => {
                const days = e.target.value ? Number(e.target.value) : null;
                updateField("durationDays", days);
                
                // Auto-calculate end date if start date exists
                if (days && formData.startDate) {
                  const start = new Date(formData.startDate);
                  const end = new Date(start);
                  end.setDate(start.getDate() + days - 1);
                  updateField("endDate", end.toISOString().split('T')[0]);
                }
              }}
              className={baseInput}
              placeholder="3"
            />
          </div>

          {/* Capacity */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Sức chứa (số người) <span className="theme-text-error">*</span>
            </label>
            <input
              type="number"
              value={formData.capacity || ""}
              onChange={(e) => {
                const val = Number(e.target.value) || null;
                updateField("capacity", val);
              }}
              className={baseInput}
              placeholder="20"
              min={0}
            />
            {errors.capacity && (
              <span className={errorText}>{errors.capacity}</span>
            )}
          </div>

          {/* Start Date */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Ngày bắt đầu <span className="theme-text-error">*</span>
            </label>
            <input
              type="date"
              value={formData.startDate || ""}
              onChange={(e) => {
                updateField("startDate", e.target.value);
                
                // Auto-calculate end date if duration exists
                if (formData.durationDays && e.target.value) {
                  const start = new Date(e.target.value);
                  const end = new Date(start);
                  end.setDate(start.getDate() + formData.durationDays - 1);
                  updateField("endDate", end.toISOString().split('T')[0]);
                }
              }}
              className={baseInput}
            />
            {errors.startDate && (
              <span className={errorText}>{errors.startDate}</span>
            )}
          </div>

          {/* End Date */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>
              Ngày kết thúc <span className="theme-text-error">*</span>
            </label>
            <input
              type="date"
              value={formData.endDate || ""}
              disabled
              className={baseInput + " bg-gray-100 dark:bg-gray-800 cursor-not-allowed"}
              title="Ngày kết thúc được tính tự động từ số ngày tour và ngày bắt đầu"
            />
          </div>

          {/* Departure Location */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Điểm khởi hành</label>
            <input
              type="text"
              value={formData.departureLocation || ""}
              onChange={(e) =>
                updateField("departureLocation", e.target.value)
              }
              className={baseInput}
              placeholder="Sân bay Nội Bài"
            />
          </div>

          {/* Meeting Point */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Điểm tập trung</label>
            <input
              type="text"
              value={formData.meetingPoint || ""}
              onChange={(e) => updateField("meetingPoint", e.target.value)}
              className={baseInput}
              placeholder="Cổng chính khách sạn"
            />
          </div>

          {/* Min Participants */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Số người tối thiểu</label>
            <input
              type="number"
              value={formData.minParticipants || ""}
              onChange={(e) =>
                updateField(
                  "minParticipants",
                  e.target.value ? Number(e.target.value) : null
                )
              }
              className={baseInput}
              placeholder="1"
              min={0}
            />
          </div>

          {/* Max Participants */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Số người tối đa</label>
            <input
              type="number"
              value={formData.maxParticipants || ""}
              onChange={(e) =>
                updateField(
                  "maxParticipants",
                  e.target.value ? Number(e.target.value) : null
                )
              }
              className={baseInput}
              placeholder="20"
              min={0}
            />
          </div>
        </div>
      </div>
    ),
    [formData, errors, updateField]
  );

  /* ================= STEP 3: Tiện ích & Chi tiết hành trình ================= */
  const renderAmenitiesItinerary = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Tiện ích & Chi tiết hành trình</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Chỉnh sửa các tiện ích và hành trình chi tiết
          </p>
        </div>

        {/* Categories */}
        <div className="flex flex-col gap-2">
          <label className={labelCls}>Danh mục tour</label>
          <MultiSelectCheckboxString
            options={TOUR_CATEGORIES}
            selectedValues={formData.categoriesJson}
            onChange={(values) => updateArrayField("categoriesJson", values)}
            fieldName="categoriesJson"
          />
        </div>

        {/* Services */}
        <div className="flex flex-col gap-2">
          <label className={labelCls}>Dịch vụ bổ sung</label>
          <MultiSelectCheckboxString
            options={TOUR_SERVICES}
            selectedValues={formData.servicesJson}
            onChange={(values) => updateArrayField("servicesJson", values)}
            fieldName="servicesJson"
          />
        </div>

        {/* Languages */}
        <div className="flex flex-col gap-2">
          <label className={labelCls}>Ngôn ngữ hướng dẫn viên</label>
          <MultiSelectCheckboxString
            options={GUIDE_LANGUAGES}
            selectedValues={formData.guideLanguagesJson}
            onChange={(values) =>
              updateArrayField("guideLanguagesJson", values)
            }
            fieldName="guideLanguagesJson"
          />
        </div>

        {/* Included Items */}
        <div className="flex flex-col gap-2">
          <label className={labelCls}>Bao gồm trong tour</label>
          <MultiSelectCheckboxString
            options={INCLUDED_ITEMS}
            selectedValues={formData.includedJson}
            onChange={(values) => updateArrayField("includedJson", values)}
            fieldName="includedJson"
          />
        </div>

        {/* Excluded Items */}
        <div className="flex flex-col gap-2">
          <label className={labelCls}>Không bao gồm trong tour</label>
          <MultiSelectCheckboxString
            options={EXCLUDED_ITEMS}
            selectedValues={formData.excludedJson}
            onChange={(values) => updateArrayField("excludedJson", values)}
            fieldName="excludedJson"
          />
        </div>

        {/* Itinerary Overview */}
        <div className="flex flex-col gap-2">
          <label className={labelCls}>Tổng quan lịch trình</label>
          <textarea
            value={formData.itineraryOverview || ""}
            onChange={(e) => updateField("itineraryOverview", e.target.value)}
            className={baseTextarea}
            rows={4}
            placeholder="Mô tả tổng quan về hành trình tour..."
          />
        </div>

        {/* Daily Itinerary */}
        <div className="flex flex-col gap-4">
          <div className="flex items-center justify-between">
            <label className={labelCls}>Chi tiết hành trình theo ngày</label>
            <button
              type="button"
              onClick={addItineraryDay}
              disabled={!formData.durationDays || itinerary.length >= (formData.durationDays || 0)}
              className="flex items-center gap-2 px-4 py-2 bg-light-primary dark:bg-dark-primary text-white rounded hover:opacity-90 disabled:opacity-50 disabled:cursor-not-allowed"
              title={itinerary.length >= (formData.durationDays || 0) ? `Đã đủ ${formData.durationDays} ngày` : "Thêm ngày mới"}
            >
              <Plus className="w-4 h-4" />
              Thêm ngày
            </button>
          </div>

          {itinerary.map((day, dayIndex) => (
            <div
              key={dayIndex}
              className="border theme-border rounded p-4 flex flex-col gap-3"
            >
              <div className="flex items-center justify-between">
                <span className="font-semibold theme-text-primary">
                  Ngày {day.day}
                </span>
                <button
                  type="button"
                  onClick={() => removeItineraryDay(dayIndex)}
                  className="p-1 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>

              <input
                type="text"
                value={day.title}
                onChange={(e) =>
                  updateItineraryDay(dayIndex, "title", e.target.value)
                }
                className={baseInput}
                placeholder="Tiêu đề ngày (VD: Khám phá Hà Nội)"
              />

              <div className="flex flex-col gap-2">
                <label className="text-sm theme-text-secondary">
                  Hoạt động
                </label>
                {day.activities.map((activity, actIndex) => (
                  <div key={actIndex} className="flex gap-2">
                    <input
                      type="text"
                      value={activity}
                      onChange={(e) =>
                        updateActivity(dayIndex, actIndex, e.target.value)
                      }
                      className={baseInput + " flex-1"}
                      placeholder={`Hoạt động ${actIndex + 1}`}
                    />
                    <button
                      type="button"
                      onClick={() => removeActivity(dayIndex, actIndex)}
                      className="p-2 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                ))}
                <button
                  type="button"
                  onClick={() => addActivity(dayIndex)}
                  className="px-3 py-2 border theme-border rounded theme-text-secondary hover:bg-light-secondary dark:hover:bg-dark-secondary"
                >
                  + Thêm hoạt động
                </button>
              </div>
            </div>
          ))}

          {itinerary.length === 0 && (
            <div className="text-center theme-text-secondary py-8 border theme-border border-dashed rounded">
              Chưa có hành trình chi tiết. Nhấn "Thêm ngày" để bắt đầu.
            </div>
          )}
        </div>
      </div>
    ),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [formData, itinerary, updateField, updateArrayField]
  );

  /* ================= STEP 4: Media, Chính sách & SEO ================= */
  const renderMediaPoliciesSEO = useMemo(
    () => (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className={sectionTitle}>Media, Chính sách & SEO</h2>
          <p className="theme-text-secondary text-body2-mobile sm:text-body2-tablet mt-1">
            Cập nhật ảnh, chính sách và SEO
          </p>
        </div>

        {/* Existing Thumbnail */}
        {existingThumbnailUrl && !thumbnailPreview && (
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Ảnh đại diện hiện tại</label>
            <div className="relative w-40 h-40 border theme-border rounded overflow-hidden">
              <img
                src={existingThumbnailUrl}
                alt="Current thumbnail"
                className="w-full h-full object-cover"
              />
            </div>
          </div>
        )}

        {/* Thumbnail */}
        <ImageUpload
          label="Ảnh đại diện tour (upload mới để thay thế)"
          onSelect={(files) => setThumbnailFile(files[0])}
          preview={thumbnailPreview}
          onRemove={() => setThumbnailFile(null)}
        />

        {/* Existing Gallery */}
        {existingImageUrls.length > 0 && (
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Thư viện ảnh hiện tại ({existingImageUrls.length} ảnh)</label>
            <div className="grid grid-cols-3 md:grid-cols-4 gap-2">
              {existingImageUrls.map((url, idx) => (
                <div key={idx} className="relative aspect-square border theme-border rounded overflow-hidden">
                  <img
                    src={url}
                    alt={`Gallery ${idx + 1}`}
                    className="w-full h-full object-cover"
                  />
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Gallery */}
        <ImageUpload
          label="Thêm ảnh mới vào thư viện"
          multiple
          onSelect={(files) => setImageFiles([...imageFiles, ...files])}
          preview={imagePreviews}
          onRemoveMultiple={(index) => removeImageFile(index)}
        />

        {/* Badges */}
        <div className="flex flex-col gap-2">
          <label className={labelCls}>Huy hiệu (Badges)</label>
          <MultiSelectCheckboxString
            options={TOUR_BADGES}
            selectedValues={formData.badges}
            onChange={(values) => updateArrayField("badges", values)}
            fieldName="badges"
          />
        </div>

        {/* Cancellation Policy */}
        <div className="flex flex-col gap-2">
          <label className={labelCls}>Chính sách hủy tour</label>
          <textarea
            value={formData.cancellationPolicy || ""}
            onChange={(e) =>
              updateField("cancellationPolicy", e.target.value)
            }
            className={baseTextarea}
            rows={4}
            placeholder="VD: Hủy trước 7 ngày: hoàn 100%, hủy trước 3 ngày: hoàn 50%..."
          />
        </div>

        {/* Other Policies */}
        <div className="flex flex-col gap-2">
          <label className={labelCls}>Các chính sách khác</label>
          <textarea
            value={formData.policiesText || ""}
            onChange={(e) => updateField("policiesText", e.target.value)}
            className={baseTextarea}
            rows={4}
            placeholder="Chính sách về trẻ em, người cao tuổi, hành lý..."
          />
        </div>

        {/* Visibility */}
        <div className="flex flex-col gap-2">
          <label className={labelCls}>Hiển thị</label>
          <select
            value={formData.visibility || "public"}
            onChange={(e) =>
              updateField("visibility", e.target.value as "public" | "private")
            }
            className={baseInput}
          >
            <option value="public">Công khai</option>
            <option value="private">Riêng tư</option>
          </select>
        </div>

        {/* Featured */}
        <div className="flex items-center gap-2">
          <input
            type="checkbox"
            id="isFeatured"
            checked={formData.isFeatured}
            onChange={(e) => updateField("isFeatured", e.target.checked)}
            className="w-4 h-4 accent-light-primary dark:accent-dark-primary"
          />
          <label htmlFor="isFeatured" className={labelCls}>
            Tour nổi bật
          </label>
        </div>

        <div className="border-t theme-border pt-6">
          <h3 className="font-semibold theme-text-primary mb-4">
            Tối ưu SEO
          </h3>

          {/* Slug */}
          <div className="flex flex-col gap-2 mb-4">
            <label className={labelCls}>Slug (URL)</label>
            <input
              type="text"
              value={formData.slug || ""}
              className={`${baseInput} bg-gray-100 dark:bg-gray-800 cursor-not-allowed`}
              placeholder="Slug từ tour gốc"
              disabled
              readOnly
            />
            <span className="theme-text-secondary text-caption-mobile">
              Slug không thể thay đổi sau khi tạo
            </span>
          </div>

          {/* SEO Title */}
          <div className="flex flex-col gap-2 mb-4">
            <label className={labelCls}>Tiêu đề SEO</label>
            <input
              type="text"
              value={formData.seoTitle || ""}
              onChange={(e) => updateField("seoTitle", e.target.value)}
              className={baseInput}
              maxLength={255}
              placeholder="Tiêu đề tối ưu cho công cụ tìm kiếm"
            />
            <span className="theme-text-secondary text-caption-mobile">
              {(formData.seoTitle || "").length}/255
            </span>
          </div>

          {/* SEO Description */}
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Mô tả SEO</label>
            <textarea
              value={formData.seoDescription || ""}
              onChange={(e) => updateField("seoDescription", e.target.value)}
              className={baseTextarea}
              rows={3}
              maxLength={512}
              placeholder="Mô tả ngắn gọn hiển thị trên kết quả tìm kiếm..."
            />
            <span className="theme-text-secondary text-caption-mobile ml-auto">
              {(formData.seoDescription || "").length}/512
            </span>
          </div>
        </div>
      </div>
    ),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [
      formData,
      existingThumbnailUrl,
      existingImageUrls,
      thumbnailPreview,
      imagePreviews,
      imageFiles,
      updateField,
      updateArrayField,
    ]
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
        <h1 className={pageTitle}>Chỉnh sửa tour</h1>
        <p className="theme-text-secondary text-body1-mobile sm:text-body1-tablet mt-2">
          Các trường có dấu <span className="theme-text-error">*</span> là bắt
          buộc
        </p>
      </div>

      <div className="flex items-center justify-between gap-2 pb-4 border-b theme-border">
        {[
          { step: 1, label: "Thông tin cơ bản" },
          { step: 2, label: "Lịch trình" },
          { step: 3, label: "Tiện ích" },
          { step: 4, label: "Media & SEO" },
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
        {currentStep === 2 && renderScheduleParticipants}
        {currentStep === 3 && renderAmenitiesItinerary}
        {currentStep === 4 && renderMediaPoliciesSEO}
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
            onClick={async () => {
              const result = await handleSubmit("archived");
              if (result && !result.success && result.missingFields.length > 0) {
                const userConfirmed = window.confirm(
                  `⚠️ VUI LÒNG ĐIỀN ĐẦY ĐỦ CÁC TRƯỜNG BẮT BUỘC!\n\nCác trường còn thiếu:\n${result.missingFields.map(f => `• ${f}`).join('\n')}\n\nVui lòng kiểm tra và điền đầy đủ thông tin trước khi lưu.\n\nNhấn OK để tải lại trang.`
                );
                if (userConfirmed) {
                  window.location.reload();
                }
              }
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
              onClick={async () => {
                const result = await handleSubmit("published");
                if (result && !result.success && result.missingFields.length > 0) {
                  const userConfirmed = window.confirm(
                    `⚠️ VUI LÒNG ĐIỀN ĐẦY ĐỦ CÁC TRƯỜNG BẮT BUỘC!\n\nCác trường còn thiếu:\n${result.missingFields.map(f => `• ${f}`).join('\n')}\n\nVui lòng kiểm tra và điền đầy đủ thông tin trước khi cập nhật.\n\nNhấn OK để tải lại trang.`
                  );
                  if (userConfirmed) {
                    window.location.reload();
                  }
                }
              }}
              disabled={submitting}
              className="btn-primary btn-text-responsive px-6 py-3 disabled:opacity-60 flex items-center gap-2"
            >
              {submitting && <Loader2 className="w-4 h-4 animate-spin" />}
              Cập nhật
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default TourEditPage;
