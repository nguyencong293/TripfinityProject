import React, { useState, useMemo, useCallback } from "react";
import {
  ChevronLeft,
  ChevronRight,
  Loader2,
  Upload,
  Star,
  Trash2,
  Building2,
} from "lucide-react";
import { useParams } from "react-router-dom";

/* ================= Types ================= */
type ListingStatus = "draft" | "published";
interface MediaImage {
  id: string;
  url: string;
  alt?: string;
  is_thumbnail?: boolean;
}
interface PriceOption {
  id: string;
  option_name: string;
  price: number;
  currency_code: string;
  per_person: boolean;
  description?: string;
  includes_json: string[];
  is_addon: boolean;
}
interface CancellationPolicyTier {
  id: string;
  from_days: number;
  to_days: number;
  refund_percent?: number;
  penalty_description?: string;
}
interface AddonItem {
  id: string;
  name: string;
  price: number;
  currency_code: string;
  per_person: boolean;
  available_all_dates: boolean;
  description?: string;
}
interface RoomType {
  id: string;
  name: string;
  capacity: number;
  quantity_total: number;
  notes?: string;
}
interface BookingSettings {
  auto_accept: boolean;
  cancellation_requires_admin_approval: boolean;
  require_passport_scan?: boolean;
  terms_text?: string;
}
interface SeoConfig {
  seo_title?: string;
  seo_description?: string;
  seo_keywords?: string[];
  visibility: "public" | "private";
  publish_now: boolean;
  publish_at?: string | null;
}
interface HotelDraft {
  status: ListingStatus;
  title?: string;
  short_description?: string;
  service_description?: string;
  area_id?: string;
  slug?: string;
  visibility: "public" | "private";
  is_featured: boolean;
  languages_supported: string[];
  tags: string[];
  image_gallery: MediaImage[];
  video_urls: string[];
  virtual_tours: string[];
  base_price?: number;
  currency_code: string;
  pricing_model: "per_person" | "per_booking";
  price_options: PriceOption[];
  cancellation_policy: CancellationPolicyTier[];
  addons: AddonItem[];
  room_types: RoomType[];
  booking_settings: BookingSettings;
  seo: SeoConfig;
}

/* ================= Steps ================= */
export const Step = {
  TYPE: 0,
  GENERAL: 1,
  MEDIA: 2,
  PRICING: 3,
  ROOMS: 4,
  POLICIES: 5,
  SEO: 6,
  CONFIRM: 7,
} as const;
export type Step = (typeof Step)[keyof typeof Step];

/* ================= Style tokens (đồng bộ Create) ================= */
const baseInput =
  "border theme-border rounded px-3 py-2 bg-white dark:bg-dark-card theme-text-primary focus-ring-primary text-body2-mobile sm:text-body2-tablet lg:text-body2-desktop placeholder:theme-text-secondary";
const baseTextarea =
  "border theme-border rounded px-3 py-2 bg-white dark:bg-dark-card theme-text-primary focus-ring-primary resize-y text-body2-mobile sm:text-body2-tablet lg:text-body2-desktop placeholder:theme-text-secondary";
const baseChipInputWrapper =
  "border theme-border rounded px-2 py-1 flex flex-wrap gap-1 bg-white dark:bg-dark-card focus-within:ring-2 ring-light-focus dark:ring-dark-focus";
const baseCard =
  "theme-bg-card border theme-border rounded-lg p-4 shadow-sm flex flex-col gap-3";
const subtleText =
  "theme-text-secondary text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop";
const sectionTitle =
  "font-semibold theme-text-primary text-h3-mobile sm:text-h3-tablet lg:text-h3-desktop";
const pageTitle =
  "font-bold theme-text-primary text-h1-mobile sm:text-h1-tablet lg:text-h1-desktop";
const sectionSubtitle =
  "theme-text-secondary text-body2-mobile sm:text-body2-tablet lg:text-body2-desktop";
