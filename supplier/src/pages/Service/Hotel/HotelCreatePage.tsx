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
const smallInput =
  "border rounded px-2 py-1 text-xs focus:ring-1 ring-blue-500 outline-none";
const sectionCard = "border rounded-lg p-4 bg-white shadow-sm";

const randomImg = () =>
  `https://picsum.photos/seed/hotel-${Math.random() * 9999}/320/220`;

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

  /* ===== Validation (simple) ===== */
  const validateCurrent = (): boolean => {
    const e: Record<string, string> = {};
    if (step === Step.GENERAL) {
      if (!draft.title) e.title = "Required";
      if (!draft.short_description) e.short_description = "Required";
      if (!draft.service_description) e.service_description = "Required";
      if (!draft.area_id) e.area_id = "Required";
    }
    if (step === Step.MEDIA) {
      if (draft.image_gallery.length === 0)
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
      console.log("MOCK SAVE DRAFT", draft);
      setSaving(false);
    }, 500);
  };

  const publish = () => {
    // Simple check
    if (
      !draft.title ||
      !draft.short_description ||
      !draft.service_description ||
      draft.image_gallery.length === 0 ||
      !draft.base_price
    ) {
      alert("Chưa đủ dữ liệu để publish (mock).");
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
      alert("Published (mock)!");
    }, 800);
  };

  /* ===== Reusable small editors inside this file (để gọn) ===== */
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
          className="border-2 border-dashed rounded p-6 flex flex-col items-center gap-2 text-xs text-gray-500 cursor-pointer hover:bg-gray-50"
        >
          <Upload className="w-5 h-5 text-gray-400" />
          Thêm (mock) hình ảnh
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

  const PriceOptionsEditor: React.FC = () => {
    const addOpt = () => {
      const o: PriceOption = {
        id: Date.now().toString(),
        option_name: "Default",
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
      <div className="flex flex-col gap-3">
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-semibold">Price Options</h3>
          <button
            onClick={addOpt}
            className="text-xs flex items-center gap-1 px-2 py-1.5 rounded bg-blue-600 text-white hover:bg-blue-700"
          >
            <Plus className="w-3 h-3" /> Add Option
          </button>
        </div>
        {draft.price_options.length === 0 && (
          <div className="text-[11px] text-gray-500">Chưa có option.</div>
        )}
        <div className="flex flex-col gap-3">
          {draft.price_options.map((o) => (
            <div
              key={o.id}
              className="border rounded p-3 bg-gray-50 flex flex-col gap-2"
            >
              <div className="flex flex-wrap gap-2">
                <input
                  value={o.option_name}
                  onChange={(e) =>
                    updateOpt(o.id, { option_name: e.target.value })
                  }
                  className={smallInput + " flex-1 min-w-[120px]"}
                />
                <input
                  type="number"
                  value={o.price}
                  onChange={(e) => updateOpt(o.id, { price: +e.target.value })}
                  className={smallInput + " w-28"}
                />
                <label className="flex items-center gap-1 text-[11px]">
                  <input
                    type="checkbox"
                    checked={o.per_person}
                    onChange={(e) =>
                      updateOpt(o.id, { per_person: e.target.checked })
                    }
                  />
                  Per Person
                </label>
                <button
                  onClick={() => remove(o.id)}
                  className="p-1 text-red-600 hover:bg-red-50 rounded"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
              <textarea
                value={o.description || ""}
                onChange={(e) =>
                  updateOpt(o.id, { description: e.target.value })
                }
                rows={2}
                className="border rounded px-2 py-1 text-xs"
                placeholder="Description"
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
        name: "Standard Room",
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
      <div className="flex flex-col gap-3">
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-semibold">Room Types</h3>
          <button
            onClick={addRoom}
            className="text-xs flex items-center gap-1 px-2 py-1.5 rounded bg-blue-600 text-white hover:bg-blue-700"
          >
            <Plus className="w-3 h-3" /> Add Room
          </button>
        </div>
        {draft.room_types.length === 0 && (
          <div className="text-[11px] text-gray-500">Chưa có room type.</div>
        )}
        <div className="flex flex-col gap-3">
          {draft.room_types.map((r) => (
            <div
              key={r.id}
              className="border rounded p-3 bg-gray-50 flex flex-col gap-2"
            >
              <div className="flex flex-wrap gap-2">
                <input
                  value={r.name}
                  onChange={(e) => upd(r.id, { name: e.target.value })}
                  className={smallInput + " flex-1 min-w-[120px]"}
                />
                <input
                  type="number"
                  value={r.capacity}
                  onChange={(e) => upd(r.id, { capacity: +e.target.value })}
                  className={smallInput + " w-24"}
                  placeholder="Capacity"
                />
                <input
                  type="number"
                  value={r.quantity_total}
                  onChange={(e) =>
                    upd(r.id, { quantity_total: +e.target.value })
                  }
                  className={smallInput + " w-28"}
                  placeholder="Quantity"
                />
                <button
                  onClick={() => remove(r.id)}
                  className="p-1 text-red-600 hover:bg-red-50 rounded"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
              <textarea
                value={r.notes || ""}
                onChange={(e) => upd(r.id, { notes: e.target.value })}
                rows={2}
                className="border rounded px-2 py-1 text-xs"
                placeholder="Notes"
              />
            </div>
          ))}
        </div>
        <div className="mt-2 text-[11px] text-gray-500">
          Calendar inventory phức tạp sẽ làm sau.
        </div>
      </div>
    );
  };

  const PoliciesAddons: React.FC = () => {
    // Đơn giản: chỉ addons & vài booking settings
    const addAddon = () => {
      const a: AddonItem = {
        id: Date.now().toString(),
        name: "Breakfast",
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
      <div className="flex flex-col gap-6">
        <div className="flex flex-col gap-2">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-semibold">Cancellation Policy</h3>
            <button
              onClick={addPolicyTier}
              className="text-xs flex items-center gap-1 px-2 py-1 rounded bg-blue-100 text-blue-700 hover:bg-blue-200"
            >
              <Plus className="w-3 h-3" /> Add Tier
            </button>
          </div>
          {draft.cancellation_policy.length === 0 && (
            <div className="text-[11px] text-gray-500">Chưa có tier.</div>
          )}
          <div className="flex flex-col gap-2">
            {draft.cancellation_policy.map((t) => (
              <div
                key={t.id}
                className="border rounded p-2 bg-gray-50 flex flex-col gap-2"
              >
                <div className="flex flex-wrap gap-2">
                  <input
                    type="number"
                    className={smallInput + " w-20"}
                    value={t.from_days}
                    onChange={(e) =>
                      updTier(t.id, { from_days: +e.target.value })
                    }
                    placeholder="From"
                  />
                  <input
                    type="number"
                    className={smallInput + " w-20"}
                    value={t.to_days}
                    onChange={(e) =>
                      updTier(t.id, { to_days: +e.target.value })
                    }
                    placeholder="To"
                  />
                  <input
                    type="number"
                    className={smallInput + " w-24"}
                    value={t.refund_percent ?? ""}
                    onChange={(e) =>
                      updTier(t.id, { refund_percent: +e.target.value })
                    }
                    placeholder="%"
                  />
                  <input
                    className={smallInput + " flex-1 min-w-[140px]"}
                    value={t.penalty_description || ""}
                    onChange={(e) =>
                      updTier(t.id, { penalty_description: e.target.value })
                    }
                    placeholder="Penalty desc"
                  />
                  <button
                    onClick={() => removeTier(t.id)}
                    className="p-1 text-red-600 hover:bg-red-50 rounded"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
                <div className="text-[10px] text-gray-500">
                  Không để khoảng ngày bị overlap (chưa validate).
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="flex flex-col gap-3">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-semibold">Add-ons</h3>
            <button
              onClick={addAddon}
              className="text-xs flex items-center gap-1 px-2 py-1 rounded bg-blue-100 text-blue-700 hover:bg-blue-200"
            >
              <Plus className="w-3 h-3" /> Add Addon
            </button>
          </div>
          {draft.addons.length === 0 && (
            <div className="text-[11px] text-gray-500">Chưa có addon.</div>
          )}
          <div className="flex flex-col gap-2">
            {draft.addons.map((a) => (
              <div
                key={a.id}
                className="border rounded p-2 bg-gray-50 flex flex-col gap-2"
              >
                <div className="flex flex-wrap gap-2">
                  <input
                    value={a.name}
                    onChange={(e) => updAddon(a.id, { name: e.target.value })}
                    className={smallInput + " flex-1 min-w-[120px]"}
                  />
                  <input
                    type="number"
                    value={a.price}
                    onChange={(e) => updAddon(a.id, { price: +e.target.value })}
                    className={smallInput + " w-24"}
                  />
                  <label className="flex items-center gap-1 text-[11px]">
                    <input
                      type="checkbox"
                      checked={a.per_person}
                      onChange={(e) =>
                        updAddon(a.id, { per_person: e.target.checked })
                      }
                    />
                    Per Person
                  </label>
                  <button
                    onClick={() => remove(a.id)}
                    className="p-1 text-red-600 hover:bg-red-50 rounded"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
                <textarea
                  value={a.description || ""}
                  onChange={(e) =>
                    updAddon(a.id, { description: e.target.value })
                  }
                  rows={2}
                  className="border rounded px-2 py-1 text-xs"
                  placeholder="Description"
                />
              </div>
            ))}
          </div>
        </div>

        <div className="border rounded p-3 flex flex-col gap-2">
          <h4 className="text-xs font-semibold">Booking Settings</h4>
          <div className="flex gap-4 flex-wrap text-[11px]">
            <label className="flex items-center gap-1">
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
              Auto Accept
            </label>
            <label className="flex items-center gap-1">
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
              Cancel Needs Approval
            </label>
            <label className="flex items-center gap-1">
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
              Require Passport
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
            className="border rounded px-2 py-1 text-xs"
            placeholder="Terms & Conditions..."
          />
        </div>
      </div>
    );
  };

  const SeoPublish: React.FC = () => {
    const setSeo = (patch: Partial<SeoConfig>) =>
      update({ seo: { ...draft.seo, ...patch } });
    return (
      <div className="flex flex-col gap-6">
        <div>
          <h2 className="text-lg font-semibold mb-1">SEO & Publish</h2>
          <p className="text-xs text-gray-500">
            Cấu hình SEO và hành động xuất bản.
          </p>
        </div>
        <div className="grid md:grid-cols-2 gap-5">
          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium">SEO Title</label>
            <input
              value={draft.seo.seo_title || ""}
              onChange={(e) => setSeo({ seo_title: e.target.value })}
              className={smallInput}
              maxLength={255}
            />
          </div>
          <div className="flex flex-col gap-1 md:col-span-2">
            <label className="text-xs font-medium">Meta Description</label>
            <textarea
              value={draft.seo.seo_description || ""}
              onChange={(e) => setSeo({ seo_description: e.target.value })}
              rows={3}
              className="border rounded px-2 py-1 text-xs resize-y"
            />
          </div>
          <div className="flex flex-col gap-1 md:col-span-2">
            <label className="text-xs font-medium">Meta Keywords (CSV)</label>
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
              className={smallInput}
              placeholder="hotel,resort,beach"
            />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium">Visibility</label>
            <select
              value={draft.seo.visibility}
              onChange={(e) =>
                setSeo({ visibility: e.target.value as "public" | "private" })
              }
              className={smallInput}
            >
              <option value="public">Public</option>
              <option value="private">Private</option>
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium">Publish Now?</label>
            <select
              value={draft.seo.publish_now ? "yes" : "no"}
              onChange={(e) =>
                setSeo({ publish_now: e.target.value === "yes" })
              }
              className={smallInput}
            >
              <option value="yes">Yes (Immediate)</option>
              <option value="no">No (Schedule)</option>
            </select>
          </div>
          {!draft.seo.publish_now && (
            <div className="flex flex-col gap-1">
              <label className="text-xs font-medium">Publish At</label>
              <input
                type="datetime-local"
                value={draft.seo.publish_at || ""}
                onChange={(e) => setSeo({ publish_at: e.target.value })}
                className={smallInput}
              />
            </div>
          )}
        </div>
        <div className="border rounded p-4">
          <h3 className="text-sm font-semibold mb-2">Checklist</h3>
          <ul className="text-[11px] text-gray-600 list-disc ml-4 space-y-1">
            <li>{draft.title ? "✅" : "❌"} Title</li>
            <li>{draft.short_description ? "✅" : "❌"} Short description</li>
            <li>
              {draft.image_gallery.length > 0 ? "✅" : "❌"} At least 1 image
            </li>
            <li>{draft.base_price ? "✅" : "❌"} Base price</li>
          </ul>
        </div>
      </div>
    );
  };

  const Confirmation: React.FC = () => (
    <div className="flex flex-col gap-6">
      <h2 className="text-lg font-semibold">
        Hoàn tất (Mock) – {draft.status === "published" ? "Published" : "Draft"}
      </h2>
      <div className="grid sm:grid-cols-2 gap-4 text-xs">
        <div className={sectionCard}>
          <h3 className="font-semibold mb-2 text-sm">Summary</h3>
          <div className="flex flex-col gap-1">
            <div>
              <strong>Title:</strong> {draft.title || "(empty)"}
            </div>
            <div>
              <strong>Slug:</strong> {draft.slug || "(auto)"}
            </div>
            <div>
              <strong>Images:</strong> {draft.image_gallery.length}
            </div>
            <div>
              <strong>Room types:</strong> {draft.room_types.length}
            </div>
            <div>
              <strong>Price options:</strong> {draft.price_options.length}
            </div>
            <div>
              <strong>SEO publish now:</strong>{" "}
              {draft.seo.publish_now ? "Yes" : "No"}
            </div>
          </div>
        </div>
        <div className={sectionCard}>
          <h3 className="font-semibold mb-2 text-sm">Next Steps</h3>
          <ul className="list-disc ml-4 space-y-1">
            <li className="text-[11px]">Thêm nội dung mô tả chi tiết hơn.</li>
            <li className="text-[11px]">
              Kiểm tra lại chính sách huỷ & addons.
            </li>
            <li className="text-[11px]">
              Đồng bộ lên server khi API sẵn sàng.
            </li>
          </ul>
        </div>
      </div>
      <div className="text-[11px] text-gray-500">
        Bạn có thể quay lại các bước để chỉnh sửa (tĩnh).
      </div>
    </div>
  );

  /* ===== Auto slug (simple) ===== */
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
          <div className="flex flex-col gap-6">
            <div>
              <h2 className="text-lg font-semibold mb-1">Select Type</h2>
              <p className="text-xs text-gray-500">
                Hiện tại cố định là Hotel. (Các service khác làm sau)
              </p>
            </div>
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
              <div className="border-2 border-blue-500 rounded-lg p-4 bg-blue-50 flex flex-col gap-3">
                <div className="flex items-center gap-2">
                  <Building2 className="w-5 h-5 text-blue-600" />
                  <h3 className="font-medium text-sm">Hotel</h3>
                </div>
                <ul className="text-[11px] text-gray-600 list-disc ml-4 space-y-1">
                  <li>Room types & inventory</li>
                  <li>Nhiều mức giá / options</li>
                  <li>SEO & scheduling</li>
                </ul>
                <div className="mt-auto">
                  <button
                    onClick={next}
                    className="text-xs bg-blue-600 text-white px-3 py-1.5 rounded hover:bg-blue-700"
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
          <div className="flex flex-col gap-6">
            <div>
              <h2 className="text-lg font-semibold mb-1">General</h2>
              <p className="text-xs text-gray-500">
                Thông tin mô tả cơ bản của khách sạn.
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
                  placeholder="Ví dụ: Blue Ocean Hotel"
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
                {errors.short_description && (
                  <span className="text-[10px] text-red-600">
                    {errors.short_description}
                  </span>
                )}
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
                  placeholder="Mô tả chi tiết (mock rich text)"
                />
                {errors.service_description && (
                  <span className="text-[10px] text-red-600">
                    {errors.service_description}
                  </span>
                )}
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
                <span className="text-[10px] text-gray-500">
                  Tự sinh từ title (có thể sửa).
                </span>
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
                  placeholder="Enter language (Enter)"
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
            <div>
              <h2 className="text-lg font-semibold mb-1">Media</h2>
              <p className="text-xs text-gray-500">
                Ảnh gallery, video, virtual tour (mock).
              </p>
            </div>
            <Gallery />
            <div className="grid md:grid-cols-2 gap-5">
              <div className="flex flex-col gap-1">
                <label className="text-xs font-medium">Video URLs (CSV)</label>
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
                  className={smallInput}
                  placeholder="https://youtu.be/..."
                />
              </div>
              <div className="flex flex-col gap-1">
                <label className="text-xs font-medium">
                  Virtual Tours (CSV)
                </label>
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
                  className={smallInput}
                  placeholder="https://example.com/360..."
                />
              </div>
            </div>
          </div>
        );
      case Step.PRICING:
        return (
          <div className="flex flex-col gap-6">
            <div>
              <h2 className="text-lg font-semibold mb-1">Pricing</h2>
              <p className="text-xs text-gray-500">
                Giá cơ bản & nhiều price options.
              </p>
            </div>
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
            <PriceOptionsEditor />
          </div>
        );
      case Step.ROOMS:
        return (
          <div className="flex flex-col gap-6">
            <div>
              <h2 className="text-lg font-semibold mb-1">Rooms</h2>
              <p className="text-xs text-gray-500">
                Quản lý các loại phòng (mock).
              </p>
            </div>
            <RoomTypesEditor />
          </div>
        );
      case Step.POLICIES:
        return (
          <div className="flex flex-col gap-6">
            <div>
              <h2 className="text-lg font-semibold mb-1">Policies & Add-ons</h2>
              <p className="text-xs text-gray-500">
                Chính sách huỷ và addon bổ sung.
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
    <div className="max-w-7xl mx-auto p-6 flex flex-col gap-6">
      <h1 className="text-2xl font-bold">Create Hotel Listing</h1>

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
                <Loader2 className="w-4 h-4 animate-spin" /> Saving...
              </span>
            ) : (
              "Save Draft"
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
              {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : null}
              Publish
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

export default HotelCreatePage;
