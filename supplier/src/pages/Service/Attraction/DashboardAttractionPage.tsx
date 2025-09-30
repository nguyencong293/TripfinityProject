import React, { useMemo, useState } from "react";
import {
  Landmark,
  Plus,
  Search,
  Filter,
  CalendarDays,
  Clock,
  Star,
  Power,
  Archive,
  ChevronDown,
  ChevronUp,
  History,
  Tag,
  Layers3,
  Pencil,
  Video,
  BookOpen,
  Users,
  DollarSign,
  Shield,
  ShieldAlert,
  AlertTriangle,
  XCircle,
  Sparkles,
  Check,
} from "lucide-react";

/* ===================== Types ===================== */
type AttractionStatus = "draft" | "published" | "archived" | "disabled";

interface Attraction {
  id: number;
  title: string;
  slug: string;
  area: string;
  feature_type: "park" | "museum" | "historical" | "other";
  accessibility: string[];
  price_min: number;
  price_currency: string;
  opening_hours: {
    morning: boolean;
    afternoon: boolean;
    evening: boolean;
  };
  average_visit_minutes: number;
  next_available_slot?: string | null;
  rating_average: number;
  status: AttractionStatus;
  visibility: "public" | "private";
  thumbnail_url?: string | null;
  created_at: string;
  updated_at: string;
}

interface TimeSlot {
  id: number;
  attraction_id: number;
  datetime: string; // ISO
  capacity: number;
  booked: number;
  blocked: boolean;
}

interface PackageOption {
  id: number;
  attraction_id: number;
  name: string;
  type: "combo" | "timed" | "family" | "all_day";
  price: number;
  currency: string;
  includes: string[];
  capacity_control: boolean;
}

interface Review {
  id: number;
  attraction_id: number;
  author: string;
  rating: number;
  aspects: { beauty: number; culture: number; accessibility: number };
  content: string;
  created_at: string;
}

interface Tip {
  id: number;
  attraction_id: number;
  author: string;
  content: string;
  created_at: string;
}

interface Permit {
  id: number;
  name: string;
  status: "valid" | "expired" | "pending";
  expires_on?: string;
  required: boolean;
}

interface AlertItem {
  id: number;
  type:
    | "high_demand"
    | "permit_expired"
    | "accessibility_issue"
    | "slot_over_capacity";
  message: string;
  severity: "info" | "warn" | "critical";
  created_at: string;
}

interface ActivityLog {
  id: number;
  action:
    | "publish"
    | "unpublish"
    | "slot_block"
    | "capacity_increase"
    | "price_update"
    | "package_add"
    | "virtual_tour_add"
    | "review_reply";
  attraction_id?: number;
  created_at: string;
  meta?: Record<string, unknown>;
}

/* ===================== Mock Data Generators ===================== */
const areas = ["Hà Nội", "TP.HCM", "Đà Nẵng", "Huế", "Quảng Ninh", "Sa Pa"];
const featureTypes: Attraction["feature_type"][] = [
  "park",
  "museum",
  "historical",
  "other",
];
const accessibilityTags = [
  "wheelchair",
  "audio-guide",
  "braille",
  "family-friendly",
  "pet-friendly",
];

function rand<T>(arr: T[]) {
  return arr[Math.floor(Math.random() * arr.length)];
}
function randomSubset<T>(arr: T[], min = 1, max = 3) {
  const copy = [...arr];
  const result: T[] = [];
  const target = Math.max(
    min,
    Math.min(max, Math.floor(Math.random() * (max - min + 1)) + min)
  );
  while (result.length < target && copy.length) {
    const idx = Math.floor(Math.random() * copy.length);
    result.push(copy.splice(idx, 1)[0]);
  }
  return result;
}

function genAttractions(): Attraction[] {
  const list: Attraction[] = [];
  const now = Date.now();
  for (let i = 1; i <= 18; i++) {
    const hasSlot = Math.random() > 0.3;
    list.push({
      id: i,
      title: `Attraction #${i}`,
      slug: `attraction-${i}`,
      area: rand(areas),
      feature_type: rand(featureTypes),
      accessibility: randomSubset(accessibilityTags, 1, 4),
      price_min: 50000 + ((i * 17000) % 180000),
      price_currency: "VND",
      opening_hours: {
        morning: Math.random() > 0.2,
        afternoon: Math.random() > 0.1,
        evening: Math.random() > 0.4,
      },
      average_visit_minutes: 60 + (i % 5) * 30,
      next_available_slot: hasSlot
        ? new Date(now + Math.random() * 5 * 86400000)
            .toISOString()
            .substring(0, 16)
        : null,
      rating_average: parseFloat((3 + Math.random() * 2).toFixed(1)),
      status: rand(["published", "draft", "archived", "disabled"]),
      visibility: Math.random() > 0.2 ? "public" : "private",
      thumbnail_url:
        Math.random() > 0.15
          ? `https://picsum.photos/seed/attraction-${i}/210/150.webp`
          : null,
      created_at: new Date(now - i * 86400000).toISOString(),
      updated_at: new Date(now - i * 3600000).toISOString(),
    });
  }
  return list;
}

function genTimeSlots(attractions: Attraction[]): TimeSlot[] {
  const now = new Date();
  const slots: TimeSlot[] = [];
  let id = 1;
  attractions.slice(0, 6).forEach((a) => {
    for (let d = 0; d < 7; d++) {
      for (let t = 9; t <= 17; t += 2) {
        if (Math.random() > 0.75) continue;
        const dt = new Date(now.getTime() + d * 86400000);
        dt.setHours(t, 0, 0, 0);
        const capacity = 40 + (t % 3) * 20;
        const booked = Math.floor(capacity * Math.random());
        slots.push({
          id: id++,
          attraction_id: a.id,
          datetime: dt.toISOString(),
          capacity,
          booked,
          blocked: Math.random() > 0.93,
        });
      }
    }
  });
  return slots;
}

