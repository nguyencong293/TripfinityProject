import React, { useState, useMemo, useCallback } from "react";
import {
  ChevronLeft,
  ChevronRight,
  Loader2,
  Upload,
  Star,
  Trash2,
  Plus,
  Building2,
} from "lucide-react";

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

/* ================ Initial draft ================ */
const initialDraft: HotelDraft = {
  status: "draft",
  visibility: "public",
  is_featured: false,
  languages_supported: [],
  tags: [],
  image_gallery: [],
  video_urls: [],
  virtual_tours: [],
  currency_code: "VND",
  pricing_model: "per_booking",
  price_options: [],
  cancellation_policy: [],
  addons: [],
  room_types: [],
  booking_settings: {
    auto_accept: false,
    cancellation_requires_admin_approval: false,
  },
  seo: {
    visibility: "public",
    publish_now: false,
  },
};

/* ================= Helpers ================= */
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
const smallHelper =
  "theme-text-secondary text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop";

const randomImg = () =>
  `https://picsum.photos/seed/hotel-${Math.floor(
    Math.random() * 9999
  )}/320/220`;

function slugify(v: string) {
  return v
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "")
    .slice(0, 60);
}

/* ================= Component ================= */
const HotelCreatePage: React.FC = () => {
  const [step, setStep] = useState<Step>(Step.TYPE);
  const [maxVisited, setMaxVisited] = useState<Step>(Step.TYPE);
  const [saving, setSaving] = useState(false);
  const [draft, setDraft] = useState<HotelDraft>(initialDraft);
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

  /* ===== Validation ===== */
  const validateCurrent = (): boolean => {
    const e: Record<string, string> = {};
    if (step === Step.GENERAL) {
      if (!draft.title) e.title = "Bắt buộc";
      if (!draft.short_description) e.short_description = "Bắt buộc";
      if (!draft.service_description) e.service_description = "Bắt buộc";
      if (!draft.area_id) e.area_id = "Bắt buộc";
    }
    if (step === Step.MEDIA) {
      if (draft.image_gallery.length === 0)
        e.image_gallery = "Cần ít nhất 1 hình ảnh.";
    }
    if (step === Step.PRICING) {
      if (!draft.base_price || draft.base_price <= 0)
        e.base_price = "Giá cơ bản phải > 0";
    }
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
      console.log("MOCK LƯU NHÁP", draft);
      setSaving(false);
    }, 500);
  };

  const publish = () => {
    if (
      !draft.title ||
      !draft.short_description ||
      !draft.service_description ||
      draft.image_gallery.length === 0 ||
      !draft.base_price
    ) {
      alert("Chưa đủ dữ liệu để xuất bản (mock).");
      return;
    }
    setSaving(true);
    setTimeout(() => {
      console.log("MOCK PUBLISH", draft);
      setDraft((d) => ({
        ...d,
        status: "published",
        seo: { ...d.seo, publish_now: true },
      }));
      setSaving(false);
      alert("Đã xuất bản (mock)!");
    }, 800);
  };

  /* ====== Mini Components ====== */
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
    const setGallery = (imgs: MediaImage[]) =>
      update({ image_gallery: imgs.slice() });
    const setThumb = (id: string) =>
      setGallery(
        draft.image_gallery.map((i) => ({ ...i, is_thumbnail: i.id === id }))
      );
    const remove = (id: string) =>
      setGallery(draft.image_gallery.filter((i) => i.id !== id));
    const add = () => {
      const img: MediaImage = {
        id: Date.now().toString(),
        url: randomImg(),
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

  const PriceOptionsEditor: React.FC = () => {
    const addOpt = () => {
      const o: PriceOption = {
        id: Date.now().toString(),
        option_name: "Mặc định",
        price: draft.base_price || 0,
        currency_code: draft.currency_code,
        per_person: false,
        includes_json: [],
        is_addon: false,
      };
      update({ price_options: [...draft.price_options, o] });
    };
    const updateOpt = (id: string, patch: Partial<PriceOption>) =>
      update({
        price_options: draft.price_options.map((o) =>
          o.id === id ? { ...o, ...patch } : o
        ),
      });
    const remove = (id: string) =>
      update({
        price_options: draft.price_options.filter((o) => o.id !== id),
      });
    return (
      <div className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <h3
            className={
              sectionTitle +
              " !text-h5-mobile sm:!text-h5-tablet lg:!text-h5-desktop"
            }
          >
            Tuỳ chọn giá
          </h3>
          <button
            onClick={addOpt}
            className="btn-primary btn-text-responsive px-4 py-2"
          >
            <span className="inline-flex items-center gap-1">
              <Plus className="w-4 h-4" /> Thêm
            </span>
          </button>
        </div>
        {draft.price_options.length === 0 && (
          <div className={subtleText}>Chưa có tuỳ chọn.</div>
        )}
        <div className="flex flex-col gap-3">
          {draft.price_options.map((o) => (
            <div
              key={o.id}
              className="border theme-border rounded p-3 theme-bg-card flex flex-col gap-2"
            >
              <div className="flex flex-wrap gap-2">
                <input
                  value={o.option_name}
                  onChange={(e) =>
                    updateOpt(o.id, { option_name: e.target.value })
                  }
                  className={baseInput + " flex-1 min-w-[160px]"}
                  placeholder="Tên option"
                />
                <input
                  type="number"
                  value={o.price}
                  onChange={(e) => updateOpt(o.id, { price: +e.target.value })}
                  className={baseInput + " w-32"}
                  placeholder="Giá"
                />
                <label className="flex items-center gap-2 theme-text-primary text-body2-mobile sm:text-body2-tablet">
                  <input
                    type="checkbox"
                    checked={o.per_person}
                    onChange={(e) =>
                      updateOpt(o.id, { per_person: e.target.checked })
                    }
                  />
                  Tính theo người
                </label>
                <button
                  onClick={() => remove(o.id)}
                  className="px-2 py-2 rounded hover:bg-light-secondary dark:hover:bg-dark-secondary"
                  title="Xoá"
                >
                  <Trash2 className="w-4 h-4 theme-text-error" />
                </button>
              </div>
              <textarea
                value={o.description || ""}
                onChange={(e) =>
                  updateOpt(o.id, { description: e.target.value })
                }
                rows={2}
                className={baseTextarea}
                placeholder="Mô tả (tuỳ chọn)"
              />
            </div>
          ))}
        </div>
      </div>
    );
  };

  const RoomTypesEditor: React.FC = () => {
    const addRoom = () => {
      const r: RoomType = {
        id: Date.now().toString(),
        name: "Phòng Tiêu Chuẩn",
        capacity: 2,
        quantity_total: 10,
      };
      update({ room_types: [...draft.room_types, r] });
    };
    const upd = (id: string, patch: Partial<RoomType>) =>
      update({
        room_types: draft.room_types.map((r) =>
          r.id === id ? { ...r, ...patch } : r
        ),
      });
    const remove = (id: string) =>
      update({
        room_types: draft.room_types.filter((r) => r.id !== id),
      });
    return (
      <div className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <h3
            className={
              sectionTitle +
              " !text-h5-mobile sm:!text-h5-tablet lg:!text-h5-desktop"
            }
          >
            Loại phòng
          </h3>
          <button
            onClick={addRoom}
            className="btn-primary btn-text-responsive px-4 py-2"
          >
            <span className="inline-flex items-center gap-1">
              <Plus className="w-4 h-4" /> Thêm
            </span>
          </button>
        </div>
        {draft.room_types.length === 0 && (
          <div className={subtleText}>Chưa có loại phòng.</div>
        )}
        <div className="flex flex-col gap-3">
          {draft.room_types.map((r) => (
            <div
              key={r.id}
              className="border theme-border rounded p-3 theme-bg-card flex flex-col gap-2"
            >
              <div className="flex flex-wrap gap-2">
                <input
                  value={r.name}
                  onChange={(e) => upd(r.id, { name: e.target.value })}
                  className={baseInput + " flex-1 min-w-[180px]"}
                  placeholder="Tên phòng"
                />
                <input
                  type="number"
                  value={r.capacity}
                  onChange={(e) => upd(r.id, { capacity: +e.target.value })}
                  className={baseInput + " w-28"}
                  placeholder="Số khách"
                />
                <input
                  type="number"
                  value={r.quantity_total}
                  onChange={(e) =>
                    upd(r.id, { quantity_total: +e.target.value })
                  }
                  className={baseInput + " w-32"}
                  placeholder="Số lượng"
                />
                <button
                  onClick={() => remove(r.id)}
                  className="px-2 py-2 rounded hover:bg-light-secondary dark:hover:bg-dark-secondary"
                  title="Xoá"
                >
                  <Trash2 className="w-4 h-4 theme-text-error" />
                </button>
              </div>
              <textarea
                value={r.notes || ""}
                onChange={(e) => upd(r.id, { notes: e.target.value })}
                rows={2}
                className={baseTextarea}
                placeholder="Ghi chú"
              />
            </div>
          ))}
        </div>
        <div className={subtleText}>
          Quản lý tồn kho theo lịch chi tiết sẽ được bổ sung sau.
        </div>
      </div>
    );
  };

  const PoliciesAddons: React.FC = () => {
    const addAddon = () => {
      const a: AddonItem = {
        id: Date.now().toString(),
        name: "Bữa sáng",
        price: 100000,
        currency_code: draft.currency_code,
        per_person: false,
        available_all_dates: true,
      };
      update({ addons: [...draft.addons, a] });
    };
    const updAddon = (id: string, patch: Partial<AddonItem>) =>
      update({
        addons: draft.addons.map((a) => (a.id === id ? { ...a, ...patch } : a)),
      });
    const remove = (id: string) =>
      update({ addons: draft.addons.filter((a) => a.id !== id) });

    const addPolicyTier = () => {
      const t: CancellationPolicyTier = {
        id: Date.now().toString(),
        from_days: 30,
        to_days: 9999,
        refund_percent: 100,
      };
      update({ cancellation_policy: [...draft.cancellation_policy, t] });
    };
    const updTier = (id: string, patch: Partial<CancellationPolicyTier>) =>
      update({
        cancellation_policy: draft.cancellation_policy.map((t) =>
          t.id === id ? { ...t, ...patch } : t
        ),
      });
    const removeTier = (id: string) =>
      update({
        cancellation_policy: draft.cancellation_policy.filter(
          (t) => t.id !== id
        ),
      });

    return (
      <div className="flex flex-col gap-8">
        {/* Cancellation Policy */}
        <div className="flex flex-col gap-3">
          <div className="flex items-center justify-between">
            <h3
              className={
                sectionTitle +
                " !text-h5-mobile sm:!text-h5-tablet lg:!text-h5-desktop"
              }
            >
              Chính sách huỷ
            </h3>
            <button
              onClick={addPolicyTier}
              className="btn-outline btn-text-responsive px-4 py-2"
            >
              <span className="inline-flex items-center gap-1">
                <Plus className="w-4 h-4" /> Thêm mốc
              </span>
            </button>
          </div>
          {draft.cancellation_policy.length === 0 && (
            <div className={subtleText}>Chưa có mốc.</div>
          )}
          <div className="flex flex-col gap-3">
            {draft.cancellation_policy.map((t) => (
              <div
                key={t.id}
                className="border theme-border rounded p-3 theme-bg-card flex flex-col gap-2"
              >
                <div className="flex flex-wrap gap-2">
                  <input
                    type="number"
                    className={baseInput + " w-28"}
                    value={t.from_days}
                    onChange={(e) =>
                      updTier(t.id, { from_days: +e.target.value })
                    }
                    placeholder="Từ ngày"
                  />
                  <input
                    type="number"
                    className={baseInput + " w-28"}
                    value={t.to_days}
                    onChange={(e) =>
                      updTier(t.id, { to_days: +e.target.value })
                    }
                    placeholder="Đến ngày"
                  />
                  <input
                    type="number"
                    className={baseInput + " w-32"}
                    value={t.refund_percent ?? ""}
                    onChange={(e) =>
                      updTier(t.id, { refund_percent: +e.target.value })
                    }
                    placeholder="% hoàn"
                  />
                  <input
                    className={baseInput + " flex-1 min-w-[180px]"}
                    value={t.penalty_description || ""}
                    onChange={(e) =>
                      updTier(t.id, { penalty_description: e.target.value })
                    }
                    placeholder="Mô tả phạt"
                  />
                  <button
                    onClick={() => removeTier(t.id)}
                    className="px-2 py-2 rounded hover:bg-light-secondary dark:hover:bg-dark-secondary"
                    title="Xoá"
                  >
                    <Trash2 className="w-4 h-4 theme-text-error" />
                  </button>
                </div>
                <div className={subtleText}>
                  Tránh khoảng ngày bị chồng lấn (chưa kiểm tra tự động).
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Addons */}
        <div className="flex flex-col gap-3">
          <div className="flex items-center justify-between">
            <h3
              className={
                sectionTitle +
                " !text-h5-mobile sm:!text-h5-tablet lg:!text-h5-desktop"
              }
            >
              Dịch vụ bổ sung (Add-ons)
            </h3>
            <button
              onClick={addAddon}
              className="btn-outline btn-text-responsive px-4 py-2"
            >
              <span className="inline-flex items-center gap-1">
                <Plus className="w-4 h-4" /> Thêm
              </span>
            </button>
          </div>
          {draft.addons.length === 0 && (
            <div className={subtleText}>Chưa có addon.</div>
          )}
          <div className="flex flex-col gap-3">
            {draft.addons.map((a) => (
              <div
                key={a.id}
                className="border theme-border rounded p-3 theme-bg-card flex flex-col gap-2"
              >
                <div className="flex flex-wrap gap-2">
                  <input
                    value={a.name}
                    onChange={(e) => updAddon(a.id, { name: e.target.value })}
                    className={baseInput + " flex-1 min-w-[160px]"}
                    placeholder="Tên dịch vụ"
                  />
                  <input
                    type="number"
                    value={a.price}
                    onChange={(e) => updAddon(a.id, { price: +e.target.value })}
                    className={baseInput + " w-32"}
                    placeholder="Giá"
                  />
                  <label className="flex items-center gap-2 theme-text-primary text-body2-mobile sm:text-body2-tablet">
                    <input
                      type="checkbox"
                      checked={a.per_person}
                      onChange={(e) =>
                        updAddon(a.id, { per_person: e.target.checked })
                      }
                    />
                    Theo khách
                  </label>
                  <button
                    onClick={() => remove(a.id)}
                    className="px-2 py-2 rounded hover:bg-light-secondary dark:hover:bg-dark-secondary"
                    title="Xoá"
                  >
                    <Trash2 className="w-4 h-4 theme-text-error" />
                  </button>
                </div>
                <textarea
                  value={a.description || ""}
                  onChange={(e) =>
                    updAddon(a.id, { description: e.target.value })
                  }
                  rows={2}
                  className={baseTextarea}
                  placeholder="Mô tả (tuỳ chọn)"
                />
              </div>
            ))}
          </div>
        </div>

        {/* Booking Settings */}
        <div className="border theme-border rounded p-4 flex flex-col gap-3 theme-bg-card">
          <h4 className="font-semibold theme-text-primary text-h5-mobile sm:text-h5-tablet lg:text-h5-desktop">
            Cài đặt đặt phòng
          </h4>
          <div className="flex gap-6 flex-wrap text-body2-mobile sm:text-body2-tablet theme-text-primary">
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={draft.booking_settings.auto_accept}
                onChange={(e) =>
                  update({
                    booking_settings: {
                      ...draft.booking_settings,
                      auto_accept: e.target.checked,
                    },
                  })
                }
              />
              Tự động chấp nhận
            </label>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={
                  draft.booking_settings.cancellation_requires_admin_approval
                }
                onChange={(e) =>
                  update({
                    booking_settings: {
                      ...draft.booking_settings,
                      cancellation_requires_admin_approval: e.target.checked,
                    },
                  })
                }
              />
              Huỷ cần duyệt
            </label>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={draft.booking_settings.require_passport_scan || false}
                onChange={(e) =>
                  update({
                    booking_settings: {
                      ...draft.booking_settings,
                      require_passport_scan: e.target.checked,
                    },
                  })
                }
              />
              Yêu cầu quét hộ chiếu
            </label>
          </div>
          <textarea
            value={draft.booking_settings.terms_text || ""}
            onChange={(e) =>
              update({
                booking_settings: {
                  ...draft.booking_settings,
                  terms_text: e.target.value,
                },
              })
            }
            rows={3}
            className={baseTextarea}
            placeholder="Điều khoản & điều kiện..."
          />
        </div>
      </div>
    );
  };

  const SeoPublish: React.FC = () => {
    const setSeo = (patch: Partial<SeoConfig>) =>
      update({ seo: { ...draft.seo, ...patch } });
    return (
      <div className="flex flex-col gap-8">
        <div>
          <h2 className={sectionTitle}>SEO & Xuất bản</h2>
          <p className={sectionSubtitle}>
            Thiết lập thông tin SEO và lịch xuất bản hiển thị.
          </p>
        </div>
        <div className="grid md:grid-cols-2 gap-6">
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Tiêu đề SEO</label>
            <input
              value={draft.seo.seo_title || ""}
              onChange={(e) => setSeo({ seo_title: e.target.value })}
              className={baseInput}
              maxLength={255}
              placeholder="Tiêu đề ngắn gọn hấp dẫn"
            />
          </div>
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>Mô tả Meta</label>
            <textarea
              value={draft.seo.seo_description || ""}
              onChange={(e) => setSeo({ seo_description: e.target.value })}
              rows={3}
              className={baseTextarea}
              placeholder="Mô tả dùng cho công cụ tìm kiếm..."
            />
          </div>
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className={labelCls}>Từ khoá Meta (CSV)</label>
            <input
              value={(draft.seo.seo_keywords || []).join(",")}
              onChange={(e) =>
                setSeo({
                  seo_keywords: e.target.value
                    .split(",")
                    .map((x) => x.trim())
                    .filter(Boolean),
                })
              }
              className={baseInput}
              placeholder="khach-san,nghi-duong,bien"
            />
          </div>
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Chế độ hiển thị</label>
            <select
              value={draft.seo.visibility}
              onChange={(e) =>
                setSeo({ visibility: e.target.value as "public" | "private" })
              }
              className={baseInput}
            >
              <option value="public">Công khai</option>
              <option value="private">Riêng tư</option>
            </select>
          </div>
          <div className="flex flex-col gap-2">
            <label className={labelCls}>Xuất bản ngay?</label>
            <select
              value={draft.seo.publish_now ? "yes" : "no"}
              onChange={(e) =>
                setSeo({ publish_now: e.target.value === "yes" })
              }
              className={baseInput}
            >
              <option value="yes">Có (ngay lập tức)</option>
              <option value="no">Không (Đặt lịch)</option>
            </select>
          </div>
          {!draft.seo.publish_now && (
            <div className="flex flex-col gap-2">
              <label className={labelCls}>Thời điểm xuất bản</label>
              <input
                type="datetime-local"
                value={draft.seo.publish_at || ""}
                onChange={(e) => setSeo({ publish_at: e.target.value })}
                className={baseInput}
              />
            </div>
          )}
        </div>
        <div className="border theme-border rounded p-4 theme-bg-card">
          <h3 className="font-semibold theme-text-primary text-h5-mobile sm:text-h5-tablet lg:text-h5-desktop mb-2">
            Danh sách kiểm tra
          </h3>
          <ul className="list-disc ml-5 space-y-1 text-body2-mobile sm:text-body2-tablet theme-text-primary">
            <li>{draft.title ? "✅" : "❌"} Tiêu đề</li>
            <li>{draft.short_description ? "✅" : "❌"} Mô tả ngắn</li>
            <li>
              {draft.image_gallery.length > 0 ? "✅" : "❌"} Ít nhất 1 hình ảnh
            </li>
            <li>{draft.base_price ? "✅" : "❌"} Giá cơ bản</li>
          </ul>
        </div>
      </div>
    );
  };

  const Confirmation: React.FC = () => (
    <div className="flex flex-col gap-8">
      <h2 className={sectionTitle}>
        Hoàn tất (Mock) –{" "}
        {draft.status === "published" ? "ĐÃ XUẤT BẢN" : "NHÁP"}
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
              <strong>Xuất bản ngay:</strong>{" "}
              {draft.seo.publish_now ? "Có" : "Không"}
            </div>
          </div>
        </div>
        <div className={baseCard}>
          <h3 className="font-semibold text-h5-mobile sm:text-h5-tablet lg:text-h5-desktop">
            Bước tiếp theo
          </h3>
          <ul className="list-disc ml-5 space-y-1">
            <li className="text-caption-mobile sm:text-caption-tablet">
              Bổ sung nội dung mô tả chi tiết hơn.
            </li>
            <li className="text-caption-mobile sm:text-caption-tablet">
              Kiểm tra lại chính sách huỷ & addons.
            </li>
            <li className="text-caption-mobile sm:text-caption-tablet">
              Đồng bộ lên máy chủ khi API sẵn sàng.
            </li>
          </ul>
        </div>
      </div>
      <div className={subtleText}>
        Bạn có thể quay lại các bước trước để chỉnh sửa.
      </div>
    </div>
  );

  /* ===== Auto slug ===== */
  const handleTitleChange = (v: string) => {
    const patch: Partial<HotelDraft> = { title: v };
    if (!draft.slug) patch.slug = slugify(v);
    update(patch);
  };

  /* ===== Step content switch ===== */
  const renderStep = useCallback(() => {
    switch (step) {
      case Step.TYPE:
        return (
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-2">
              <h2 className={sectionTitle}>Chọn loại dịch vụ</h2>
              <p className={sectionSubtitle}>
                Hiện tại chỉ hỗ trợ Khách sạn. (Các loại khác sẽ bổ sung sau)
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
                  <li>Nhiều loại phòng & quản lý tồn kho</li>
                  <li>Nhiều tuỳ chọn giá</li>
                  <li>SEO & lịch xuất bản</li>
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
                Cung cấp mô tả cơ bản về khách sạn của bạn.
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
                  placeholder="Tóm tắt ngắn gọn..."
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
                  placeholder="Mô tả chi tiết (mock rich text)"
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
                <span className={smallHelper}>
                  Tự sinh từ tiêu đề (có thể sửa).
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
                Quản lý hình ảnh, video và virtual tour (mock).
              </p>
            </div>
            <Gallery />
            <div className="grid md:grid-cols-2 gap-6">
              <div className="flex flex-col gap-2">
                <label className={labelCls}>Video URLs (CSV)</label>
                <input
                  value={draft.video_urls.join(",")}
                  onChange={(e) =>
                    update({
                      video_urls: e.target.value
                        .split(",")
                        .map((x) => x.trim())
                        .filter(Boolean),
                    })
                  }
                  className={baseInput}
                  placeholder="https://youtu.be/..."
                />
              </div>
              <div className="flex flex-col gap-2">
                <label className={labelCls}>Virtual Tours (CSV)</label>
                <input
                  value={draft.virtual_tours.join(",")}
                  onChange={(e) =>
                    update({
                      virtual_tours: e.target.value
                        .split(",")
                        .map((x) => x.trim())
                        .filter(Boolean),
                    })
                  }
                  className={baseInput}
                  placeholder="https://example.com/360..."
                />
              </div>
            </div>
          </div>
        );
      case Step.PRICING:
        return (
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-2">
              <h2 className={sectionTitle}>Giá</h2>
              <p className={sectionSubtitle}>
                Thiết lập giá cơ bản và nhiều tuỳ chọn giá.
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
            <PriceOptionsEditor />
          </div>
        );
      case Step.ROOMS:
        return (
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-2">
              <h2 className={sectionTitle}>Phòng</h2>
              <p className={sectionSubtitle}>Quản lý các loại phòng (mock).</p>
            </div>
            <RoomTypesEditor />
          </div>
        );
      case Step.POLICIES:
        return (
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-2">
              <h2 className={sectionTitle}>Chính sách & Add-ons</h2>
              <p className={sectionSubtitle}>
                Thiết lập chính sách huỷ và dịch vụ bổ sung.
              </p>
            </div>
            <PoliciesAddons />
          </div>
        );
      case Step.SEO:
        return <SeoPublish />;
      case Step.CONFIRM:
        return <Confirmation />;
      default:
        return null;
    }
  }, [step, draft, errors]);

  const finalStep = step === Step.CONFIRM;

  return (
    <div className="max-w-7xl mx-auto px-6 py-8 flex flex-col gap-8 theme-text-primary">
      <h1 className={pageTitle}>Tạo listing khách sạn</h1>

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
            Lưu nháp
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

export default HotelCreatePage;