const labelCls =
  "font-medium theme-text-primary text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop";
const errorText =
  "theme-text-error text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop";

/* ================= Helpers ================= */
function slugify(v: string) {
  return v
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "")
    .slice(0, 60);
}

/* ---------- Mock loader for existing listing ---------- */
function loadExisting(_listingId: string | undefined): HotelDraft {
  return {
    status: "draft",
    title: "Khách sạn Mẫu",
    short_description: "Khách sạn mẫu đã tồn tại.",
    service_description: "Mô tả chi tiết về khách sạn (mock).",
    area_id: "hn",
    slug: "khach-san-mau",
    visibility: "public",
    is_featured: true,
    languages_supported: ["vi", "en"],
    tags: ["bien", "sang-trong"],
    image_gallery: [
      {
        id: "img-1",
        url: "https://picsum.photos/seed/exist-1/640/420",
        is_thumbnail: true,
      },
      {
        id: "img-2",
        url: "https://picsum.photos/seed/exist-2/640/420",
      },
    ],
    video_urls: [],
    virtual_tours: [],
    base_price: 1500000,
    currency_code: "VND",
    pricing_model: "per_booking",
    price_options: [
      {
        id: "opt-1",
        option_name: "Deluxe",
        price: 1800000,
        currency_code: "VND",
        per_person: false,
        includes_json: [],
        is_addon: false,
        description: "Phòng Deluxe hướng biển",
      },
    ],
    cancellation_policy: [
      {
        id: "pol-1",
        from_days: 30,
        to_days: 9999,
        refund_percent: 100,
        penalty_description: "Hoàn tiền đầy đủ trước 30 ngày",
      },
    ],
    addons: [
      {
        id: "ad-1",
        name: "Bữa sáng",
        price: 100000,
        currency_code: "VND",
        per_person: false,
        available_all_dates: true,
        description: "Buffet sáng",
      },
    ],
    room_types: [
      {
        id: "room-1",
        name: "Phòng Deluxe",
        capacity: 2,
        quantity_total: 8,
        notes: "Hướng biển",
      },
    ],
    booking_settings: {
      auto_accept: true,
      cancellation_requires_admin_approval: false,
      require_passport_scan: false,
      terms_text: "Khách mang theo CMND/CCCD.",
    },
    seo: {
      visibility: "public",
      publish_now: false,
      seo_title: "SEO Khách sạn Mẫu",
      seo_description: "Mô tả SEO mẫu",
      seo_keywords: ["khach-san", "mau"],
    },
  };
}