function genPackages(attractions: Attraction[]): PackageOption[] {
  const list: PackageOption[] = [];
  let id = 1;
  attractions.slice(0, 6).forEach((a) => {
    ["combo", "timed", "family", "all_day"].forEach((type, idx) => {
      list.push({
        id: id++,
        attraction_id: a.id,
        name:
          type === "combo"
            ? "Combo City Pass"
            : type === "timed"
            ? "Timed Entry"
            : type === "family"
            ? "Family Pack"
            : "All-Day Access",
        type: type as PackageOption["type"],
        price: a.price_min + idx * 40000,
        currency: "VND",
        includes:
          type === "combo"
            ? ["Main Gate", "Museum Wing", "Sky Deck"]
            : type === "family"
            ? ["2 Adults", "2 Kids"]
            : type === "timed"
            ? ["Entry at set hour"]
            : ["Unlimited entries"],
        capacity_control: type === "timed",
      });
    });
  });
  return list;
}

function genReviews(attractions: Attraction[]): Review[] {
  const list: Review[] = [];
  let id = 1;
  attractions.slice(0, 6).forEach((a) => {
    const n = 1 + (a.id % 3);
    for (let i = 0; i < n; i++) {
      list.push({
        id: id++,
        attraction_id: a.id,
        author: `Reviewer ${id}`,
        rating: parseFloat((3 + Math.random() * 2).toFixed(1)),
        aspects: {
          beauty: parseFloat((3 + Math.random() * 2).toFixed(1)),
          culture: parseFloat((3 + Math.random() * 2).toFixed(1)),
          accessibility: parseFloat((3 + Math.random() * 2).toFixed(1)),
        },
        content: "Khá ấn tượng, dịch vụ tốt (mock).",
        created_at: new Date(Date.now() - i * 3600000).toISOString(),
      });
    }
  });
  return list;
}

function genTips(attractions: Attraction[]): Tip[] {
  const list: Tip[] = [];
  let id = 1;
  attractions.slice(0, 5).forEach((a) => {
    list.push({
      id: id++,
      attraction_id: a.id,
      author: "Hệ thống",
      content: "Đến sớm 15 phút để làm thủ tục.",
      created_at: new Date().toISOString(),
    });
  });
  return list;
}

function genPermits(): Permit[] {
  return [
    {
      id: 1,
      name: "An toàn phòng cháy",
      status: "valid",
      expires_on: new Date(Date.now() + 120 * 86400000)
        .toISOString()
        .substring(0, 10),
      required: true,
    },
    {
      id: 2,
      name: "Giấy phép sự kiện",
      status: "pending",
      required: false,
    },
    {
      id: 3,
      name: "Vệ sinh môi trường",
      status: "expired",
      expires_on: new Date(Date.now() - 10 * 86400000)
        .toISOString()
        .substring(0, 10),
      required: true,
    },
  ];
}

function genAlerts(attractions: Attraction[]): AlertItem[] {
  return [
    {
      id: 1,
      type: "high_demand",
      message: `Slot 10:00 ngày mai nhu cầu cao (${attractions[0].title})`,
      severity: "warn",
      created_at: new Date().toISOString(),
    },
    {
      id: 2,
      type: "permit_expired",
      message: "Giấy phép vệ sinh môi trường đã hết hạn",
      severity: "critical",
      created_at: new Date().toISOString(),
    },
    {
      id: 3,
      type: "accessibility_issue",
      message: "Phản hồi thiếu bảng chỉ dẫn Braille",
      severity: "info",
      created_at: new Date().toISOString(),
    },
  ];
}

function genActivity(attractions: Attraction[]): ActivityLog[] {
  const actions: ActivityLog["action"][] = [
    "publish",
    "unpublish",
    "slot_block",
    "capacity_increase",
    "price_update",
    "package_add",
    "virtual_tour_add",
    "review_reply",
  ];
  const list: ActivityLog[] = [];
  for (let i = 0; i < 22; i++) {
    const a = rand(attractions);
    list.push({
      id: i + 1,
      action: rand(actions),
      attraction_id: a.id,
      created_at: new Date(Date.now() - i * 3600000).toISOString(),
      meta: { title: a.title },
    });
  }
  return list;
}

/* ===================== Helpers ===================== */
const fmtCurrency = (v: number, cur = "VND") =>
  new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: cur,
    minimumFractionDigits: 0,
  }).format(v);

const cx = (...c: Array<string | false | null | undefined>) =>
  c.filter(Boolean).join(" ");

