import React, { useState, useMemo } from "react";
import {
  Plus,
  Search,
  Filter,
  Star,
  StarOff,
  Globe,
  Eye,
  Pencil,
  CalendarDays,
  Copy,
  Power,
  Archive,
  ChevronDown,
  ChevronUp,
  Clock,
  MapPin,
  BookOpen,
  MessageCircle,
  XCircle,
  TriangleAlert,
  Layers,
  Image as ImageIcon,
  Tag,
  RefreshCw,
  History,
  DollarSign,
} from "lucide-react";

/* ===================== Types ===================== */
type TourStatus = "draft" | "published" | "archived" | "disabled";
interface Tour {
  id: number;
  title: string;
  slug: string;
  area: string;
  status: TourStatus;
  visibility: "public" | "private";
  featured: boolean;
  thumbnail_url?: string | null;
  price_min: number;
  currency: string;
  rating_average: number;
  rating_count: number;
  capacity: number;
  confirmed_pax: number;
  next_departure?: string | null;
  guide_languages: string[];
  has_images: boolean;
  has_price_option: boolean;
  auto_accept: boolean;
  has_cancellation_policy: boolean;
  seo_title?: string | null;
  image_count: number;
  created_at: string;
  updated_at: string;
}

interface Booking {
  id: number;
  tour_id: number;
  leader_name: string;
  start_date: string;
  pax: number;
  total_price: number;
  currency: string;
  payment_status: "pending" | "paid" | "partial" | "refunded";
  booking_status: "pending" | "confirmed" | "cancelled" | "hold";
  hold_until?: string | null;
}

interface InventorySlot {
  date: string;
  tour_id: number;
  available_count: number;
  confirmed_pax: number;
  blocked: boolean;
  price_override?: number | null;
}

interface PriceOption {
  id: number;
  tour_id: number;
  name: string;
  price: number;
  currency: string;
  per_person: boolean;
  is_addon: boolean;
  deposit_type: "none" | "percent" | "fixed";
  deposit_value?: number;
  tax_included: boolean;
}

interface Review {
  id: number;
  tour_id: number;
  author: string;
  rating: number;
  content: string;
  created_at: string;
}

interface ItineraryDay {
  tour_id: number;
  day_number: number;
  activities: Array<{
    time?: string;
    location?: string;
    desc: string;
  }>;
}

interface GuideAssignment {
  id: number;
  tour_id: number;
  guide_name: string;
  language: string;
  departure_date: string;
}

interface AlertItem {
  id: number;
  type:
    | "low_seats"
    | "hold_expiring"
    | "doc_expire"
    | "price_change"
    | "policy_missing"
    | "upcoming_departure";
  message: string;
  severity: "info" | "warn" | "critical";
  created_at: string;
}

interface ActivityLog {
  id: number;
  action:
    | "publish"
    | "unpublish"
    | "price_update"
    | "booking_confirm"
    | "booking_cancel"
    | "clone"
    | "media_upload"
    | "seo_update";
  tour_id?: number;
  meta?: Record<string, unknown>;
  created_at: string;
}

/* ===================== Mock Seed ===================== */
const areas = ["Hà Nội", "TP.HCM", "Đà Nẵng", "Quảng Ninh", "Thanh Hóa"];
const guideLangs = ["vi", "en", "fr", "de", "es", "jp"];

function randomArray<T>(arr: T[], min = 1, max = 3): T[] {
  const copy = [...arr];
  const count = Math.max(
    min,
    Math.min(max, Math.floor(Math.random() * max) + 1)
  );
  const result: T[] = [];
  while (result.length < count && copy.length) {
    const idx = Math.floor(Math.random() * copy.length);
    result.push(copy.splice(idx, 1)[0]);
  }
  return result;
}

function genTours(): Tour[] {
  const list: Tour[] = [];
  const now = Date.now();
  for (let i = 1; i <= 28; i++) {
    const statusPool: TourStatus[] = [
      "published",
      "draft",
      "archived",
      "disabled",
    ];
    const status = statusPool[Math.floor(Math.random() * statusPool.length)];
    const hasImages = Math.random() > 0.15;
    const hasPriceOpt = Math.random() > 0.1;
    const autoAccept = Math.random() > 0.4;
    const hasPolicy = Math.random() > 0.2;
    const nextDeparture =
      Math.random() > 0.25
        ? new Date(now + Math.random() * 14 * 86400000)
            .toISOString()
            .substring(0, 10)
        : null;
    list.push({
      id: i,
      title: `Tour Adventure #${i}`,
      slug: `tour-adventure-${i}`,
      area: areas[i % areas.length],
      status,
      visibility: Math.random() > 0.2 ? "public" : "private",
      featured: i % 5 === 0,
      thumbnail_url: hasImages
        ? `https://picsum.photos/seed/tour-${i}/180/120.webp`
        : null,
      price_min: 1000000 + ((i * 137000) % 4000000),
      currency: "VND",
      rating_average: parseFloat((3 + Math.random() * 2).toFixed(1)),
      rating_count: 10 + Math.floor(Math.random() * 120),
      capacity: 20 + (i % 5) * 10,
      confirmed_pax: Math.floor(Math.random() * 15),
      next_departure: nextDeparture,
      guide_languages: randomArray(guideLangs, 1, 3),
      has_images: hasImages,
      has_price_option: hasPriceOpt,
      auto_accept: autoAccept,
      has_cancellation_policy: hasPolicy,
      seo_title: Math.random() > 0.2 ? `SEO Title Tour #${i}` : null,
      image_count: hasImages ? 4 + (i % 5) : 0,
      created_at: new Date(now - i * 86400000).toISOString(),
      updated_at: new Date(now - i * 43200000).toISOString(),
    });
  }
  return list;
}

