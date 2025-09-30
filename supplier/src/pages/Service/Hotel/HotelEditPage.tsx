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

/* (Các types giống file Create — nếu muốn DRY thì tách chung) */
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

const smallInput =
  "border rounded px-2 py-1 text-xs focus:ring-1 ring-blue-500 outline-none";
const sectionCard = "border rounded-lg p-4 bg-white shadow-sm";

/* ---------- Mock existing data loader ---------- */
function loadExisting(listingId: string | undefined): HotelDraft {
  // Tạo dữ liệu giả cho chế độ edit
  return {
    status: "draft",
    title: "Sample Existing Hotel",
    short_description: "Khách sạn mẫu đã tồn tại.",
    service_description: "Mô tả chi tiết về khách sạn (mock).",
    area_id: "hn",
    slug: "sample-existing-hotel",
    visibility: "public",
    is_featured: true,
    languages_supported: ["en", "vi"],
    tags: ["beach", "luxury"],
    image_gallery: [
      {
        id: "img-1",
        url: "https://picsum.photos/seed/exist-1/320/220",
        is_thumbnail: true,
      },
      {
        id: "img-2",
        url: "https://picsum.photos/seed/exist-2/320/220",
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
        description: "Deluxe view biển",
      },
    ],
    cancellation_policy: [
      {
        id: "pol-1",
        from_days: 30,
        to_days: 9999,
        refund_percent: 100,
        penalty_description: "Full refund before 30 days",
      },
    ],
    addons: [
      {
        id: "ad-1",
        name: "Breakfast",
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
        name: "Deluxe Room",
        capacity: 2,
        quantity_total: 8,
        notes: "Sea view",
      },
    ],
    booking_settings: {
      auto_accept: true,
      cancellation_requires_admin_approval: false,
      require_passport_scan: false,
      terms_text: "Guests must present valid ID.",
    },
    seo: {
      visibility: "public",
      publish_now: false,
      seo_title: "SEO Title Hotel Sample",
      seo_description: "Meta description sample",
      seo_keywords: ["hotel", "sample"],
    },
  };
}