/* ===================== Component ===================== */
const DashboardAttractionPage: React.FC = () => {
  // Seeds
  const [attractions] = useState<Attraction[]>(() => genAttractions());
  const [slots] = useState<TimeSlot[]>(() => genTimeSlots(attractions));
  const [packages] = useState<PackageOption[]>(() => genPackages(attractions));
  const [reviews] = useState<Review[]>(() => genReviews(attractions));
  const [tips] = useState<Tip[]>(() => genTips(attractions));
  const [permits] = useState<Permit[]>(() => genPermits());
  const [alerts] = useState<AlertItem[]>(() => genAlerts(attractions));
  const [activities] = useState<ActivityLog[]>(() => genActivity(attractions));

  // Filters
  const [search, setSearch] = useState("");
  const [filterArea, setFilterArea] = useState("");
  const [filterType, setFilterType] = useState<Attraction["feature_type"] | "">(
    ""
  );
  const [filterAccess, setFilterAccess] = useState("");
  const [priceMin, setPriceMin] = useState("");
  const [priceMax, setPriceMax] = useState("");
  const [filterHours, setFilterHours] = useState("");
  const [filterStatus, setFilterStatus] = useState<AttractionStatus | "">("");

  // Collapse
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});
  const toggleCollapse = (k: string) =>
    setCollapsed((p) => ({ ...p, [k]: !p[k] }));

  // Selection
  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set());
  const toggleSelectAll = (rows: Attraction[]) => {
    const ids = rows.map((r) => r.id);
    const all = ids.every((id) => selectedIds.has(id));
    setSelectedIds(all ? new Set() : new Set(ids));
  };
  const toggleSelectOne = (id: number) =>
    setSelectedIds((prev) => {
      const n = new Set(prev);
      if (n.has(id)) {
        n.delete(id);
      } else {
        n.add(id);
      }
      return n;
    });

  // Filtered attractions
  const filteredAttractions = useMemo(() => {
    return attractions.filter((a) => {
      if (search) {
        const q = search.toLowerCase();
        if (
          !a.title.toLowerCase().includes(q) &&
          !a.slug.toLowerCase().includes(q) &&
          !String(a.id).includes(q)
        )
          return false;
      }
      if (filterArea && a.area !== filterArea) return false;
      if (filterType && a.feature_type !== filterType) return false;
      if (filterAccess && !a.accessibility.includes(filterAccess)) return false;
      if (filterHours) {
        if (!a.opening_hours[filterHours as keyof typeof a.opening_hours])
          return false;
      }
      if (filterStatus && a.status !== filterStatus) return false;
      if (priceMin && a.price_min < parseInt(priceMin, 10)) return false;
      if (priceMax && a.price_min > parseInt(priceMax, 10)) return false;
      return true;
    });
  }, [
    attractions,
    search,
    filterArea,
    filterType,
    filterAccess,
    filterHours,
    filterStatus,
    priceMin,
    priceMax,
  ]);

  // Derivations
  const todayStr = new Date().toISOString().substring(0, 10);
  const todaySlots = slots.filter((s) => s.datetime.startsWith(todayStr));
  const visitorsToday = todaySlots.reduce((sum, s) => sum + s.booked, 0);
  const avgVisitDuration =
    attractions.length > 0
      ? attractions.reduce((s, a) => s + a.average_visit_minutes, 0) /
        attractions.length
      : 0;
  const occupancyPercent =
    todaySlots.length > 0
      ? (todaySlots.reduce((s, t) => s + t.booked, 0) /
          todaySlots.reduce((s, t) => s + t.capacity, 0)) *
        100
      : 0;
  const revenue =
    todaySlots.reduce(
      (s, t) => s + t.booked * (50000 + (t.capacity % 3) * 20000),
      0
    ) * 0.7; // mock adjust
  const newReviews = reviews.filter((r) =>
    r.created_at.startsWith(todayStr)
  ).length;

  const kpis = {
    visitorsToday,
    avgVisitDuration,
    occupancyPercent,
    revenue,
    newReviews,
  };

  const next7 = useMemo(() => {
    const until = new Date(Date.now() + 7 * 86400000).toISOString();
    return slots
      .filter((s) => s.datetime <= until)
      .sort(
        (a, b) =>
          new Date(a.datetime).getTime() - new Date(b.datetime).getTime()
      )
      .slice(0, 40);
  }, [slots]);

  const packagesPreview = useMemo(() => packages.slice(0, 9), [packages]);
  const reviewsPreview = useMemo(() => reviews.slice(0, 5), [reviews]);
  const tipsPreview = useMemo(() => tips.slice(0, 4), [tips]);
  const alertsRecent = useMemo(() => alerts.slice(0, 6), [alerts]);
  const activitiesRecent = useMemo(() => activities.slice(0, 10), [activities]);

  // Bulk (mock)
  const bulkPublish = () => {
    console.log("Publish attractions:", Array.from(selectedIds));
    alert("Bulk publish (mock)");
  };
  const bulkArchive = () => {
    console.log("Archive attractions:", Array.from(selectedIds));
    alert("Bulk archive (mock)");
  };
  const clearFilters = () => {
    setSearch("");
    setFilterArea("");
    setFilterType("");
    setFilterAccess("");
    setFilterHours("");
    setFilterStatus("");
    setPriceMin("");
    setPriceMax("");
  };

  // Helpers
  const statusBadge = (status: AttractionStatus) => {
    const map: Record<AttractionStatus, string> = {
      published:
        "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
      draft:
        "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
      archived: "bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-200",
      disabled: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300",
    };
    const label: Record<AttractionStatus, string> = {
      published: "Đang xuất bản",
      draft: "Nháp",
      archived: "Lưu trữ",
      disabled: "Ngưng",
    };
    return (
      <span
        className={cx(
          "caption-mobile sm:caption-tablet lg:caption-desktop px-2 py-0.5 rounded font-medium inline-block",
          map[status]
        )}
      >
        {label[status]}
      </span>
    );
  };

  const sectionHeader = (
    title: string,
    key: string,
    icon?: React.ReactNode,
    extra?: React.ReactNode
  ) => {
    const col = collapsed[key];
    return (
      <div className="flex items-center gap-2 mb-3">
        <button
          onClick={() => toggleCollapse(key)}
          className="flex items-center gap-2 group"
          type="button"
        >
          <span className="w-6 h-6 inline-flex items-center justify-center rounded theme-bg-secondary icon-brand">
            {icon || <Landmark className="w-4 h-4" />}
          </span>
          <h3 className="h5-mobile sm:h5-tablet lg:h5-desktop font-semibold">
            {title}
          </h3>
          {col ? (
            <ChevronDown className="w-4 h-4 theme-text-secondary group-hover:icon-brand" />
          ) : (
            <ChevronUp className="w-4 h-4 theme-text-secondary group-hover:icon-brand" />
          )}
        </button>
        <div className="ml-auto flex items-center gap-2">{extra}</div>
      </div>
    );
  };

  const renderKPI = (
    label: string,
    value: React.ReactNode,
    icon: React.ReactNode,
    sub?: React.ReactNode
  ) => (
    <div className="theme-border rounded-lg p-4 theme-bg-card flex flex-col gap-2 shadow-sm">
      <div className="flex items-center gap-2">
        <div className="w-9 h-9 rounded-full theme-bg-secondary flex items-center justify-center icon-brand">
          {icon}
        </div>
        <span className="overline-mobile sm:overline-tablet lg:overline-desktop font-medium theme-text-secondary">
          {label}
        </span>
      </div>
      <div className="h4-mobile sm:h4-tablet lg:h4-desktop font-bold">
        {value}
      </div>
      {sub && (
        <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
          {sub}
        </div>
      )}
    </div>
  );

  /* ===================== JSX ===================== */
  return (
    <div className="p-6 max-w-[1900px] mx-auto flex flex-col gap-10 theme-text-primary">
      {/* Header & Filters */}
      <div className="flex flex-col gap-4">
        <div className="flex flex-wrap items-center gap-3">
          <h1 className="h3-mobile sm:h3-tablet lg:h3-desktop font-bold flex items-center gap-2">
            <Landmark className="w-7 h-7 icon-brand" />
            Dashboard Điểm Tham Quan
          </h1>
          <span className="body2-mobile sm:body2-tablet lg:body2-desktop theme-text-secondary">
            Nhà cung cấp: <strong>Mock Provider Co.</strong>
          </span>
          <div className="ml-auto flex gap-2">
            <button className="btn-primary btn-text-responsive flex items-center gap-2">
              <Plus className="w-4 h-4" />
              Tạo Attraction
            </button>
            <button className="btn-outline btn-text-responsive flex items-center gap-2">
              <Video className="w-4 h-4" />
              Thêm Virtual Tour
            </button>
          </div>
        </div>

        <div className="flex flex-wrap gap-3 items-end">
          <div className="flex items-center gap-2 theme-border rounded px-2 py-1 theme-bg-card body2-mobile sm:body2-tablet lg:body2-desktop">
            <Search className="w-4 h-4 icon-disabled" />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Tìm tên / slug / ID"
              className="outline-none bg-transparent body2-mobile sm:body2-tablet lg:body2-desktop placeholder:theme-text-secondary"
            />
          </div>
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Khu vực
            </label>
            <select
              value={filterArea}
              onChange={(e) => setFilterArea(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Tất cả</option>
              {areas.map((a) => (
                <option key={a}>{a}</option>
              ))}
            </select>
          </div>
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Loại
            </label>
            <select
              value={filterType}
              onChange={(e) =>
                setFilterType(e.target.value as Attraction["feature_type"] | "")
              }
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Tất cả</option>
              <option value="park">Park</option>
              <option value="museum">Museum</option>
              <option value="historical">Historical</option>
              <option value="other">Other</option>
            </select>
          </div>
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Accessibility
            </label>
            <select
              value={filterAccess}
              onChange={(e) => setFilterAccess(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Tất cả</option>
              {accessibilityTags.map((a) => (
                <option key={a}>{a}</option>
              ))}
            </select>
          </div>
          <div className="flex flex-col w-28">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Giá ≥
            </label>
            <input
              value={priceMin}
              onChange={(e) => setPriceMin(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
              placeholder="Min"
            />
          </div>
          <div className="flex flex-col w-28">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Giá ≤
            </label>
            <input
              value={priceMax}
              onChange={(e) => setPriceMax(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
              placeholder="Max"
            />
          </div>
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Khung giờ
            </label>
            <select
              value={filterHours}
              onChange={(e) => setFilterHours(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Tất cả</option>
              <option value="morning">Morning</option>
              <option value="afternoon">Afternoon</option>
              <option value="evening">Evening</option>
            </select>
          </div>
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Trạng thái
            </label>
            <select
              value={filterStatus}
              onChange={(e) =>
                setFilterStatus(e.target.value as AttractionStatus | "")
              }
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Tất cả</option>
              <option value="published">Published</option>
              <option value="draft">Draft</option>
              <option value="archived">Archived</option>
              <option value="disabled">Disabled</option>
            </select>
          </div>
          <button
            onClick={clearFilters}
            className="caption-mobile sm:caption-tablet lg:caption-desktop theme-border rounded px-3 py-1 theme-bg-card hover:opacity-80"
          >
            Đặt lại
          </button>
        </div>
      </div>

      {/* KPIs */}
      <div>
        {sectionHeader("Chỉ số (KPI)", "kpi", <Filter className="w-4 h-4" />)}
        {!collapsed["kpi"] && (
          <div className="grid sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-5 gap-4">
            {renderKPI(
              "Visitors hôm nay",
              kpis.visitorsToday,
              <Users className="w-4 h-4" />
            )}
            {renderKPI(
              "Thời lượng TB",
              `${kpis.avgVisitDuration.toFixed(0)}p`,
              <Clock className="w-4 h-4" />
            )}
            {renderKPI(
              "Occupancy slots",
              `${kpis.occupancyPercent.toFixed(1)}%`,
              <Layers3 className="w-4 h-4" />
            )}
            {renderKPI(
              "Doanh thu (mock)",
              fmtCurrency(Math.round(kpis.revenue)),
              <DollarSign className="w-4 h-4" />
            )}
            {renderKPI(
              "Review mới",
              kpis.newReviews,
              <Star className="w-4 h-4" />
            )}
          </div>
        )}
      </div>

      {/* Listings */}
      <div>
        {sectionHeader(
          "Danh sách Attraction",
          "listings",
          <Landmark className="w-4 h-4" />,
          <span className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
            {filteredAttractions.length} kết quả
          </span>
        )}
        {!collapsed["listings"] && (
          <div className="flex flex-col gap-3">
            {selectedIds.size > 0 && (
              <div className="theme-border rounded theme-bg-card p-2 flex flex-wrap gap-2 items-center caption-mobile sm:caption-tablet lg:caption-desktop">
                <span className="font-medium">{selectedIds.size} đã chọn</span>
                <button
                  onClick={bulkPublish}
                  className="px-2 py-1 rounded bg-green-600 text-white hover:bg-green-700"
                >
                  Xuất bản
                </button>
                <button
                  onClick={bulkArchive}
                  className="px-2 py-1 rounded bg-gray-300 hover:bg-gray-400 dark:bg-gray-600 dark:hover:bg-gray-500 dark:text-white"
                >
                  Lưu trữ
                </button>
                <button
                  onClick={() => setSelectedIds(new Set())}
                  className="px-2 py-1 rounded theme-border hover:opacity-80"
                >
                  Bỏ chọn
                </button>
              </div>
            )}
            <div className="overflow-auto theme-border rounded theme-bg-card">
              <table className="w-full border-collapse body2-mobile sm:body2-tablet lg:body2-desktop">
                <thead className="bg-gray-50 dark:bg-gray-800/60">
                  <tr className="text-left theme-text-secondary caption-mobile sm:caption-tablet lg:caption-desktop">
                    <th className="p-2">
                      <input
                        type="checkbox"
                        checked={
                          filteredAttractions.length > 0 &&
                          filteredAttractions.every((a) =>
                            selectedIds.has(a.id)
                          )
                        }
                        onChange={() => toggleSelectAll(filteredAttractions)}
                      />
                    </th>
                    <th className="p-2">Ảnh</th>
                    <th className="p-2">Tiêu đề / Slug</th>
                    <th className="p-2">Loại</th>
                    <th className="p-2">Khung giờ</th>
                    <th className="p-2">Visit (p)</th>
                    <th className="p-2">Slot kế</th>
                    <th className="p-2">Giá</th>
                    <th className="p-2">Rating</th>
                    <th className="p-2">Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredAttractions.map((a) => (
                    <tr
                      key={a.id}
                      className="border-t theme-border hover:bg-gray-50 dark:hover:bg-gray-800/40 transition-colors"
                    >
                      <td className="p-2">
                        <input
                          type="checkbox"
                          checked={selectedIds.has(a.id)}
                          onChange={() => toggleSelectOne(a.id)}
                        />
                      </td>
                      <td className="p-2">
                        <div className="w-20 h-14 bg-gray-100 dark:bg-gray-700 rounded overflow-hidden flex items-center justify-center">
                          {a.thumbnail_url ? (
                            <img
                              src={a.thumbnail_url}
                              alt={a.title}
                              className="object-cover w-full h-full"
                              loading="lazy"
                            />
                          ) : (
                            <span className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                              Không ảnh
                            </span>
                          )}
                        </div>
                      </td>
                      <td className="p-2 align-top">
                        <div className="flex flex-col gap-0.5">
                          <button className="text-blue-600 dark:text-blue-400 hover:underline font-medium caption-mobile sm:caption-tablet lg:caption-desktop text-left">
                            {a.title}
                          </button>
                          <span className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                            {a.slug}
                          </span>
                          {statusBadge(a.status)}
                        </div>
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        <span
                          className={cx(
                            "px-2 py-0.5 rounded overline-mobile sm:overline-tablet lg:overline-desktop",
                            a.feature_type === "park"
                              ? "bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-300"
                              : a.feature_type === "museum"
                              ? "bg-indigo-50 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300"
                              : a.feature_type === "historical"
                              ? "bg-amber-50 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300"
                              : "bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300"
                          )}
                        >
                          {a.feature_type}
                        </span>
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {["morning", "afternoon", "evening"]
                          .filter(
                            (k) =>
                              a.opening_hours[k as keyof typeof a.opening_hours]
                          )
                          .join(" / ") || "—"}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {a.average_visit_minutes}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {a.next_available_slot
                          ? a.next_available_slot.slice(5, 16).replace("T", " ")
                          : "—"}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop whitespace-nowrap">
                        {fmtCurrency(a.price_min, a.price_currency)}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {a.rating_average.toFixed(1)}
                      </td>
                      <td className="p-2 align-top">
                        <div className="flex flex-wrap gap-1">
                          {[
                            { ic: Pencil, t: "Edit" },
                            { ic: CalendarDays, t: "Slots" },
                            { ic: BookOpen, t: "Bookings" },
                            { ic: Video, t: "Virtual" },
                            { ic: Power, t: "Publish" },
                            { ic: Archive, t: "Archive" },
                          ].map((act, i) => {
                            const Icon = act.ic;
                            return (
                              <button
                                key={i}
                                className="p-1 hover:text-blue-600 dark:hover:text-blue-400"
                                title={act.t}
                              >
                                <Icon className="w-4 h-4" />
                              </button>
                            );
                          })}
                        </div>
                      </td>
                    </tr>
                  ))}
                  {filteredAttractions.length === 0 && (
                    <tr>
                      <td
                        colSpan={10}
                        className="p-4 text-center caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary"
                      >
                        Không tìm thấy attraction
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>

      {/* Time-slot Snapshot */}
      <div>
        {sectionHeader(
          "Time-slots (7 ngày)",
          "slots",
          <CalendarDays className="w-4 h-4" />
        )}
        {!collapsed["slots"] && (
          <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-4">
            <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-4">
              {next7.map((s) => {
                const remaining = s.capacity - s.booked;
                const dt = new Date(s.datetime);
                const label = `${dt.toISOString().substring(5, 10)} ${dt
                  .toISOString()
                  .substring(11, 16)}`;
                const color = s.blocked
                  ? "border-red-300"
                  : remaining <= 0
                  ? "border-gray-300"
                  : remaining < 10
                  ? "border-amber-300"
                  : "border-green-300";
                return (
                  <div
                    key={s.id}
                    className={cx(
                      "theme-border rounded p-3 flex flex-col gap-2 bg-gray-50 dark:bg-gray-800/40 caption-mobile sm:caption-tablet lg:caption-desktop",
                      color
                    )}
                  >
                    <div className="flex items-center justify-between">
                      <span className="font-semibold">{label}</span>
                      <span
                        className={cx(
                          "px-2 py-0.5 rounded overline-mobile sm:overline-tablet lg:overline-desktop",
                          s.blocked
                            ? "bg-red-200 text-red-800 dark:bg-red-900/40 dark:text-red-300"
                            : remaining <= 0
                            ? "bg-gray-300 text-gray-700 dark:bg-gray-700 dark:text-gray-300"
                            : remaining < 10
                            ? "bg-amber-200 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300"
                            : "bg-green-200 text-green-800 dark:bg-green-900/40 dark:text-green-300"
                        )}
                      >
                        {s.blocked ? "BLOCK" : `${remaining} left`}
                      </span>
                    </div>
                    <div className="flex gap-3 overline-mobile sm:overline-tablet lg:overline-desktop">
                      <span>Cap: {s.capacity}</span>
                      <span>Booked: {s.booked}</span>
                    </div>
                    <div className="flex flex-wrap gap-1 pt-1">
                      <button className="px-2 py-0.5 rounded bg-red-600 text-white hover:bg-red-700 overline-mobile sm:overline-tablet lg:overline-desktop">
                        Block
                      </button>
                      <button className="px-2 py-0.5 rounded bg-green-600 text-white hover:bg-green-700 overline-mobile sm:overline-tablet lg:overline-desktop">
                        +Cap
                      </button>
                      <button className="px-2 py-0.5 rounded bg-indigo-100 hover:bg-indigo-200 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300 overline-mobile sm:overline-tablet lg:overline-desktop">
                        Info
                      </button>
                      <button className="px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-600 hover:bg-gray-300 dark:hover:bg-gray-500 overline-mobile sm:overline-tablet lg:overline-desktop">
                        Msg
                      </button>
                    </div>
                  </div>
                );
              })}
              {next7.length === 0 && (
                <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                  Không có slot
                </div>
              )}
            </div>
            <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
              (Giả lập) – click hành động để quản lý slot trong tương lai.
            </div>
          </div>
        )}
      </div>

      {/* Visitor Flow & Permits */}
      <div>
        {sectionHeader(
          "Giấy phép & Tuân thủ",
          "permits",
          <Shield className="w-4 h-4" />
        )}
        {!collapsed["permits"] && (
          <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-6">
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3 md:col-span-2">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Trạng thái giấy phép
              </h4>
              <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
                {permits.map((p) => {
                  const cls =
                    p.status === "valid"
                      ? "bg-green-50 dark:bg-green-900/30 border-green-200 dark:border-green-700 text-green-700 dark:text-green-300"
                      : p.status === "expired"
                      ? "bg-red-50 dark:bg-red-900/30 border-red-200 dark:border-red-700 text-red-700 dark:text-red-300"
                      : "bg-amber-50 dark:bg-amber-900/30 border-amber-200 dark:border-amber-700 text-amber-700 dark:text-amber-300";
                  return (
                    <div
                      key={p.id}
                      className={cx(
                        "border rounded p-3 flex flex-col gap-1 caption-mobile sm:caption-tablet lg:caption-desktop",
                        cls
                      )}
                    >
                      <span className="font-semibold line-clamp-1">
                        {p.name}
                      </span>
                      <span>Trạng thái: {p.status}</span>
                      {p.expires_on && <span>Hết hạn: {p.expires_on}</span>}
                      <span>Yêu cầu: {p.required ? "Có" : "Không"}</span>
                      <div className="flex gap-2 pt-1">
                        <button className="px-2 py-0.5 rounded bg-indigo-600 text-white hover:bg-indigo-700">
                          Upload
                        </button>
                        <button className="px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-600 hover:bg-gray-300 dark:hover:bg-gray-500">
                          Review
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Ghi chú tuân thủ
              </h4>
              <ul className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                <li className="flex items-center gap-2">
                  <Check className="w-3 h-3 text-green-600" /> PCCC hợp lệ
                </li>
                <li className="flex items-center gap-2">
                  <AlertTriangle className="w-3 h-3 text-amber-600" /> Chờ duyệt
                  giấy phép sự kiện
                </li>
                <li className="flex items-center gap-2">
                  <XCircle className="w-3 h-3 text-red-600" /> Vệ sinh môi
                  trường hết hạn
                </li>
              </ul>
              <div className="flex gap-2 pt-1">
                <button className="flex-1 px-3 py-2 rounded theme-border hover:opacity-80 caption-mobile sm:caption-tablet lg:caption-desktop">
                  Tải giấy phép
                </button>
                <button className="flex-1 px-3 py-2 rounded theme-border hover:opacity-80 caption-mobile sm:caption-tablet lg:caption-desktop">
                  Yêu cầu kiểm tra
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Pricing & Packages */}
      <div>
        {sectionHeader(
          "Pricing & Packages",
          "packages",
          <Tag className="w-4 h-4" />
        )}
        {!collapsed["packages"] && (
          <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-4">
            <div className="flex flex-wrap gap-2">
              <button className="btn-primary btn-text-responsive flex items-center gap-2">
                <Plus className="w-4 h-4" /> Thêm Package
              </button>
              <button className="btn-outline btn-text-responsive flex items-center gap-2">
                <Sparkles className="w-4 h-4" /> Timed Entry
              </button>
              <button className="btn-outline btn-text-responsive flex items-center gap-2">
                <Layers3 className="w-4 h-4" /> Enable Capacity
              </button>
            </div>
            <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-4">
              {packagesPreview.map((p) => {
                const a = attractions.find((x) => x.id === p.attraction_id)!;
                return (
                  <div
                    key={p.id}
                    className="theme-border rounded p-3 bg-gray-50 dark:bg-gray-800/40 flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop"
                  >
                    <div className="flex items-center justify-between">
                      <span className="font-semibold line-clamp-1">
                        {p.name}
                      </span>
                      <span className="overline-mobile sm:overline-tablet lg:overline-desktop">
                        #{p.id}
                      </span>
                    </div>
                    <div className="overline-mobile sm:overline-tablet lg:overline-desktop">
                      {a.title}
                    </div>
                    <div>
                      Giá: <strong>{fmtCurrency(p.price, p.currency)}</strong>
                    </div>
                    <div>
                      Loại: {p.type}{" "}
                      {p.capacity_control && "• capacity control"}
                    </div>
                    <div className="line-clamp-1">
                      Bao gồm: {p.includes.join(", ")}
                    </div>
                    <div className="flex gap-2 pt-1">
                      <button className="flex-1 px-2 py-0.5 rounded theme-border hover:opacity-80">
                        Sửa
                      </button>
                      <button className="flex-1 px-2 py-0.5 rounded theme-border hover:opacity-80">
                        Giá
                      </button>
                    </div>
                  </div>
                );
              })}
              {packagesPreview.length === 0 && (
                <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                  Không có package
                </div>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Reviews & Tips */}
      <div>
        {sectionHeader(
          "Reviews & Visitor Tips",
          "reviews",
          <Star className="w-4 h-4" />
        )}
        {!collapsed["reviews"] && (
          <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-6">
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-4 md:col-span-2">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Đánh giá
              </h4>
              <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {reviewsPreview.map((r) => {
                  const a = attractions.find((x) => x.id === r.attraction_id)!;
                  return (
                    <div
                      key={r.id}
                      className="theme-border rounded p-3 flex flex-col gap-2 bg-gray-50 dark:bg-gray-800/40"
                    >
                      <div className="flex items-center justify-between">
                        <span className="caption-mobile sm:caption-tablet lg:caption-desktop font-semibold line-clamp-1">
                          {a.title}
                        </span>
                        <span className="flex items-center gap-1 caption-mobile sm:caption-tablet lg:caption-desktop">
                          <Star className="w-3 h-3 text-yellow-500 fill-yellow-500" />
                          {r.rating.toFixed(1)}
                        </span>
                      </div>
                      <div className="flex flex-wrap gap-2 overline-mobile sm:overline-tablet lg:overline-desktop">
                        <span>Beauty {r.aspects.beauty.toFixed(1)}</span>
                        <span>Culture {r.aspects.culture.toFixed(1)}</span>
                        <span>Acc {r.aspects.accessibility.toFixed(1)}</span>
                      </div>
                      <div className="body2-mobile sm:body2-tablet lg:body2-desktop theme-text-secondary line-clamp-3">
                        {r.content}
                      </div>
                      <div className="flex gap-2">
                        <button className="flex-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-border rounded px-2 py-0.5 hover:opacity-80">
                          Reply
                        </button>
                        <button className="flex-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-border rounded px-2 py-0.5 hover:opacity-80">
                          Flag
                        </button>
                      </div>
                    </div>
                  );
                })}
                {reviewsPreview.length === 0 && (
                  <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                    Không có đánh giá
                  </div>
                )}
              </div>
            </div>
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Visitor Tips
              </h4>
              <div className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                {tipsPreview.map((t) => {
                  const a = attractions.find((x) => x.id === t.attraction_id)!;
                  return (
                    <div
                      key={t.id}
                      className="theme-border rounded p-2 bg-gray-50 dark:bg-gray-800/40 flex flex-col gap-1"
                    >
                      <span className="font-semibold line-clamp-1">
                        {a.title}
                      </span>
                      <span className="line-clamp-2">{t.content}</span>
                      <button className="self-start px-2 py-0.5 rounded bg-blue-600 text-white hover:bg-blue-700 overline-mobile sm:overline-tablet lg:overline-desktop">
                        Post
                      </button>
                    </div>
                  );
                })}
                {tipsPreview.length === 0 && (
                  <span className="theme-text-secondary">Chưa có tips</span>
                )}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Virtual Tours & Media */}
      <div>
        {sectionHeader(
          "Virtual Tours & Media",
          "media",
          <Video className="w-4 h-4" />
        )}
        {!collapsed["media"] && (
          <div className="grid md:grid-cols-2 gap-6">
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Virtual Tours
              </h4>
              <div className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                <div className="theme-border rounded p-3 bg-gray-50 dark:bg-gray-800/40 flex items-center justify-between">
                  <span>Khu trưng bày chính</span>
                  <button className="px-2 py-0.5 rounded bg-blue-600 text-white hover:bg-blue-700">
                    Xem
                  </button>
                </div>
                <div className="theme-border rounded p-3 bg-gray-50 dark:bg-gray-800/40 flex items-center justify-between">
                  <span>Tháp quan sát</span>
                  <button className="px-2 py-0.5 rounded bg-blue-600 text-white hover:bg-blue-700">
                    Xem
                  </button>
                </div>
                <button className="btn-outline btn-text-responsive flex items-center gap-2">
                  <Plus className="w-4 h-4" /> Thêm virtual tour
                </button>
              </div>
            </div>
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Media & Checklist
              </h4>
              <ul className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                <li className="flex items-center gap-2">
                  <Check className="w-3 h-3 text-green-600" /> Ảnh tiêu đề
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-3 h-3 text-green-600" /> Gallery ≥ 5 ảnh
                </li>
                <li className="flex items-center gap-2">
                  <AlertTriangle className="w-3 h-3 text-amber-600" /> Thiếu
                  video 360
                </li>
                <li className="flex items-center gap-2">
                  <AlertTriangle className="w-3 h-3 text-amber-600" /> Chưa thêm
                  mô tả SEO
                </li>
              </ul>
              <div className="flex gap-2 pt-1">
                <button className="flex-1 px-3 py-2 rounded theme-border hover:opacity-80 caption-mobile sm:caption-tablet lg:caption-desktop">
                  Thêm media
                </button>
                <button className="flex-1 px-3 py-2 rounded theme-border hover:opacity-80 caption-mobile sm:caption-tablet lg:caption-desktop">
                  Cập nhật SEO
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Alerts & Activity */}
      <div>
        {sectionHeader(
          "Cảnh báo & Hoạt động",
          "alertsActivity",
          <ShieldAlert className="w-4 h-4" />
        )}
        {!collapsed["alertsActivity"] && (
          <div className="grid md:grid-cols-2 gap-6">
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Cảnh báo
              </h4>
              <div className="flex flex-col gap-1 caption-mobile sm:caption-tablet lg:caption-desktop">
                {alertsRecent.length === 0 && (
                  <span className="theme-text-secondary">
                    Không có cảnh báo
                  </span>
                )}
                {alertsRecent.map((a) => {
                  const cls =
                    a.severity === "critical"
                      ? "bg-red-50 border-red-200 text-red-700 dark:bg-red-900/30 dark:border-red-700 dark:text-red-300"
                      : a.severity === "warn"
                      ? "bg-amber-50 border-amber-200 text-amber-700 dark:bg-amber-900/30 dark:border-amber-700 dark:text-amber-300"
                      : "bg-blue-50 border-blue-200 text-blue-700 dark:bg-blue-900/30 dark:border-blue-700 dark:text-blue-300";
                  return (
                    <div
                      key={a.id}
                      className={cx(
                        "theme-border rounded px-2 py-1 flex items-center gap-2",
                        cls
                      )}
                    >
                      {a.severity === "critical" ? (
                        <XCircle className="w-3 h-3" />
                      ) : a.severity === "warn" ? (
                        <AlertTriangle className="w-3 h-3" />
                      ) : (
                        <ShieldAlert className="w-3 h-3" />
                      )}
                      <span className="flex-1 line-clamp-1">{a.message}</span>
                      <button className="px-2 py-0.5 rounded bg-white/70 dark:bg-white/10 hover:bg-white dark:hover:bg-white/20 border border-white/60 dark:border-white/20">
                        Xem
                      </button>
                    </div>
                  );
                })}
              </div>
            </div>
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Hoạt động gần đây
              </h4>
              <div className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                {activitiesRecent.map((act) => {
                  const a = attractions.find((x) => x.id === act.attraction_id);
                  return (
                    <div
                      key={act.id}
                      className="theme-border rounded px-2 py-1 bg-gray-50 dark:bg-gray-800/40 flex items-center gap-2"
                    >
                      <History className="w-3 h-3 text-gray-500 dark:text-gray-400" />
                      <span className="flex-1 line-clamp-1">
                        {act.action} {a ? `(${a.title})` : ""}
                      </span>
                      <span className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
                        {act.created_at.slice(11, 16)}
                      </span>
                    </div>
                  );
                })}
                {activitiesRecent.length === 0 && (
                  <span className="theme-text-secondary">
                    Không có hoạt động
                  </span>
                )}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary flex flex-wrap gap-4">
        <span>UI tĩnh • dữ liệu mock • sẽ tích hợp API /provider/... sau.</span>
        <span>Legend slot: Xanh tốt • Vàng thấp • Xám full • Đỏ block.</span>
      </div>
    </div>
  );
};

export default DashboardAttractionPage;