function genBookings(tours: Tour[]): Booking[] {
  const list: Booking[] = [];
  const now = Date.now();
  for (let i = 1; i <= 32; i++) {
    const tour = tours[Math.floor(Math.random() * tours.length)];
    const startDate = new Date(now + (Math.random() * 10 - 3) * 86400000)
      .toISOString()
      .substring(0, 10);
    const statusPool: Booking["booking_status"][] = [
      "pending",
      "confirmed",
      "hold",
      "cancelled",
    ];
    const booking_status =
      statusPool[Math.floor(Math.random() * statusPool.length)];
    list.push({
      id: 1000 + i,
      tour_id: tour.id,
      leader_name: `Guest ${i}`,
      start_date: startDate,
      pax: 2 + (i % 4),
      total_price: 1200000 + ((i * 330000) % 3000000),
      currency: "VND",
      payment_status: Math.random() > 0.5 ? "pending" : "paid",
      booking_status,
      hold_until:
        booking_status === "hold"
          ? new Date(Date.now() + 2 * 3600000).toISOString()
          : null,
    });
  }
  return list;
}

function genInventory(tours: Tour[]): InventorySlot[] {
  const now = new Date();
  const slots: InventorySlot[] = [];
  for (const tour of tours) {
    for (let d = 0; d < 35; d++) {
      const date = new Date(now.getTime() + d * 86400000)
        .toISOString()
        .substring(0, 10);
      if (Math.random() > 0.65) continue;
      const confirmed = Math.floor(
        Math.random() * Math.min(10, tour.capacity / 2)
      );
      slots.push({
        date,
        tour_id: tour.id,
        available_count: tour.capacity - confirmed,
        confirmed_pax: confirmed,
        blocked: Math.random() > 0.92,
        price_override: Math.random() > 0.85 ? tour.price_min * 1.1 : null,
      });
    }
  }
  return slots;
}

function genPriceOptions(tours: Tour[]): PriceOption[] {
  const arr: PriceOption[] = [];
  let id = 1;
  tours.forEach((t) => {
    const count = 1 + (t.id % 3);
    for (let i = 0; i < count; i++) {
      const isAddon = i === count - 1 && Math.random() > 0.6;
      arr.push({
        id: id++,
        tour_id: t.id,
        name: isAddon ? "Premium Meal" : i === 0 ? "Adult" : "Child",
        price: isAddon ? 250000 : t.price_min + i * 150000,
        currency: "VND",
        per_person: true,
        is_addon: isAddon,
        deposit_type: Math.random() > 0.7 ? "percent" : "none",
        deposit_value: Math.random() > 0.7 ? 20 : undefined,
        tax_included: true,
      });
    }
  });
  return arr;
}

function genReviews(tours: Tour[]): Review[] {
  const arr: Review[] = [];
  let id = 1;
  tours.slice(0, 8).forEach((t) => {
    const n = 1 + (t.id % 3);
    for (let i = 0; i < n; i++) {
      arr.push({
        id: id++,
        tour_id: t.id,
        author: `Reviewer ${id}`,
        rating: parseFloat((3 + Math.random() * 2).toFixed(1)),
        content: "Great experience! (mock)",
        created_at: new Date(Date.now() - i * 3600000).toISOString(),
      });
    }
  });
  return arr.sort(
    (a, b) =>
      new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
  );
}

function genItinerary(tours: Tour[]): ItineraryDay[] {
  const arr: ItineraryDay[] = [];
  tours.slice(0, 6).forEach((t) => {
    arr.push({
      tour_id: t.id,
      day_number: 1,
      activities: [
        {
          time: "08:00",
          location: "Hotel Lobby",
          desc: "Check-in and welcome briefing.",
        },
        { time: "10:00", location: "Old Quarter", desc: "Walking tour." },
      ],
    });
    arr.push({
      tour_id: t.id,
      day_number: 2,
      activities: [
        { time: "08:30", location: "Harbor", desc: "Boat departure." },
        { time: "12:00", location: "Island", desc: "Lunch on island." },
      ],
    });
  });
  return arr;
}

function genGuideAssignments(tours: Tour[]): GuideAssignment[] {
  const arr: GuideAssignment[] = [];
  let id = 1;
  tours.slice(0, 8).forEach((t) => {
    if (!t.next_departure) return;
    arr.push({
      id: id++,
      tour_id: t.id,
      guide_name: `Guide ${id}`,
      language: randomArray(guideLangs, 1, 1)[0],
      departure_date: t.next_departure,
    });
  });
  return arr;
}

function genAlerts(tours: Tour[], bookings: Booking[]): AlertItem[] {
  const arr: AlertItem[] = [];
  let id = 1;
  tours.forEach((t) => {
    if (t.capacity - t.confirmed_pax < 5 && t.status === "published") {
      arr.push({
        id: id++,
        type: "low_seats",
        message: `Low seats on ${t.title}`,
        severity: "warn",
        created_at: new Date().toISOString(),
      });
    }
    if (t.auto_accept && !t.has_cancellation_policy) {
      arr.push({
        id: id++,
        type: "policy_missing",
        message: `Missing cancellation policy: ${t.title}`,
        severity: "info",
        created_at: new Date().toISOString(),
      });
    }
  });
  bookings.forEach((b) => {
    if (
      b.booking_status === "hold" &&
      b.hold_until &&
      new Date(b.hold_until).getTime() - Date.now() < 3600000 * 2
    ) {
      arr.push({
        id: id++,
        type: "hold_expiring",
        message: `Hold expiring booking #${b.id}`,
        severity: "critical",
        created_at: new Date().toISOString(),
      });
    }
  });
  return arr;
}

function genActivities(tours: Tour[]): ActivityLog[] {
  const actions: ActivityLog["action"][] = [
    "publish",
    "unpublish",
    "price_update",
    "booking_confirm",
    "booking_cancel",
    "clone",
    "media_upload",
    "seo_update",
  ];
  const arr: ActivityLog[] = [];
  let id = 1;
  for (let i = 0; i < 28; i++) {
    const action = actions[Math.floor(Math.random() * actions.length)];
    const t = tours[Math.floor(Math.random() * tours.length)];
    arr.push({
      id: id++,
      action,
      tour_id: t.id,
      meta: { title: t.title },
      created_at: new Date(Date.now() - i * 3600000).toISOString(),
    });
  }
  return arr;
}

/* ===================== Utils ===================== */
const fmtCurrency = (v: number, currency = "VND") =>
  new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency,
    minimumFractionDigits: 0,
  }).format(v);