const HotelEditPage: React.FC = () => {
  const { listingId } = useParams<{ listingId: string }>();
  const [step, setStep] = useState<Step>(Step.TYPE);
  const [maxVisited, setMaxVisited] = useState<Step>(Step.TYPE);
  const [saving, setSaving] = useState(false);
  const [draft, setDraft] = useState<HotelDraft>(() => loadExisting(listingId));
  const [errors, setErrors] = useState<Record<string, string>>({});

  const stepsMeta = useMemo(
    () => [
      { key: Step.TYPE, label: "Type" },
      { key: Step.GENERAL, label: "General" },
      { key: Step.MEDIA, label: "Media" },
      { key: Step.PRICING, label: "Pricing" },
      { key: Step.ROOMS, label: "Rooms" },
      { key: Step.POLICIES, label: "Policies" },
      { key: Step.SEO, label: "SEO & Publish" },
      { key: Step.CONFIRM, label: "Confirmation" },
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

  function slugify(v: string) {
    return v
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/(^-|-$)/g, "")
      .slice(0, 60);
  }

  /* ---- validation ---- */
  const validateCurrent = (): boolean => {
    const e: Record<string, string> = {};
    if (step === Step.GENERAL) {
      if (!draft.title) e.title = "Required";
      if (!draft.short_description) e.short_description = "Required";
      if (!draft.service_description) e.service_description = "Required";
      if (!draft.area_id) e.area_id = "Required";
    }
    if (step === Step.MEDIA) {
      if (!draft.image_gallery.length)
        e.image_gallery = "Need at least 1 image.";
    }
    if (step === Step.PRICING) {
      if (!draft.base_price || draft.base_price <= 0)
        e.base_price = "Base price > 0";
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
      console.log("MOCK UPDATE DRAFT", draft);
      setSaving(false);
      alert("Updated draft (mock).");
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
      alert("Thiếu dữ liệu để publish.");
      return;
    }
    setSaving(true);
    setTimeout(() => {
      console.log("MOCK PUBLISH", draft);
      setDraft((d) => ({ ...d, status: "published" }));
      setSaving(false);
      alert("Published (mock)!");
    }, 800);
  };

  /* --- Small subcomponents (rút gọn, giống create) --- */
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
      <div className="border rounded px-2 py-1 flex flex-wrap gap-1 bg-white focus-within:ring-1 ring-blue-500">
        {value.map((c) => (
          <span
            key={c}
            className="inline-flex items-center gap-1 text-[11px] bg-blue-100 text-blue-700 px-2 py-0.5 rounded"
          >
            {c}
            <button
              onClick={() => onChange(value.filter((x) => x !== c))}
              className="hover:text-red-600"
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
          className="outline-none text-[11px] flex-1 min-w-[90px]"
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
        url: `https://picsum.photos/seed/edit-${Date.now()}/320/220`,
        is_thumbnail: false,
      };
      setGallery([...draft.image_gallery, img]);
    };
    return (
      <div className="flex flex-col gap-3">
        <div
          onClick={add}
          className="border-2 border-dashed rounded p-6 flex flex-col items-center gap-2 text-xs text-gray-500 cursor-pointer hover:bg-gray-50"
        >
          <Upload className="w-5 h-5 text-gray-400" />
          Thêm ảnh (mock)
        </div>
        {errors.image_gallery && (
          <div className="text-[11px] text-red-600">{errors.image_gallery}</div>
        )}
        <div className="grid gap-3 grid-cols-2 sm:grid-cols-3 md:grid-cols-4">
          {draft.image_gallery.map((img) => (
            <div
              key={img.id}
              className="relative group border rounded overflow-hidden bg-gray-100"
            >
              <img
                src={img.url}
                alt=""
                className="object-cover w-full h-28"
                loading="lazy"
              />
              <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition flex flex-col justify-between bg-black/35 p-1">
                <div className="flex justify-end gap-1">
                  <button
                    onClick={() => remove(img.id)}
                    className="p-1 bg-white/80 rounded hover:bg-white"
                  >
                    <Trash2 className="w-3 h-3 text-red-600" />
                  </button>
                </div>
                <div>
                  <button
                    onClick={() => setThumb(img.id)}
                    className={`flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-medium ${
                      img.is_thumbnail
                        ? "bg-yellow-400 text-black"
                        : "bg-white/80 hover:bg-white"
                    }`}
                  >
                    <Star
                      className={`w-3 h-3 ${
                        img.is_thumbnail ? "fill-black" : "text-yellow-500"
                      }`}
                    />
                    {img.is_thumbnail ? "Thumbnail" : "Set thumb"}
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  };

  /* ---- Step rendering (giữ gần giống Create) ---- */
  const handleTitleChange = (v: string) => {
    const patch: Partial<HotelDraft> = { title: v };
    if (!draft.slug) patch.slug = slugify(v);
    update(patch);
  };

  const renderStep = useCallback(() => {
    switch (step) {
      case Step.TYPE:
        return (
          <div className="flex flex-col gap-6">
            <div>
              <h2 className="text-lg font-semibold mb-1">Type</h2>
              <p className="text-xs text-gray-500">Đang chỉnh sửa Hotel.</p>
            </div>
            <div className="border-2 border-blue-500 rounded-lg p-4 bg-blue-50 flex flex-col gap-3 max-w-sm">
              <div className="flex items-center gap-2">
                <Building2 className="w-5 h-5 text-blue-600" />
                <h3 className="font-medium text-sm">Hotel</h3>
              </div>
              <ul className="text-[11px] text-gray-600 list-disc ml-4 space-y-1">
                <li>Room types & inventory</li>
                <li>Price options</li>
                <li>SEO & Publish</li>
              </ul>
              <button
                onClick={next}
                className="mt-2 text-xs bg-blue-600 text-white px-3 py-1.5 rounded hover:bg-blue-700 self-start"
              >
                Tiếp tục
              </button>
            </div>
          </div>
        );
      case Step.GENERAL:
        return (
          <div className="flex flex-col gap-6">
            <div>
              <h2 className="text-lg font-semibold mb-1">General</h2>
              <p className="text-xs text-gray-500">
                Cập nhật thông tin mô tả khách sạn.
              </p>
            </div>
            <div className="grid md:grid-cols-2 gap-5">
              <div className="flex flex-col gap-1">
                <label className="text-xs font-medium">
                  Title <span className="text-red-500">*</span>
                </label>
                <input
                  value={draft.title || ""}
                  onChange={(e) => handleTitleChange(e.target.value)}
                  className={smallInput}
                />
                {errors.title && (
                  <span className="text-[10px] text-red-600">
                    {errors.title}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-1">
                <label className="text-xs font-medium">
                  Short Description <span className="text-red-500">*</span>
                </label>
                <input
                  value={draft.short_description || ""}
                  onChange={(e) =>
                    update({ short_description: e.target.value })
                  }
                  className={smallInput}
                  maxLength={255}
                />
              </div>
              <div className="flex flex-col gap-1 md:col-span-2">
                <label className="text-xs font-medium">
                  Service Description <span className="text-red-500">*</span>
                </label>
                <textarea
                  value={draft.service_description || ""}
                  onChange={(e) =>
                    update({ service_description: e.target.value })
                  }
                  rows={6}
                  className="border rounded px-2 py-1 text-xs resize-y focus:ring-1 ring-blue-500 outline-none"
                />
              </div>
              <div className="flex flex-col gap-1">
                <label className="text-xs font-medium">
                  Area <span className="text-red-500">*</span>
                </label>
                <select
                  value={draft.area_id || ""}
                  onChange={(e) => update({ area_id: e.target.value })}
                  className={smallInput}
                >
                  <option value="">-- Chọn --</option>
                  <option value="hn">Hà Nội</option>
                  <option value="hcm">TP.HCM</option>
                  <option value="dn">Đà Nẵng</option>
                  <option value="qn">Quảng Ninh</option>
                  <option value="th">Thanh Hóa</option>
                </select>
                {errors.area_id && (
                  <span className="text-[10px] text-red-600">
                    {errors.area_id}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-1">
                <label className="text-xs font-medium">Slug</label>
                <input
                  value={draft.slug || ""}
                  onChange={(e) => update({ slug: e.target.value })}
                  className={smallInput}
                />
              </div>
              <div className="flex flex-col gap-1">
                <label className="text-xs font-medium">Visibility</label>
                <select
                  value={draft.visibility}
                  onChange={(e) =>
                    update({
                      visibility: e.target.value as "public" | "private",
                    })
                  }
                  className={smallInput}
                >
                  <option value="public">Public</option>
                  <option value="private">Private</option>
                </select>
              </div>
              <div className="flex items-center gap-2 mt-6">
                <input
                  id="featured"
                  type="checkbox"
                  checked={draft.is_featured}
                  onChange={(e) => update({ is_featured: e.target.checked })}
                />
                <label htmlFor="featured" className="text-xs">
                  Featured
                </label>
              </div>
              <div className="flex flex-col gap-1 md:col-span-2">
                <label className="text-xs font-medium">
                  Languages Supported
                </label>
                <ChipInput
                  value={draft.languages_supported}
                  onChange={(v) => update({ languages_supported: v })}
                  placeholder="Add language"
                />
              </div>
              <div className="flex flex-col gap-1 md:col-span-2">
                <label className="text-xs font-medium">Tags</label>
                <ChipInput
                  value={draft.tags}
                  onChange={(v) => update({ tags: v })}
                  placeholder="Add tag"
                />
              </div>
            </div>
          </div>
        );
      case Step.MEDIA:
        return (
          <div className="flex flex-col gap-6">
            <h2 className="text-lg font-semibold">Media</h2>
            <Gallery />
          </div>
        );
      case Step.PRICING:
        return (
          <div className="flex flex-col gap-6">
            <h2 className="text-lg font-semibold">Pricing</h2>
            <div className="grid md:grid-cols-3 gap-4">
              <div className="flex flex-col gap-1">
                <label className="text-xs font-medium">
                  Base Price (VND) <span className="text-red-500">*</span>
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
                  className={smallInput}
                />
                {errors.base_price && (
                  <span className="text-[10px] text-red-600">
                    {errors.base_price}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-1">
                <label className="text-xs font-medium">Currency</label>
                <select
                  value={draft.currency_code}
                  onChange={(e) => update({ currency_code: e.target.value })}
                  className={smallInput}
                >
                  <option value="VND">VND</option>
                  <option value="USD">USD</option>
                </select>
              </div>
              <div className="flex flex-col gap-1">
                <label className="text-xs font-medium">Pricing Model</label>
                <select
                  value={draft.pricing_model}
                  onChange={(e) =>
                    update({
                      pricing_model: e.target.value as
                        | "per_person"
                        | "per_booking",
                    })
                  }
                  className={smallInput}
                >
                  <option value="per_booking">Per Booking</option>
                  <option value="per_person">Per Person</option>
                </select>
              </div>
            </div>
            {/* Đơn giản hiển thị số option (chi tiết như create có thể copy lại nếu cần) */}
            <div className="text-xs text-gray-600">
              (Mock) Số price options hiện có: {draft.price_options.length}
            </div>
          </div>
        );
      case Step.ROOMS:
        return (
          <div className="flex flex-col gap-6">
            <h2 className="text-lg font-semibold">Rooms (View only mock)</h2>
            <div className="text-xs text-gray-600">
              Room types hiện có: {draft.room_types.length}
            </div>
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
              {draft.room_types.map((r) => (
                <div
                  key={r.id}
                  className="border rounded p-3 text-xs bg-gray-50 flex flex-col gap-1"
                >
                  <div className="font-semibold">{r.name}</div>
                  <div>Capacity: {r.capacity}</div>
                  <div>Quantity: {r.quantity_total}</div>
                  {r.notes && <div className="text-gray-500">{r.notes}</div>}
                </div>
              ))}
            </div>
            <div className="text-[11px] text-gray-500">
              (Đơn giản: không cho sửa ở file Edit demo này để code ngắn).
            </div>
          </div>
        );
      case Step.POLICIES:
        return (
          <div className="flex flex-col gap-6">
            <h2 className="text-lg font-semibold">Policies Overview</h2>
            <div className="text-xs">
              Tiers: {draft.cancellation_policy.length} | Addons:{" "}
              {draft.addons.length}
            </div>
          </div>
        );
      case Step.SEO:
        return (
          <div className="flex flex-col gap-6">
            <h2 className="text-lg font-semibold">SEO & Publish</h2>
            <div className="grid md:grid-cols-2 gap-5">
              <div className="flex flex-col gap-1">
                <label className="text-xs font-medium">SEO Title</label>
                <input
                  value={draft.seo.seo_title || ""}
                  onChange={(e) =>
                    update({ seo: { ...draft.seo, seo_title: e.target.value } })
                  }
                  className={smallInput}
                />
              </div>
              <div className="flex flex-col gap-1 md:col-span-2">
                <label className="text-xs font-medium">Meta Description</label>
                <textarea
                  value={draft.seo.seo_description || ""}
                  onChange={(e) =>
                    update({
                      seo: { ...draft.seo, seo_description: e.target.value },
                    })
                  }
                  rows={3}
                  className="border rounded px-2 py-1 text-xs resize-y"
                />
              </div>
            </div>
          </div>
        );
      case Step.CONFIRM:
        return (
          <div className="flex flex-col gap-6">
            <h2 className="text-lg font-semibold">
              Confirmation –{" "}
              {draft.status === "published" ? "Published" : "Draft"}
            </h2>
            <div className="grid sm:grid-cols-2 gap-4 text-xs">
              <div className={sectionCard}>
                <h3 className="font-semibold mb-2 text-sm">Summary</h3>
                <div className="flex flex-col gap-1">
                  <div>
                    <strong>Title:</strong> {draft.title}
                  </div>
                  <div>
                    <strong>Images:</strong> {draft.image_gallery.length}
                  </div>
                  <div>
                    <strong>Base Price:</strong> {draft.base_price}
                  </div>
                  <div>
                    <strong>Room Types:</strong> {draft.room_types.length}
                  </div>
                </div>
              </div>
              <div className={sectionCard}>
                <h3 className="font-semibold mb-2 text-sm">Next Steps</h3>
                <ul className="list-disc ml-4 space-y-1">
                  <li className="text-[11px]">
                    Đồng bộ thay đổi lên server khi API sẵn sàng.
                  </li>
                  <li className="text-[11px]">
                    Hoàn thiện chính sách & terms nếu thiếu.
                  </li>
                </ul>
              </div>
            </div>
          </div>
        );
      default:
        return null;
    }
  }, [step, draft, errors]);

  const finalStep = step === Step.CONFIRM;

  return (
    <div className="max-w-7xl mx-auto p-6 flex flex-col gap-6">
      <h1 className="text-2xl font-bold">
        Edit Hotel Listing #{listingId || "(mock)"}
      </h1>

      {/* Stepper */}
      <div className="flex flex-col gap-3">
        <div className="flex overflow-x-auto gap-2 no-scrollbar">
          {stepsMeta.map((s, i) => {
            const active = s.key === step;
            const visited = s.key <= maxVisited;
            return (
              <button
                key={s.key}
                disabled={!visited}
                onClick={() => goStep(s.key)}
                className={[
                  "flex items-center gap-2 px-3 py-2 rounded border text-xs font-medium shrink-0",
                  active
                    ? "bg-blue-600 text-white border-blue-600"
                    : visited
                    ? "bg-white hover:bg-blue-50 border-gray-300 text-gray-700"
                    : "bg-gray-100 text-gray-400 border-gray-200",
                ].join(" ")}
              >
                <span className="w-5 h-5 rounded-full border flex items-center justify-center text-[10px] font-semibold">
                  {i + 1}
                </span>
                {s.label}
              </button>
            );
          })}
        </div>
        <div className="h-1 bg-gray-200 rounded">
          <div
            className="h-full bg-blue-600 rounded transition-all"
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
      <div className="bg-white border rounded-lg p-5 shadow-sm">
        {renderStep()}
      </div>

      {/* Actions */}
      <div className="flex items-center justify-between">
        <div className="flex gap-2">
          {step > Step.TYPE && (
            <button
              onClick={prev}
              className="px-4 py-2 text-sm border rounded hover:bg-gray-50 flex items-center gap-1"
            >
              <ChevronLeft className="w-4 h-4" />
              Back
            </button>
          )}
          <button
            onClick={saveDraft}
            disabled={saving}
            className="px-4 py-2 text-sm border rounded bg-gray-100 hover:bg-gray-200 disabled:opacity-50"
          >
            {saving ? (
              <span className="flex items-center gap-2">
                <Loader2 className="w-4 h-4 animate-spin" /> Updating...
              </span>
            ) : (
              "Update Draft"
            )}
          </button>
        </div>
        <div className="flex gap-2">
          {finalStep && (
            <button
              onClick={publish}
              disabled={saving}
              className="px-4 py-2 text-sm rounded bg-green-600 text-white hover:bg-green-700 disabled:opacity-50 flex items-center gap-1"
            >
              {saving ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                "Publish"
              )}
            </button>
          )}
          {!finalStep && (
            <button
              onClick={next}
              disabled={saving}
              className="px-4 py-2 text-sm rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 flex items-center gap-1"
            >
              {saving ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                <ChevronRight className="w-4 h-4" />
              )}
              Next
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default HotelEditPage;