/* ================= Component ================= */
const HotelEditPage: React.FC = () => {
  const { listingId } = useParams<{ listingId: string }>();
  const [step, setStep] = useState<Step>(Step.TYPE);
  const [maxVisited, setMaxVisited] = useState<Step>(Step.TYPE);
  const [saving, setSaving] = useState(false);
  const [draft, setDraft] = useState<HotelDraft>(() => loadExisting(listingId));
  const [errors, setErrors] = useState<Record<string, string>>({});

  const stepsMeta = useMemo(
    () => [
      { key: Step.TYPE, label: "Loại dịch vụ" },
      { key: Step.GENERAL, label: "Tổng quan" },
      { key: Step.MEDIA, label: "Thư viện" },
      { key: Step.PRICING, label: "Giá" },
      { key: Step.ROOMS, label: "Phòng" },
      { key: Step.POLICIES, label: "Chính sách" },
      { key: Step.SEO, label: "SEO & Xuất bản" },
      { key: Step.CONFIRM, label: "Hoàn tất" },
    ],
    []
  );

  const goStep = (s: Step) => {
    if (s <= maxVisited) setStep(s);
  };
  const update = (patch: Partial<HotelDraft>) => {
    setDraft((d) => ({ ...d, ...patch }));
    setErrors({});
  };

  /* ===== Validation (giữ tối giản như trước) ===== */
  const validateCurrent = (): boolean => {
    const e: Record<string, string> = {};
    if (step === Step.GENERAL) {
      if (!draft.title) e.title = "Bắt buộc";
      if (!draft.short_description) e.short_description = "Bắt buộc";
      if (!draft.service_description) e.service_description = "Bắt buộc";
      if (!draft.area_id) e.area_id = "Bắt buộc";
    }
    if (step === Step.MEDIA && !draft.image_gallery.length)
      e.image_gallery = "Cần ít nhất 1 hình ảnh.";
    if (step === Step.PRICING && (!draft.base_price || draft.base_price <= 0))
      e.base_price = "Giá cơ bản phải > 0";
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const next = () => {
    if (!validateCurrent()) return;
    setStep((s) => {
      const n = (s + 1) as Step;
      if (n > maxVisited) setMaxVisited(n);
      return n;
    });
  };
  const prev = () => setStep((s) => (s > 0 ? ((s - 1) as Step) : s));

  const saveDraft = () => {
    setSaving(true);
    setTimeout(() => {
      console.log("MOCK UPDATE DRAFT", draft);
      setSaving(false);
      alert("Đã cập nhật bản nháp (mock).");
    }, 600);
  };
  const publish = () => {
    if (
      !draft.title ||
      !draft.short_description ||
      !draft.service_description ||
      draft.image_gallery.length === 0 ||
      !draft.base_price
    ) {
      alert("Thiếu dữ liệu để xuất bản.");
      return;
    }
    setSaving(true);
    setTimeout(() => {
      console.log("MOCK PUBLISH", draft);
      setDraft((d) => ({ ...d, status: "published" }));
      setSaving(false);
      alert("Xuất bản thành công (mock)!");
    }, 800);
  };

  /* ===== Mini Components (đồng bộ styling) ===== */
  const ChipInput: React.FC<{
    value: string[];
    onChange: (v: string[]) => void;
    placeholder?: string;
  }> = ({ value, onChange, placeholder }) => {
    const [txt, setTxt] = useState("");
    const add = () => {
      const v = txt.trim();
      if (!v || value.includes(v)) return;
      onChange([...value, v]);
      setTxt("");
    };
    return (
      <div className={baseChipInputWrapper}>
        {value.map((c) => (
          <span
            key={c}
            className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 bg-light-secondary dark:bg-dark-secondary theme-text-primary text-caption-mobile sm:text-caption-tablet"
          >
            {c}
            <button
              onClick={() => onChange(value.filter((x) => x !== c))}
              className="hover:opacity-70"
            >
              ×
            </button>
          </span>
        ))}
        <input
          value={txt}
          onChange={(e) => setTxt(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") {
              e.preventDefault();
              add();
            } else if (e.key === "Backspace" && !txt && value.length) {
              onChange(value.slice(0, -1));
            }
          }}
          placeholder={placeholder}
          className="outline-none bg-transparent flex-1 min-w-[90px] theme-text-primary text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop placeholder:theme-text-secondary"
        />
      </div>
    );
  };

  const Gallery: React.FC = () => {
    const setGallery = (imgs: MediaImage[]) => update({ image_gallery: imgs });
    const setThumb = (id: string) =>
      setGallery(
        draft.image_gallery.map((i) => ({ ...i, is_thumbnail: i.id === id }))
      );
    const remove = (id: string) =>
      setGallery(draft.image_gallery.filter((i) => i.id !== id));
    const add = () => {
      const img: MediaImage = {
        id: Date.now().toString(),
        url: `https://picsum.photos/seed/edit-${Date.now()}/640/420`,
        is_thumbnail: draft.image_gallery.length === 0,
      };
      setGallery([...draft.image_gallery, img]);
    };
    return (
      <div className="flex flex-col gap-3">
        <div
          onClick={add}
          className="border-2 theme-border border-dashed rounded p-6 flex flex-col items-center gap-2 cursor-pointer theme-text-secondary hover:theme-bg-secondary text-body2-mobile sm:text-body2-tablet"
        >
          <Upload className="w-5 h-5 icon-brand" />
          Thêm hình ảnh (mock)
        </div>
        {errors.image_gallery && (
          <div className={errorText}>{errors.image_gallery}</div>
        )}
        <div className="grid gap-3 grid-cols-2 sm:grid-cols-3 md:grid-cols-4">
          {draft.image_gallery.map((img) => (
            <div
              key={img.id}
              className="relative group border theme-border rounded overflow-hidden bg-light-card dark:bg-dark-card"
            >
              <img
                src={img.url}
                alt=""
                className="object-cover w-full h-28"
                loading="lazy"
              />
              <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition flex flex-col justify-between bg-black/40 p-1">
                <div className="flex justify-end gap-1">
                  <button
                    onClick={() => remove(img.id)}
                    className="p-1 bg-white/90 rounded hover:opacity-80"
                  >
                    <Trash2 className="w-3 h-3 theme-text-error" />
                  </button>
                </div>
                <div>
                  <button
                    onClick={() => setThumb(img.id)}
                    className={[
                      "flex items-center gap-1 px-2 py-0.5 rounded text-caption-mobile font-medium",
                      img.is_thumbnail
                        ? "bg-light-success text-white"
                        : "bg-white/90 hover:bg-white",
                    ].join(" ")}
                  >
                    <Star
                      className={`w-3 h-3 ${
                        img.is_thumbnail ? "fill-white" : "text-light-warning"
                      }`}
                    />
                    {img.is_thumbnail ? "Ảnh đại diện" : "Đặt làm đại diện"}
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  };

  /* ===== Auto slug ===== */
  const handleTitleChange = (v: string) => {
    const patch: Partial<HotelDraft> = { title: v };
    if (!draft.slug) patch.slug = slugify(v);
    update(patch);
  };

  /* ===== Step Content ===== */
  const renderStep = useCallback(() => {
    switch (step) {
      case Step.TYPE:
        return (
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-2">
              <h2 className={sectionTitle}>Chỉnh sửa loại dịch vụ</h2>
              <p className={sectionSubtitle}>
                Bạn đang chỉnh sửa một listing kiểu Khách sạn.
              </p>
            </div>
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
              <div className="border-2 border-light-primary dark:border-dark-primary rounded-lg p-5 bg-light-secondary dark:bg-dark-secondary flex flex-col gap-4">
                <div className="flex items-center gap-3">
                  <Building2 className="w-6 h-6 icon-brand" />
                  <h3 className="font-semibold theme-text-primary text-h5-mobile sm:text-h5-tablet lg:text-h5-desktop">
                    Khách sạn
                  </h3>
                </div>
                <ul className="list-disc ml-5 space-y-1 theme-text-secondary text-caption-mobile sm:text-caption-tablet">
                  <li>Nhiều loại phòng</li>
                  <li>Tùy chọn giá</li>
                  <li>SEO & Xuất bản</li>
                </ul>
                <div className="mt-auto">
                  <button
                    onClick={next}
                    className="btn-primary btn-text-responsive px-6 py-3"
                  >
                    Tiếp tục
                  </button>
                </div>
              </div>
            </div>
          </div>
        );
      case Step.GENERAL:
        return (
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-2">
              <h2 className={sectionTitle}>Thông tin tổng quan</h2>
              <p className={sectionSubtitle}>
                Cập nhật mô tả cơ bản của khách sạn.
              </p>
            </div>
            <div className="grid md:grid-cols-2 gap-6">
              <div className="flex flex-col gap-2">
                <label className={labelCls}>
                  Tiêu đề <span className="theme-text-error">*</span>
                </label>
                <input
                  value={draft.title || ""}
                  onChange={(e) => handleTitleChange(e.target.value)}
                  className={baseInput}
                  placeholder="VD: Khách sạn Biển Xanh"
                />
                {errors.title && (
                  <span className={errorText}>{errors.title}</span>
                )}
              </div>
              <div className="flex flex-col gap-2">
                <label className={labelCls}>
                  Mô tả ngắn <span className="theme-text-error">*</span>
                </label>
                <input
                  value={draft.short_description || ""}
                  onChange={(e) =>
                    update({ short_description: e.target.value })
                  }
                  className={baseInput}
                  maxLength={255}
                  placeholder="Tóm tắt ngắn..."
                />
                {errors.short_description && (
                  <span className={errorText}>{errors.short_description}</span>
                )}
              </div>
              <div className="flex flex-col gap-2 md:col-span-2">
                <label className={labelCls}>
                  Mô tả chi tiết <span className="theme-text-error">*</span>
                </label>
                <textarea
                  value={draft.service_description || ""}
                  onChange={(e) =>
                    update({ service_description: e.target.value })
                  }
                  rows={6}
                  className={baseTextarea}
                  placeholder="Mô tả chi tiết..."
                />
                {errors.service_description && (
                  <span className={errorText}>
                    {errors.service_description}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-2">
                <label className={labelCls}>
                  Khu vực <span className="theme-text-error">*</span>
                </label>
                <select
                  value={draft.area_id || ""}
                  onChange={(e) => update({ area_id: e.target.value })}
                  className={baseInput}
                >
                  <option value="">-- Chọn --</option>
                  <option value="hn">Hà Nội</option>
                  <option value="hcm">TP. Hồ Chí Minh</option>
                  <option value="dn">Đà Nẵng</option>
                  <option value="qn">Quảng Ninh</option>
                  <option value="th">Thanh Hoá</option>
                </select>
                {errors.area_id && (
                  <span className={errorText}>{errors.area_id}</span>
                )}
              </div>
              <div className="flex flex-col gap-2">
                <label className={labelCls}>Slug</label>
                <input
                  value={draft.slug || ""}
                  onChange={(e) => update({ slug: e.target.value })}
                  className={baseInput}
                  placeholder="slug-tu-dong"
                />
                <span className={subtleText}>
                  Có thể tuỳ chỉnh nếu cần SEO tốt hơn.
                </span>
              </div>
              <div className="flex flex-col gap-2">
                <label className={labelCls}>Hiển thị</label>
                <select
                  value={draft.visibility}
                  onChange={(e) =>
                    update({
                      visibility: e.target.value as "public" | "private",
                    })
                  }
                  className={baseInput}
                >
                  <option value="public">Công khai</option>
                  <option value="private">Riêng tư</option>
                </select>
              </div>
              <div className="flex items-center gap-3 mt-8">
                <input
                  id="featured"
                  type="checkbox"
                  checked={draft.is_featured}
                  onChange={(e) => update({ is_featured: e.target.checked })}
                />
                <label
                  htmlFor="featured"
                  className="theme-text-primary text-body2-mobile sm:text-body2-tablet"
                >
                  Nổi bật
                </label>
              </div>
              <div className="flex flex-col gap-2 md:col-span-2">
                <label className={labelCls}>Ngôn ngữ hỗ trợ</label>
                <ChipInput
                  value={draft.languages_supported}
                  onChange={(v) => update({ languages_supported: v })}
                  placeholder="Nhập ngôn ngữ (Enter)"
                />
              </div>
              <div className="flex flex-col gap-2 md:col-span-2">
                <label className={labelCls}>Thẻ (Tags)</label>
                <ChipInput
                  value={draft.tags}
                  onChange={(v) => update({ tags: v })}
                  placeholder="Nhập thẻ (Enter)"
                />
              </div>
            </div>
          </div>
        );
      case Step.MEDIA:
        return (
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-2">
              <h2 className={sectionTitle}>Thư viện</h2>
              <p className={sectionSubtitle}>
                Quản lý hình ảnh hiện có của listing.
              </p>
            </div>
            <Gallery />
          </div>
        );
      case Step.PRICING:
        return (
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-2">
              <h2 className={sectionTitle}>Giá</h2>
              <p className={sectionSubtitle}>
                Cập nhật giá cơ bản (các tuỳ chọn giá chi tiết giữ nguyên trong
                bản demo Edit rút gọn).
              </p>
            </div>
            <div className="grid md:grid-cols-3 gap-6">
              <div className="flex flex-col gap-2">
                <label className={labelCls}>
                  Giá cơ bản (VND) <span className="theme-text-error">*</span>
                </label>
                <input
                  type="number"
                  value={draft.base_price || ""}
                  onChange={(e) =>
                    update({
                      base_price: e.target.value
                        ? Number(e.target.value)
                        : undefined,
                    })
                  }
                  className={baseInput}
                  placeholder="0"
                />
                {errors.base_price && (
                  <span className={errorText}>{errors.base_price}</span>
                )}
              </div>
              <div className="flex flex-col gap-2">
                <label className={labelCls}>Đơn vị tiền tệ</label>
                <select
                  value={draft.currency_code}
                  onChange={(e) => update({ currency_code: e.target.value })}
                  className={baseInput}
                >
                  <option value="VND">VND</option>
                  <option value="USD">USD</option>
                </select>
              </div>
              <div className="flex flex-col gap-2">
                <label className={labelCls}>Mô hình giá</label>
                <select
                  value={draft.pricing_model}
                  onChange={(e) =>
                    update({
                      pricing_model: e.target.value as
                        | "per_person"
                        | "per_booking",
                    })
                  }
                  className={baseInput}
                >
                  <option value="per_booking">Theo đặt phòng</option>
                  <option value="per_person">Theo khách</option>
                </select>
              </div>
            </div>
            <div className={subtleText}>
              (Mock) Số tuỳ chọn giá hiện có: {draft.price_options.length}
            </div>
          </div>
        );
      case Step.ROOMS:
        return (
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-2">
              <h2 className={sectionTitle}>Phòng</h2>
              <p className={sectionSubtitle}>
                Danh sách loại phòng (demo chỉ xem, không sửa).
              </p>
            </div>
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {draft.room_types.map((r) => (
                <div key={r.id} className={baseCard + " !p-4"}>
                  <div className="font-semibold text-body2-mobile sm:text-body2-tablet theme-text-primary">
                    {r.name}
                  </div>
                  <div
                    className={subtleText.replace(
                      "text-caption",
                      "text-caption"
                    )}
                  >
                    Sức chứa: {r.capacity}
                  </div>
                  <div
                    className={subtleText.replace(
                      "text-caption",
                      "text-caption"
                    )}
                  >
                    Số lượng: {r.quantity_total}
                  </div>
                  {r.notes && (
                    <div className="theme-text-secondary text-caption-mobile sm:text-caption-tablet">
                      {r.notes}
                    </div>
                  )}
                </div>
              ))}
            </div>
            <div className={subtleText}>
              (Rút gọn) Chức năng sửa chi tiết phòng giống trang Create có thể
              bổ sung sau.
            </div>
          </div>
        );
      case Step.POLICIES:
        return (
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-2">
              <h2 className={sectionTitle}>Chính sách & Add-ons</h2>
              <p className={sectionSubtitle}>
                Hiển thị tóm tắt mốc huỷ & dịch vụ bổ sung.
              </p>
            </div>
            <div className="grid md:grid-cols-2 gap-6">
              <div className={baseCard}>
                <h3 className="font-semibold text-h5-mobile sm:text-h5-tablet lg:text-h5-desktop">
                  Chính sách huỷ
                </h3>
                <div className="flex flex-col gap-1 text-body2-mobile sm:text-body2-tablet">
                  {draft.cancellation_policy.map((t) => (
                    <div key={t.id}>
                      Từ {t.from_days} đến {t.to_days} ngày:{" "}
                      {t.refund_percent ?? 0}% hoàn
                    </div>
                  ))}
                  {draft.cancellation_policy.length === 0 && (
                    <div className={subtleText}>Chưa có mốc.</div>
                  )}
                </div>
              </div>
              <div className={baseCard}>
                <h3 className="font-semibold text-h5-mobile sm:text-h5-tablet lg:text-h5-desktop">
                  Add-ons
                </h3>
                <div className="flex flex-col gap-1 text-body2-mobile sm:text-body2-tablet">
                  {draft.addons.map((a) => (
                    <div key={a.id}>
                      {a.name}: {a.price.toLocaleString("vi-VN")}{" "}
                      {a.currency_code}
                    </div>
                  ))}
                  {draft.addons.length === 0 && (
                    <div className={subtleText}>Chưa có addon.</div>
                  )}
                </div>
              </div>
            </div>
          </div>
        );
      case Step.SEO:
        return (
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-2">
              <h2 className={sectionTitle}>SEO & Xuất bản</h2>
              <p className={sectionSubtitle}>
                Cập nhật thông tin SEO cơ bản (demo rút gọn).
              </p>
            </div>
            <div className="grid md:grid-cols-2 gap-6">
              <div className="flex flex-col gap-2">
                <label className={labelCls}>Tiêu đề SEO</label>
                <input
                  value={draft.seo.seo_title || ""}
                  onChange={(e) =>
                    update({ seo: { ...draft.seo, seo_title: e.target.value } })
                  }
                  className={baseInput}
                  maxLength={255}
                  placeholder="Tiêu đề SEO..."
                />
              </div>
              <div className="flex flex-col gap-2 md:col-span-2">
                <label className={labelCls}>Mô tả Meta</label>
                <textarea
                  value={draft.seo.seo_description || ""}
                  onChange={(e) =>
                    update({
                      seo: { ...draft.seo, seo_description: e.target.value },
                    })
                  }
                  rows={3}
                  className={baseTextarea}
                  placeholder="Mô tả ngắn cho công cụ tìm kiếm..."
                />
              </div>
            </div>
          </div>
        );
      case Step.CONFIRM:
        return (
          <div className="flex flex-col gap-8">
            <h2 className={sectionTitle}>
              Hoàn tất – {draft.status === "published" ? "ĐÃ XUẤT BẢN" : "NHÁP"}
            </h2>
            <div className="grid sm:grid-cols-2 gap-6 text-body2-mobile sm:text-body2-tablet theme-text-primary">
              <div className={baseCard}>
                <h3 className="font-semibold text-h5-mobile sm:text-h5-tablet lg:text-h5-desktop">
                  Tóm tắt
                </h3>
                <div className="flex flex-col gap-1">
                  <div>
                    <strong>Tiêu đề:</strong> {draft.title || "(trống)"}
                  </div>
                  <div>
                    <strong>Slug:</strong> {draft.slug || "(tự sinh)"}
                  </div>
                  <div>
                    <strong>Số ảnh:</strong> {draft.image_gallery.length}
                  </div>
                  <div>
                    <strong>Loại phòng:</strong> {draft.room_types.length}
                  </div>
                  <div>
                    <strong>Tuỳ chọn giá:</strong> {draft.price_options.length}
                  </div>
                  <div>
                    <strong>Giá cơ bản:</strong>{" "}
                    {draft.base_price?.toLocaleString("vi-VN")}
                  </div>
                </div>
              </div>
              <div className={baseCard}>
                <h3 className="font-semibold text-h5-mobile sm:text-h5-tablet lg:text-h5-desktop">
                  Gợi ý tiếp theo
                </h3>
                <ul className="list-disc ml-5 space-y-1">
                  <li className="text-caption-mobile sm:text-caption-tablet">
                    Bổ sung rich content nếu cần.
                  </li>
                  <li className="text-caption-mobile sm:text-caption-tablet">
                    Kiểm tra chính sách huỷ & add-ons.
                  </li>
                  <li className="text-caption-mobile sm:text-caption-tablet">
                    Đồng bộ API khi backend sẵn sàng.
                  </li>
                </ul>
              </div>
            </div>
            <div className={subtleText}>
              Bạn có thể quay lại các bước trước để chỉnh sửa trước khi xuất
              bản.
            </div>
          </div>
        );
      default:
        return null;
    }
  }, [step, draft, errors]);

  const finalStep = step === Step.CONFIRM;

  return (
    <div className="max-w-7xl mx-auto px-6 py-8 flex flex-col gap-8 theme-text-primary">
      <h1 className={pageTitle}>Chỉnh sửa khách sạn #{listingId || "—"}</h1>

      {/* Stepper */}
      <div className="flex flex-col gap-4">
        <div className="flex overflow-x-auto gap-3 no-scrollbar pb-1">
          {stepsMeta.map((s, i) => {
            const active = s.key === step;
            const visited = s.key <= maxVisited;
            return (
              <button
                key={s.key}
                disabled={!visited}
                onClick={() => goStep(s.key)}
                className={[
                  "flex items-center gap-2 px-4 py-2 rounded-full border theme-border text-caption-mobile sm:text-caption-tablet font-medium shrink-0 transition-colors",
                  active
                    ? "bg-light-primary dark:bg-dark-primary text-light-buttonText dark:text-dark-buttonText"
                    : visited
                    ? "theme-bg-card hover:bg-light-secondary dark:hover:bg-dark-secondary"
                    : "opacity-50 cursor-not-allowed",
                ].join(" ")}
              >
                <span
                  className={[
                    "w-6 h-6 rounded-full border flex items-center justify-center font-semibold",
                    active ? "border-white" : "theme-border theme-text-primary",
                  ].join(" ")}
                >
                  {i + 1}
                </span>
                {s.label}
              </button>
            );
          })}
        </div>
        <div className="h-2 rounded bg-light-secondary dark:bg-dark-secondary">
          <div
            className="h-full bg-light-primary dark:bg-dark-primary rounded transition-all"
            style={{
              width: `${
                ((step - stepsMeta[0].key) /
                  (stepsMeta[stepsMeta.length - 1].key - stepsMeta[0].key ||
                    1)) *
                100
              }%`,
            }}
          />
        </div>
      </div>

      {/* Content */}
      <div className="border theme-border rounded-xl p-6 theme-bg-card shadow-sm">
        {renderStep()}
      </div>

      {/* Actions */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex gap-3 flex-wrap">
          {step > Step.TYPE && (
            <button
              onClick={prev}
              className="btn-outline btn-text-responsive px-6 py-3 flex items-center gap-2"
            >
              <ChevronLeft className="w-4 h-4" />
              Quay lại
            </button>
          )}
          <button
            onClick={saveDraft}
            disabled={saving}
            className="btn-secondary btn-text-responsive px-6 py-3 disabled:opacity-60 flex items-center gap-2"
          >
            {saving && <Loader2 className="w-4 h-4 animate-spin" />}
            Cập nhật nháp
          </button>
        </div>
        <div className="flex gap-3 flex-wrap">
          {finalStep && (
            <button
              onClick={publish}
              disabled={saving}
              className="btn-primary btn-text-responsive px-6 py-3 flex items-center gap-2 disabled:opacity-60"
            >
              {saving && <Loader2 className="w-4 h-4 animate-spin" />}
              Xuất bản
            </button>
          )}
          {!finalStep && (
            <button
              onClick={next}
              disabled={saving}
              className="btn-primary btn-text-responsive px-6 py-3 flex items-center gap-2 disabled:opacity-60"
            >
              {saving ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                <ChevronRight className="w-4 h-4" />
              )}
              Tiếp theo
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default HotelEditPage;