const cx = (...cls: Array<string | false | null | undefined>) =>
  cls.filter(Boolean).join(" ");

/* ===================== Component ===================== */
const DashboardTourPage: React.FC = () => {
  const [tours] = useState(() => genTours());
  const [bookings] = useState(() => genBookings(tours));
  const [inventory] = useState(() => genInventory(tours));
  const [priceOptions] = useState(() => genPriceOptions(tours));
  const [reviews] = useState(() => genReviews(tours));
  const [itineraryDays] = useState(() => genItinerary(tours));
  const [guideAssignments] = useState(() => genGuideAssignments(tours));
  const [alerts] = useState(() => genAlerts(tours, bookings));
  const [activities] = useState(() => genActivities(tours));

  /* Filters */
  const [search, setSearch] = useState("");
  const [filterArea, setFilterArea] = useState("");
  const [filterStatus, setFilterStatus] = useState<TourStatus | "">("");
  const [filterRating, setFilterRating] = useState("");
  const [filterFeatured, setFilterFeatured] = useState(false);
  const [filterGuideLang, setFilterGuideLang] = useState("");
  const [priceMin, setPriceMin] = useState("");
  const [priceMax, setPriceMax] = useState("");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");

  const [selectedTourIds, setSelectedTourIds] = useState<Set<number>>(
    () => new Set()
  );
  const [collapsedSections, setCollapsedSections] = useState<
    Record<string, boolean>
  >({});

  const toggleCollapse = (k: string) =>
    setCollapsedSections((p) => ({ ...p, [k]: !p[k] }));

  const toggleSelectAll = (visible: Tour[]) => {
    const ids = visible.map((t) => t.id);
    const all = ids.every((id) => selectedTourIds.has(id));
    setSelectedTourIds(all ? new Set() : new Set(ids));
  };

  const toggleSelectOne = (id: number) =>
    setSelectedTourIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });

  /* Filtering */
  const filteredTours = useMemo(
    () =>
      tours.filter((t) => {
        if (search) {
          const q = search.toLowerCase();
          if (
            !t.title.toLowerCase().includes(q) &&
            !t.slug.toLowerCase().includes(q) &&
            !String(t.id).includes(q)
          )
            return false;
        }
        if (filterArea && t.area !== filterArea) return false;
        if (filterStatus && t.status !== filterStatus) return false;
        if (filterRating && t.rating_average < parseFloat(filterRating))
          return false;
        if (filterFeatured && !t.featured) return false;
        if (filterGuideLang && !t.guide_languages.includes(filterGuideLang))
          return false;
        if (priceMin && t.price_min < parseInt(priceMin, 10)) return false;
        if (priceMax && t.price_min > parseInt(priceMax, 10)) return false;

        if (dateFrom || dateTo) {
          const list = bookings.filter((b) => b.tour_id === t.id);
          const inRange = list.some((b) => {
            const time = new Date(b.start_date).getTime();
            if (dateFrom && time < new Date(dateFrom).getTime()) return false;
            if (dateTo && time > new Date(dateTo).getTime()) return false;
            return true;
          });
          if (!inRange) return false;
        }
        return true;
      }),
    [
      tours,
      search,
      filterArea,
      filterStatus,
      filterRating,
      filterFeatured,
      filterGuideLang,
      priceMin,
      priceMax,
      dateFrom,
      dateTo,
      bookings,
    ]
  );

  /* KPIs */
  const kpis = useMemo(() => {
    const totalTours = tours.length;
    const pendingBookings = bookings.filter(
      (b) => b.booking_status === "pending"
    ).length;
    const today = new Date().toISOString().substring(0, 10);
    const in7 = new Date(Date.now() + 7 * 86400000)
      .toISOString()
      .substring(0, 10);
    const upcomingDepartures = bookings.filter(
      (b) => b.start_date >= today && b.start_date <= in7
    ).length;
    const mrr =
      bookings
        .filter((b) => b.booking_status === "confirmed")
        .reduce((s, b) => s + b.total_price, 0) / 12;
    const cancels = bookings.filter(
      (b) => b.booking_status === "cancelled"
    ).length;
    const cancelRate = bookings.length ? (cancels / bookings.length) * 100 : 0;
    return { totalTours, pendingBookings, upcomingDepartures, mrr, cancelRate };
  }, [tours, bookings]);

  /* Availability */
  const [availabilityTourId, setAvailabilityTourId] = useState(() =>
    tours.length ? tours[0].id : 0
  );
  const availabilitySlots = useMemo(() => {
    const all = inventory.filter((s) => s.tour_id === availabilityTourId);
    const days: { date: string; slot?: InventorySlot }[] = [];
    for (let d = 0; d < 30; d++) {
      const date = new Date(Date.now() + d * 86400000)
        .toISOString()
        .substring(0, 10);
      days.push({ date, slot: all.find((s) => s.date === date) });
    }
    return days;
  }, [availabilityTourId, inventory]);

  /* Derivatives */
  const pendingBookingsShort = useMemo(
    () =>
      bookings
        .filter((b) => b.booking_status === "pending")
        .sort(
          (a, b) =>
            new Date(a.start_date).getTime() - new Date(b.start_date).getTime()
        )
        .slice(0, 8),
    [bookings]
  );
  const recentReviews = useMemo(() => reviews.slice(0, 5), [reviews]);
  const toursMissingSEO = useMemo(
    () =>
      tours
        .filter((t) => !t.seo_title)
        .slice(0, 6)
        .map((t) => ({ id: t.id, title: t.title })),
    [tours]
  );
  const toursMissingThumb = useMemo(
    () =>
      tours
        .filter((t) => !t.thumbnail_url)
        .slice(0, 6)
        .map((t) => ({ id: t.id, title: t.title })),
    [tours]
  );
  const itineraryPreview = useMemo(() => {
    const map = new Map<number, ItineraryDay[]>();
    itineraryDays.forEach((d) => {
      const arr = map.get(d.tour_id) || [];
      arr.push(d);
      map.set(d.tour_id, arr);
    });
    return Array.from(map.entries())
      .slice(0, 5)
      .map(([tour_id, days]) => ({
        tour_id,
        days: days
          .sort((a, b) => a.day_number - b.day_number)
          .slice(0, 2)
          .map((day) => ({
            day_number: day.day_number,
            activities: day.activities.slice(0, 2),
          })),
      }));
  }, [itineraryDays]);
  const guideAssignmentsUpc = useMemo(
    () => guideAssignments.slice(0, 8),
    [guideAssignments]
  );
  const recentAlerts = useMemo(() => alerts.slice(0, 8), [alerts]);
  const recentActivity = useMemo(() => activities.slice(0, 10), [activities]);

  const priceOptByTour = useMemo(() => {
    const map = new Map<number, PriceOption[]>();
    priceOptions.forEach((p) => {
      const arr = map.get(p.tour_id) || [];
      arr.push(p);
      map.set(p.tour_id, arr);
    });
    return map;
  }, [priceOptions]);

  /* Bulk actions (mock) */
  const performBulkPublish = () => {
    console.log("Bulk publish:", Array.from(selectedTourIds));
    alert("Bulk publish (mock)");
  };
  const performBulkArchive = () => {
    console.log("Bulk archive:", Array.from(selectedTourIds));
    alert("Bulk archive (mock)");
  };
  const clearFilters = () => {
    setSearch("");
    setFilterArea("");
    setFilterStatus("");
    setFilterRating("");
    setFilterFeatured(false);
    setFilterGuideLang("");
    setPriceMin("");
    setPriceMax("");
    setDateFrom("");
    setDateTo("");
  };

  /* UI helpers */
  const statusBadge = (status: TourStatus) => {
    const map: Record<TourStatus, string> = {
      published:
        "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
      draft:
        "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
      archived: "bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-200",
      disabled: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300",
    };
    const label: Record<TourStatus, string> = {
      published: "Đang xuất bản",
      draft: "Nháp",
      archived: "Lưu trữ",
      disabled: "Ngưng",
    };
    return (
      <span
        className={cx(
          "rounded px-2 py-0.5 inline-block caption-mobile sm:caption-tablet lg:caption-desktop font-medium",
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
    const collapsed = collapsedSections[key];
    return (
      <div className="flex items-center gap-2 mb-3">
        <button
          onClick={() => toggleCollapse(key)}
          className="flex items-center gap-2 group"
        >
          <span className="w-6 h-6 inline-flex items-center justify-center rounded theme-bg-secondary text-light-primary dark:text-dark-primary">
            {icon || <Layers className="w-4 h-4" />}
          </span>
          <h3 className="h5-mobile sm:h5-tablet lg:h5-desktop font-semibold">
            {title}
          </h3>
          {collapsed ? (
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

  /* ============== JSX ============== */
  return (
    <div className="p-6 max-w-[1900px] mx-auto flex flex-col gap-8 theme-text-primary">
      {/* Header */}
      <div className="flex flex-col gap-4">
        <div className="flex flex-wrap items-center gap-3">
          <h1 className="h3-mobile sm:h3-tablet lg:h3-desktop font-bold flex items-center gap-2">
            <Layers className="w-6 h-6 icon-brand" />
            Quản lý Tour
          </h1>
          <span className="body2-mobile sm:body2-tablet lg:body2-desktop theme-text-secondary">
            Nhà cung cấp:{" "}
            <strong className="theme-text-primary">Mock Provider Co.</strong>
          </span>
          <button className="ml-auto btn-primary btn-text-responsive flex items-center gap-2">
            <Plus className="w-4 h-4" />
            Tạo Tour
          </button>
        </div>

        {/* Filters */}
        <div className="flex flex-wrap gap-3 items-end">
          <div className="flex items-center gap-2 theme-border rounded px-2 py-1 theme-bg-card body2-mobile sm:body2-tablet lg:body2-desktop">
            <Search className="w-4 h-4 icon-disabled" />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Tìm: tiêu đề / slug / ID"
              className="outline-none bg-transparent placeholder:theme-text-secondary body2-mobile sm:body2-tablet lg:body2-desktop"
            />
          </div>

          {/* Selects */}
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
              Trạng thái
            </label>
            <select
              value={filterStatus}
              onChange={(e) =>
                setFilterStatus(e.target.value as TourStatus | "")
              }
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Tất cả</option>
              <option value="published">Đang xuất bản</option>
              <option value="draft">Nháp</option>
              <option value="archived">Lưu trữ</option>
              <option value="disabled">Ngưng</option>
            </select>
          </div>

          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Rating ≥
            </label>
            <select
              value={filterRating}
              onChange={(e) => setFilterRating(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Bất kỳ</option>
              <option value="3">3.0</option>
              <option value="3.5">3.5</option>
              <option value="4">4.0</option>
              <option value="4.5">4.5</option>
            </select>
          </div>

          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Ngôn ngữ HDV
            </label>
            <select
              value={filterGuideLang}
              onChange={(e) => setFilterGuideLang(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Bất kỳ</option>
              {guideLangs.map((g) => (
                <option key={g}>{g}</option>
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
              Ngày từ
            </label>
            <input
              type="date"
              value={dateFrom}
              onChange={(e) => setDateFrom(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            />
          </div>

          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Ngày đến
            </label>
            <input
              type="date"
              value={dateTo}
              onChange={(e) => setDateTo(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            />
          </div>

          <label className="flex items-center gap-1 caption-mobile sm:caption-tablet lg:caption-desktop select-none theme-text-secondary">
            <input
              type="checkbox"
              checked={filterFeatured}
              onChange={(e) => setFilterFeatured(e.target.checked)}
            />
            Nổi bật
          </label>
          <button
            onClick={clearFilters}
            className="caption-mobile sm:caption-tablet lg:caption-desktop theme-border rounded px-3 py-1 theme-bg-card hover:opacity-80"
          >
            Đặt lại
          </button>
        </div>
      </div>

      {/* KPI */}
      <div>
        {sectionHeader("Chỉ số (KPI)", "kpi", <Filter className="w-4 h-4" />)}
        {!collapsedSections["kpi"] && (
          <div className="grid sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-6 gap-4">
            {renderKPI(
              "Tổng tour",
              kpis.totalTours,
              <Layers className="w-4 h-4" />
            )}
            {renderKPI(
              "Booking chờ",
              kpis.pendingBookings,
              <Clock className="w-4 h-4" />
            )}
            {renderKPI(
              "Khởi hành (7d)",
              kpis.upcomingDepartures,
              <CalendarDays className="w-4 h-4" />
            )}
            {renderKPI(
              "MRR (mock)",
              fmtCurrency(Math.round(kpis.mrr)),
              <DollarSign className="w-4 h-4" />,
              "Ước từ booking confirmed"
            )}
            {renderKPI(
              "Tỷ lệ hủy",
              `${kpis.cancelRate.toFixed(1)}%`,
              <TriangleAlert className="w-4 h-4" />
            )}
            {renderKPI(
              "Published",
              tours.filter((t) => t.status === "published").length,
              <Power className="w-4 h-4" />
            )}
          </div>
        )}
      </div>

      {/* Tours Table */}
      <div>
        {sectionHeader(
          "Danh sách Tour",
          "tours",
          <Layers className="w-4 h-4" />,
          <span className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
            {filteredTours.length} kết quả
          </span>
        )}
        {!collapsedSections["tours"] && (
          <div className="flex flex-col gap-3">
            {selectedTourIds.size > 0 && (
              <div className="flex flex-wrap gap-2 items-center theme-border rounded theme-bg-card p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                <span className="font-medium">
                  {selectedTourIds.size} đã chọn
                </span>
                <button
                  onClick={performBulkPublish}
                  className="px-2 py-1 rounded bg-green-600 text-white hover:bg-green-700 caption-mobile sm:caption-tablet lg:caption-desktop"
                >
                  Xuất bản
                </button>
                <button
                  onClick={performBulkArchive}
                  className="px-2 py-1 rounded bg-gray-300 hover:bg-gray-400 dark:bg-gray-600 dark:hover:bg-gray-500 dark:text-white caption-mobile sm:caption-tablet lg:caption-desktop"
                >
                  Lưu trữ
                </button>
                <button
                  onClick={() => setSelectedTourIds(new Set())}
                  className="px-2 py-1 rounded theme-border hover:opacity-80 caption-mobile sm:caption-tablet lg:caption-desktop"
                >
                  Bỏ chọn
                </button>
              </div>
            )}
            <div className="overflow-auto theme-border rounded theme-bg-card">
              <table className="w-full border-collapse body2-mobile sm:body2-tablet lg:body2-desktop">
                <thead className="bg-gray-50 dark:bg-gray-800/60">
                  <tr className="theme-text-secondary caption-mobile sm:caption-tablet lg:caption-desktop text-left">
                    <th className="p-2">
                      <input
                        type="checkbox"
                        checked={
                          filteredTours.length > 0 &&
                          filteredTours.every((t) => selectedTourIds.has(t.id))
                        }
                        onChange={() => toggleSelectAll(filteredTours)}
                      />
                    </th>
                    <th className="p-2">Ảnh</th>
                    <th className="p-2">Tiêu đề / Slug</th>
                    <th className="p-2">Trạng thái</th>
                    <th className="p-2">Hiển thị</th>
                    <th className="p-2">Khởi hành kế</th>
                    <th className="p-2">Giá từ</th>
                    <th className="p-2">Sức chứa / Còn</th>
                    <th className="p-2">Rating</th>
                    <th className="p-2">Ngôn ngữ HDV</th>
                    <th className="p-2">Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredTours.map((t) => {
                    const remaining = t.capacity - t.confirmed_pax;
                    return (
                      <tr
                        key={t.id}
                        className="border-t theme-border hover:bg-gray-50 dark:hover:bg-gray-800/40 transition-colors"
                      >
                        <td className="p-2">
                          <input
                            type="checkbox"
                            checked={selectedTourIds.has(t.id)}
                            onChange={() => toggleSelectOne(t.id)}
                          />
                        </td>
                        <td className="p-2">
                          <div className="w-16 h-12 bg-gray-100 dark:bg-gray-700 rounded overflow-hidden flex items-center justify-center">
                            {t.thumbnail_url ? (
                              <img
                                src={t.thumbnail_url}
                                alt={t.title}
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
                              {t.title}
                            </button>
                            <span className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                              {t.slug}
                            </span>
                            {t.featured ? (
                              <span className="inline-flex items-center gap-1 caption-mobile sm:caption-tablet lg:caption-desktop text-amber-600 dark:text-amber-400">
                                <Star className="w-3 h-3 fill-amber-500 text-amber-500" />
                                Nổi bật
                              </span>
                            ) : (
                              <span className="inline-flex items-center gap-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                                <StarOff className="w-3 h-3" />–
                              </span>
                            )}
                          </div>
                        </td>
                        <td className="p-2">{statusBadge(t.status)}</td>
                        <td className="p-2">
                          <span
                            className={cx(
                              "inline-flex items-center gap-1 px-2 py-0.5 rounded caption-mobile sm:caption-tablet lg:caption-desktop",
                              t.visibility === "public"
                                ? "bg-green-50 text-green-700 dark:bg-green-900/30 dark:text-green-300"
                                : "bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-300"
                            )}
                          >
                            <Globe className="w-3 h-3" />
                            {t.visibility === "public"
                              ? "Công khai"
                              : "Riêng tư"}
                          </span>
                        </td>
                        <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                          {t.next_departure || "—"}
                        </td>
                        <td className="p-2 whitespace-nowrap caption-mobile sm:caption-tablet lg:caption-desktop">
                          {fmtCurrency(t.price_min, t.currency)}
                        </td>
                        <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                          {t.capacity} /{" "}
                          <span
                            className={
                              remaining < 5
                                ? "text-red-600 dark:text-red-400 font-semibold"
                                : ""
                            }
                          >
                            {remaining}
                          </span>
                        </td>
                        <td className="p-2">
                          <div className="flex items-center gap-1 caption-mobile sm:caption-tablet lg:caption-desktop">
                            <Star className="w-3 h-3 text-yellow-500 fill-yellow-500" />
                            <span>{t.rating_average.toFixed(1)}</span>
                          </div>
                        </td>
                        <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                          {t.guide_languages.join(", ")}
                        </td>
                        <td className="p-2 align-top">
                          <div className="flex flex-wrap gap-1">
                            {[
                              { ic: Eye, title: "Xem" },
                              { ic: Pencil, title: "Sửa" },
                              { ic: CalendarDays, title: "Lịch" },
                              { ic: BookOpen, title: "Booking" },
                              { ic: Copy, title: "Clone" },
                              { ic: Power, title: "Publish" },
                              { ic: Archive, title: "Lưu trữ" },
                            ].map((b, idx) => {
                              const Icon = b.ic;
                              return (
                                <button
                                  key={idx}
                                  className="p-1 hover:text-blue-600 dark:hover:text-blue-400"
                                  title={b.title}
                                >
                                  <Icon className="w-4 h-4" />
                                </button>
                              );
                            })}
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                  {filteredTours.length === 0 && (
                    <tr>
                      <td
                        className="p-4 text-center caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary"
                        colSpan={11}
                      >
                        Không tìm thấy tour
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>

      {/* Bookings */}
      <div>
        {sectionHeader(
          "Booking Chờ Xử Lý",
          "bookings",
          <Clock className="w-4 h-4" />,
          <button className="caption-mobile sm:caption-tablet lg:caption-desktop flex items-center gap-1 px-2 py-1 rounded theme-border hover:opacity-80">
            <RefreshCw className="w-3 h-3" />
            Làm mới
          </button>
        )}
        {!collapsedSections["bookings"] && (
          <div className="theme-border rounded theme-bg-card p-3 overflow-auto">
            <table className="w-full border-collapse body2-mobile sm:body2-tablet lg:body2-desktop">
              <thead className="bg-gray-50 dark:bg-gray-800/60">
                <tr className="theme-text-secondary caption-mobile sm:caption-tablet lg:caption-desktop text-left">
                  <th className="p-2">ID</th>
                  <th className="p-2">Trưởng đoàn</th>
                  <th className="p-2">Tour</th>
                  <th className="p-2">Khởi hành</th>
                  <th className="p-2">Pax</th>
                  <th className="p-2">Tổng tiền</th>
                  <th className="p-2">Thanh toán</th>
                  <th className="p-2">Giữ chỗ đến</th>
                  <th className="p-2">Hành động</th>
                </tr>
              </thead>
              <tbody>
                {pendingBookingsShort.map((b) => {
                  const tour = tours.find((t) => t.id === b.tour_id)!;
                  return (
                    <tr
                      key={b.id}
                      className="border-t theme-border hover:bg-gray-50 dark:hover:bg-gray-800/40 transition-colors"
                    >
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {b.id}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {b.leader_name}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        <span className="text-blue-600 dark:text-blue-400 hover:underline cursor-pointer">
                          {tour.title}
                        </span>
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {b.start_date}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {b.pax}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {fmtCurrency(b.total_price, b.currency)}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {b.payment_status === "pending" ? "Chờ" : "Đã trả"}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {b.hold_until ? "Sắp hết" : "—"}
                      </td>
                      <td className="p-2">
                        <div className="flex flex-wrap gap-1">
                          <button
                            className="px-2 py-0.5 rounded bg-green-600 text-white hover:bg-green-700 caption-mobile sm:caption-tablet lg:caption-desktop"
                            title="Chấp nhận"
                          >
                            Duyệt
                          </button>
                          <button
                            className="px-2 py-0.5 rounded bg-red-600 text-white hover:bg-red-700 caption-mobile sm:caption-tablet lg:caption-desktop"
                            title="Từ chối"
                          >
                            Từ chối
                          </button>
                          <button
                            className="px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-600 hover:bg-gray-300 dark:hover:bg-gray-500 caption-mobile sm:caption-tablet lg:caption-desktop"
                            title="Nhắn tin"
                          >
                            <MessageCircle className="w-3 h-3" />
                          </button>
                          <button
                            className="px-2 py-0.5 rounded bg-indigo-100 hover:bg-indigo-200 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300 caption-mobile sm:caption-tablet lg:caption-desktop"
                            title="Phân hướng dẫn viên"
                          >
                            HDV
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
                {pendingBookingsShort.length === 0 && (
                  <tr>
                    <td
                      className="p-4 text-center caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary"
                      colSpan={9}
                    >
                      Không có booking chờ
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Availability */}
      <div>
        {sectionHeader(
          "Tồn tour (30 ngày)",
          "availability",
          <CalendarDays className="w-4 h-4" />,
          <select
            value={availabilityTourId}
            onChange={(e) => setAvailabilityTourId(Number(e.target.value))}
            className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
          >
            {tours.slice(0, 20).map((t) => (
              <option key={t.id} value={t.id}>
                #{t.id} {t.title.slice(0, 22)}
              </option>
            ))}
          </select>
        )}
        {!collapsedSections["availability"] && (
          <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
            <div className="flex flex-wrap gap-2">
              {availabilitySlots.map(({ date, slot }) => {
                const confirmed = slot?.confirmed_pax || 0;
                const avail = slot
                  ? slot.available_count
                  : tours.find((t) => t.id === availabilityTourId)?.capacity ||
                    0;
                const remaining = avail;
                const blocked = slot?.blocked;
                const color = blocked
                  ? "bg-red-200 text-red-800 dark:bg-red-900/40 dark:text-red-300"
                  : remaining <= 0
                  ? "bg-gray-300 text-gray-700 dark:bg-gray-700 dark:text-gray-300"
                  : remaining < 5
                  ? "bg-amber-200 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300"
                  : "bg-green-200 text-green-800 dark:bg-green-900/40 dark:text-green-300";
                return (
                  <div
                    key={date}
                    className={cx(
                      "w-20 h-16 rounded flex flex-col items-center justify-center caption-mobile sm:caption-tablet lg:caption-desktop font-medium cursor-pointer relative hover:ring-2 ring-light-focus dark:ring-dark-focus transition",
                      color
                    )}
                    title={date}
                  >
                    <span>{date.slice(5)}</span>
                    <span className="overline-mobile sm:overline-tablet lg:overline-desktop">
                      {blocked
                        ? "BLOCK"
                        : `${confirmed}/${confirmed + remaining}`}
                    </span>
                    {slot?.price_override && (
                      <span className="absolute top-1 right-1 overline-mobile sm:overline-tablet lg:overline-desktop bg-black/30 text-white px-1 rounded">
                        $
                      </span>
                    )}
                  </div>
                );
              })}
            </div>
            <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
              (Giả lập) – sau này click để chỉnh sức chứa / block / giá.
            </div>
          </div>
        )}
      </div>

      {/* Pricing & Add-ons */}
      <div>
        {sectionHeader(
          "Giá & Phụ thu",
          "pricingAddons",
          <Tag className="w-4 h-4" />
        )}
        {!collapsedSections["pricingAddons"] && (
          <div className="theme-border rounded theme-bg-card p-4 grid md:grid-cols-2 xl:grid-cols-3 gap-4">
            {tours.slice(0, 6).map((t) => {
              const opts = priceOptByTour.get(t.id) || [];
              const baseOpts = opts.filter((o) => !o.is_addon);
              const addons = opts.filter((o) => o.is_addon);
              return (
                <div
                  key={t.id}
                  className="theme-border rounded p-3 flex flex-col gap-2 bg-gray-50 dark:bg-gray-800/40"
                >
                  <div className="flex items-center justify-between">
                    <span className="caption-mobile sm:caption-tablet lg:caption-desktop font-semibold line-clamp-1">
                      {t.title}
                    </span>
                    <button
                      className="caption-mobile sm:caption-tablet lg:caption-desktop px-2 py-0.5 rounded bg-light-primary dark:bg-dark-primary text-white hover:bg-light-primaryHover dark:hover:bg-dark-primaryHover"
                      title="Thêm tuỳ chọn giá"
                    >
                      Thêm
                    </button>
                  </div>
                  <div className="caption-mobile sm:caption-tablet lg:caption-desktop flex flex-col gap-1">
                    <div>
                      Giá từ:{" "}
                      <strong>{fmtCurrency(t.price_min, t.currency)}</strong>
                    </div>
                    <div>
                      Loại:{" "}
                      {baseOpts.length
                        ? baseOpts.map((o) => o.name).join(", ")
                        : "—"}
                    </div>
                    <div>
                      Phụ thu:{" "}
                      {addons.length
                        ? addons.map((o) => o.name).join(", ")
                        : "—"}
                    </div>
                    <div>
                      Đặt cọc:{" "}
                      {opts.some((o) => o.deposit_type !== "none")
                        ? opts
                            .filter((o) => o.deposit_type !== "none")
                            .map(
                              (o) =>
                                `${o.name}:${o.deposit_type}${
                                  o.deposit_value
                                    ? "(" + o.deposit_value + "%)"
                                    : ""
                                }`
                            )
                            .join("; ")
                        : "Không"}
                    </div>
                  </div>
                  <div className="flex gap-2 mt-1">
                    <button className="flex-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-border rounded px-2 py-0.5 hover:opacity-80">
                      Sửa
                    </button>
                    <button className="flex-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-border rounded px-2 py-0.5 hover:opacity-80">
                      Giả lập
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Reviews */}
      <div>
        {sectionHeader(
          "Đánh giá gần đây",
          "reviews",
          <Star className="w-4 h-4" />
        )}
        {!collapsedSections["reviews"] && (
          <div className="theme-border rounded theme-bg-card p-4 grid md:grid-cols-2 xl:grid-cols-3 gap-4">
            {recentReviews.map((r) => {
              const tour = tours.find((t) => t.id === r.tour_id)!;
              return (
                <div
                  key={r.id}
                  className="theme-border rounded p-3 flex flex-col gap-2 bg-gray-50 dark:bg-gray-800/40"
                >
                  <div className="flex items-center justify-between">
                    <span className="caption-mobile sm:caption-tablet lg:caption-desktop font-semibold line-clamp-1">
                      {tour.title}
                    </span>
                    <span className="flex items-center gap-1 caption-mobile sm:caption-tablet lg:caption-desktop">
                      <Star className="w-3 h-3 text-yellow-500 fill-yellow-500" />
                      {r.rating.toFixed(1)}
                    </span>
                  </div>
                  <div className="body2-mobile sm:body2-tablet lg:body2-desktop theme-text-secondary line-clamp-3">
                    {r.content}
                  </div>
                  <div className="flex gap-2">
                    <button className="flex-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-border rounded px-2 py-0.5 hover:opacity-80">
                      Trả lời
                    </button>
                    <button className="flex-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-border rounded px-2 py-0.5 hover:opacity-80">
                      Gắn cờ
                    </button>
                  </div>
                </div>
              );
            })}
            {recentReviews.length === 0 && (
              <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary col-span-full">
                Không có đánh giá
              </div>
            )}
          </div>
        )}
      </div>

      {/* Media & SEO */}
      <div>
        {sectionHeader(
          "Media & SEO",
          "mediaSeo",
          <ImageIcon className="w-4 h-4" />
        )}
        {!collapsedSections["mediaSeo"] && (
          <div className="grid md:grid-cols-2 gap-6">
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Thiếu ảnh đại diện
              </h4>
              <div className="flex flex-col gap-1 caption-mobile sm:caption-tablet lg:caption-desktop">
                {toursMissingThumb.length === 0 && (
                  <span className="theme-text-secondary">Không có</span>
                )}
                {toursMissingThumb.map((t) => (
                  <div
                    key={t.id}
                    className="flex items-center justify-between theme-border rounded px-2 py-1 bg-gray-50 dark:bg-gray-800/40"
                  >
                    <span className="line-clamp-1">{t.title}</span>
                    <button className="caption-mobile sm:caption-tablet lg:caption-desktop px-2 py-0.5 rounded bg-blue-600 text-white hover:bg-blue-700">
                      Upload
                    </button>
                  </div>
                ))}
              </div>
            </div>
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Thiếu tiêu đề SEO
              </h4>
              <div className="flex flex-col gap-1 caption-mobile sm:caption-tablet lg:caption-desktop">
                {toursMissingSEO.length === 0 && (
                  <span className="theme-text-secondary">Không có</span>
                )}
                {toursMissingSEO.map((t) => (
                  <div
                    key={t.id}
                    className="flex items-center justify-between theme-border rounded px-2 py-1 bg-gray-50 dark:bg-gray-800/40"
                  >
                    <span className="line-clamp-1">{t.title}</span>
                    <button className="caption-mobile sm:caption-tablet lg:caption-desktop px-2 py-0.5 rounded bg-indigo-600 text-white hover:bg-indigo-700">
                      SEO
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Itinerary & Guides */}
      <div>
        {sectionHeader(
          "Lịch trình & Hướng dẫn viên",
          "itinerary",
          <MapPin className="w-4 h-4" />
        )}
        {!collapsedSections["itinerary"] && (
          <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-6">
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3 md:col-span-2">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Lịch trình (2 ngày đầu)
              </h4>
              <div className="flex flex-col gap-4">
                {itineraryPreview.map((it) => {
                  const tour = tours.find((t) => t.id === it.tour_id)!;
                  return (
                    <div
                      key={it.tour_id}
                      className="theme-border rounded p-3 bg-gray-50 dark:bg-gray-800/40 flex flex-col gap-2"
                    >
                      <div className="flex items-center justify-between">
                        <span className="caption-mobile sm:caption-tablet lg:caption-desktop font-semibold line-clamp-1">
                          {tour.title}
                        </span>
                        <button className="caption-mobile sm:caption-tablet lg:caption-desktop px-2 py-0.5 rounded bg-blue-100 text-blue-700 hover:bg-blue-200 dark:bg-blue-900/30 dark:text-blue-300">
                          Sửa đầy đủ
                        </button>
                      </div>
                      <div className="flex flex-col gap-1 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {it.days.map((d) => (
                          <div key={d.day_number} className="flex gap-2">
                            <span className="font-semibold">
                              Ngày {d.day_number}:
                            </span>
                            <span className="line-clamp-1">
                              {d.activities
                                .map(
                                  (a) =>
                                    `${a.time ? a.time + " " : ""}${a.desc}`
                                )
                                .join(" | ")}
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>
                  );
                })}
                {itineraryPreview.length === 0 && (
                  <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                    Chưa có dữ liệu lịch trình
                  </div>
                )}
              </div>
            </div>
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Phân công HDV
              </h4>
              <div className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                {guideAssignmentsUpc.map((g) => {
                  const t = tours.find((tt) => tt.id === g.tour_id)!;
                  return (
                    <div
                      key={g.id}
                      className="theme-border rounded px-2 py-1 bg-gray-50 dark:bg-gray-800/40 flex flex-col"
                    >
                      <span className="font-medium line-clamp-1">
                        {t.title}
                      </span>
                      <span>
                        {g.guide_name} ({g.language}) • {g.departure_date}
                      </span>
                      <button className="self-start mt-1 caption-mobile sm:caption-tablet lg:caption-desktop px-2 py-0.5 rounded bg-indigo-600 text-white hover:bg-indigo-700">
                        Điều chỉnh
                      </button>
                    </div>
                  );
                })}
                {guideAssignmentsUpc.length === 0 && (
                  <span className="theme-text-secondary">
                    Chưa có phân công
                  </span>
                )}
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
          <TriangleAlert className="w-4 h-4" />
        )}
        {!collapsedSections["alertsActivity"] && (
          <div className="grid md:grid-cols-2 gap-6">
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Cảnh báo
              </h4>
              <div className="flex flex-col gap-1 caption-mobile sm:caption-tablet lg:caption-desktop">
                {recentAlerts.length === 0 && (
                  <span className="theme-text-secondary">
                    Không có cảnh báo
                  </span>
                )}
                {recentAlerts.map((a) => (
                  <div
                    key={a.id}
                    className={cx(
                      "theme-border rounded px-2 py-1 flex items-center gap-2",
                      a.severity === "critical"
                        ? "bg-red-50 border-red-200 text-red-700 dark:bg-red-900/30 dark:border-red-700 dark:text-red-300"
                        : a.severity === "warn"
                        ? "bg-amber-50 border-amber-200 text-amber-700 dark:bg-amber-900/30 dark:border-amber-700 dark:text-amber-300"
                        : "bg-blue-50 border-blue-200 text-blue-700 dark:bg-blue-900/30 dark:border-blue-700 dark:text-blue-300"
                    )}
                  >
                    {a.severity === "critical" ? (
                      <XCircle className="w-3 h-3" />
                    ) : a.severity === "warn" ? (
                      <TriangleAlert className="w-3 h-3" />
                    ) : (
                      <InfoIcon />
                    )}
                    <span className="flex-1 line-clamp-1">{a.message}</span>
                    <button className="caption-mobile sm:caption-tablet lg:caption-desktop px-2 py-0.5 rounded bg-white/70 dark:bg-white/10 hover:bg-white dark:hover:bg-white/20 border border-white/60 dark:border-white/20">
                      Xem
                    </button>
                  </div>
                ))}
              </div>
            </div>
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Hoạt động gần đây
              </h4>
              <div className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                {recentActivity.map((act) => {
                  const t = tours.find((tt) => tt.id === act.tour_id);
                  return (
                    <div
                      key={act.id}
                      className="theme-border rounded px-2 py-1 bg-gray-50 dark:bg-gray-800/40 flex items-center gap-2"
                    >
                      <History className="w-3 h-3 text-gray-500 dark:text-gray-400" />
                      <span className="flex-1 line-clamp-1">
                        {act.action} {t ? `(${t.title})` : ""}
                      </span>
                      <span className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
                        {act.created_at.slice(11, 16)}
                      </span>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary flex flex-wrap gap-4">
        <span>Chú thích tồn: Xanh tốt • Vàng thấp • Xám hết • Đỏ block</span>
        <span>Dữ liệu giả lập – tích hợp API sau.</span>
      </div>
    </div>
  );
};

/* Info icon */
const InfoIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" className="w-3 h-3 fill-current" aria-hidden="true">
    <circle cx="12" cy="12" r="10" className="opacity-20" />
    <path d="M11 10h2v7h-2zm0-4h2v2h-2z" />
  </svg>
);

export default DashboardTourPage;
