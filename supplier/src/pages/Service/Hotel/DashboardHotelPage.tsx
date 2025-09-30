import React, { useMemo, useState } from "react";
import {
  Building2,
  Plus,
  Search,
  Filter,
  Star,
  Eye,
  Pencil,
  CalendarDays,
  Copy,
  Power,
  Archive,
  ChevronDown,
  ChevronUp,
  Clock,
  BedDouble,
  BookOpen,
  Tag,
  RefreshCw,
  History,
  DollarSign,
  Video,
  Wrench,
  ShieldAlert,
  XCircle,
  TriangleAlert,
  DoorClosed,
  MessageCircle,
  Sparkles,
  Layers3,
} from "lucide-react";

/* ===================== Mock Types ===================== */
type HotelStatus = "draft" | "published" | "archived" | "disabled";
interface Hotel {
  id: number;
  title: string;
  slug: string;
  area: string;
  property_type: string;
  star_rating: number;
  status: HotelStatus;
  visibility: "public" | "private";
  thumbnail_url?: string | null;
  price_from: number;
  rating_average: number;
  total_rooms: number;
  occupied_rooms: number;
  next_available_date?: string | null;
  created_at: string;
  updated_at: string;
}

interface Reservation {
  id: number;
  hotel_id: number;
  guest_name: string;
  room_type: string;
  check_in: string;
  check_out: string;
  booking_status: "pending" | "confirmed" | "cancelled" | "checked_in";
  payment_status: "pending" | "paid" | "partial";
}

interface InventorySlot {
  date: string;
  hotel_id: number;
  room_type: string;
  available_count: number;
  occupied: number;
  blocked: boolean;
  price_override?: number | null;
}

interface RatePlan {
  id: number;
  hotel_id: number;
  room_type: string;
  name: string;
  base_price: number;
  currency: string;
  refundable: boolean;
  meal_plan?: string;
}

interface Review {
  id: number;
  hotel_id: number;
  guest: string;
  rating: number;
  aspects: {
    cleanliness: number;
    service: number;
    facilities: number;
  };
  content: string;
  created_at: string;
}

interface HousekeepingItem {
  id: number;
  room_label: string;
  status: "maintenance" | "cleaning" | "ready";
  reason?: string;
}

interface AlertItem {
  id: number;
  type: "overbook_risk" | "maintenance_conflict" | "staff_low";
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
    | "reservation_confirm"
    | "reservation_cancel"
    | "clone"
    | "media_upload"
    | "virtual_tour_add";
  hotel_id?: number;
  meta?: Record<string, unknown>;
  created_at: string;
}

/* ===================== Mock Generators ===================== */
const areas = ["Hà Nội", "TP.HCM", "Đà Nẵng", "Nha Trang", "Phú Quốc"];
const propertyTypes = ["Hotel", "Resort", "Boutique", "Apartment", "Villa"];
const roomTypes = ["Standard", "Deluxe", "Suite", "Family", "Studio"];

function rand<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

function genHotels(): Hotel[] {
  const now = Date.now();
  const arr: Hotel[] = [];
  for (let i = 1; i <= 18; i++) {
    const totalRooms = 40 + (i % 6) * 20;
    const occupied = Math.floor(totalRooms * (0.3 + Math.random() * 0.6));
    arr.push({
      id: i,
      title: `Hotel Property #${i}`,
      slug: `hotel-property-${i}`,
      area: rand(areas),
      property_type: rand(propertyTypes),
      star_rating: 3 + (i % 3),
      status: rand(["published", "draft", "archived", "disabled"]),
      visibility: Math.random() > 0.2 ? "public" : "private",
      thumbnail_url:
        Math.random() > 0.15
          ? `https://picsum.photos/seed/hotel-${i}/200/140.webp`
          : null,
      price_from: 800000 + ((i * 173000) % 1500000),
      rating_average: parseFloat((3 + Math.random() * 2).toFixed(1)),
      total_rooms: totalRooms,
      occupied_rooms: occupied,
      next_available_date:
        Math.random() > 0.3
          ? new Date(now + Math.random() * 7 * 86400000)
              .toISOString()
              .substring(0, 10)
          : null,
      created_at: new Date(now - i * 86400000).toISOString(),
      updated_at: new Date(now - i * 3600000).toISOString(),
    });
  }
  return arr;
}

function genReservations(hotels: Hotel[]): Reservation[] {
  const arr: Reservation[] = [];
  const now = Date.now();
  for (let i = 1; i <= 30; i++) {
    const h = rand(hotels);
    const offset = Math.floor(Math.random() * 3); // within next 3 days
    const ci = new Date(now + offset * 86400000).toISOString().substring(0, 10);
    const co = new Date(
      new Date(ci).getTime() + (1 + Math.floor(Math.random() * 3)) * 86400000
    )
      .toISOString()
      .substring(0, 10);
    arr.push({
      id: 5000 + i,
      hotel_id: h.id,
      guest_name: `Guest ${i}`,
      room_type: rand(roomTypes),
      check_in: ci,
      check_out: co,
      booking_status: rand(["pending", "confirmed", "cancelled"]),
      payment_status: rand(["pending", "paid", "partial"]),
    });
  }
  return arr;
}

function genInventory(hotels: Hotel[]): InventorySlot[] {
  const now = Date.now();
  const arr: InventorySlot[] = [];
  hotels.slice(0, 5).forEach((h) => {
    roomTypes.slice(0, 3).forEach((rt) => {
      for (let d = 0; d < 30; d++) {
        if (Math.random() > 0.8) continue;
        const date = new Date(now + d * 86400000)
          .toISOString()
          .substring(0, 10);
        const base = 10 + (d % 4) * 2;
        const occ = Math.floor(base * Math.random());
        arr.push({
          date,
          hotel_id: h.id,
          room_type: rt,
          available_count: base - occ,
          occupied: occ,
          blocked: Math.random() > 0.95,
          price_override:
            Math.random() > 0.9
              ? h.price_from * (1 + Math.random() * 0.2)
              : null,
        });
      }
    });
  });
  return arr;
}

function genRatePlans(hotels: Hotel[]): RatePlan[] {
  const arr: RatePlan[] = [];
  let id = 1;
  hotels.slice(0, 6).forEach((h) => {
    roomTypes.slice(0, 3).forEach((rt, idx) => {
      arr.push({
        id: id++,
        hotel_id: h.id,
        room_type: rt,
        name:
          idx === 0 ? "Flexible" : idx === 1 ? "Non-Refundable" : "Early Bird",
        base_price: h.price_from + idx * 150000,
        currency: "VND",
        refundable: idx !== 1,
        meal_plan: idx === 2 ? "Breakfast" : undefined,
      });
    });
  });
  return arr;
}

function genReviews(hotels: Hotel[]): Review[] {
  const arr: Review[] = [];
  let id = 1;
  hotels.slice(0, 6).forEach((h) => {
    const n = 1 + (h.id % 3);
    for (let i = 0; i < n; i++) {
      arr.push({
        id: id++,
        hotel_id: h.id,
        guest: `Reviewer ${id}`,
        rating: parseFloat((3 + Math.random() * 2).toFixed(1)),
        aspects: {
          cleanliness: parseFloat((3 + Math.random() * 2).toFixed(1)),
          service: parseFloat((3 + Math.random() * 2).toFixed(1)),
          facilities: parseFloat((3 + Math.random() * 2).toFixed(1)),
        },
        content: "Trải nghiệm tốt, phòng sạch (mock).",
        created_at: new Date(Date.now() - i * 3600000).toISOString(),
      });
    }
  });
  return arr;
}

function genHousekeeping(): HousekeepingItem[] {
  return [
    { id: 1, room_label: "101", status: "maintenance", reason: "Ống nước" },
    { id: 2, room_label: "205", status: "cleaning" },
    { id: 3, room_label: "320", status: "maintenance", reason: "Điều hòa" },
    { id: 4, room_label: "402", status: "ready" },
  ];
}

function genAlerts(hotels: Hotel[]): AlertItem[] {
  return [
    {
      id: 1,
      type: "overbook_risk",
      message: `Nguy cơ overbook tại ${hotels[0].title}`,
      severity: "warn",
      created_at: new Date().toISOString(),
    },
    {
      id: 2,
      type: "maintenance_conflict",
      message: "Bảo trì trùng ngày check-in phòng 205",
      severity: "critical",
      created_at: new Date().toISOString(),
    },
    {
      id: 3,
      type: "staff_low",
      message: "Thiếu nhân sự buồng phòng ngày mai",
      severity: "info",
      created_at: new Date().toISOString(),
    },
  ];
}

function genActivities(hotels: Hotel[]): ActivityLog[] {
  const actions: ActivityLog["action"][] = [
    "publish",
    "unpublish",
    "price_update",
    "reservation_confirm",
    "reservation_cancel",
    "clone",
    "media_upload",
    "virtual_tour_add",
  ];
  const arr: ActivityLog[] = [];
  for (let i = 0; i < 22; i++) {
    const h = rand(hotels);
    arr.push({
      id: i + 1,
      action: rand(actions),
      hotel_id: h.id,
      meta: { title: h.title },
      created_at: new Date(Date.now() - i * 3600000).toISOString(),
    });
  }
  return arr;
}

/* ===================== Helpers ===================== */
const fmtCurrency = (v: number) =>
  new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    minimumFractionDigits: 0,
  }).format(v);

const cx = (...c: Array<string | false | null | undefined>) =>
  c.filter(Boolean).join(" ");

/* ===================== Main Component ===================== */
const DashboardHotelPage: React.FC = () => {
  /* Seeds */
  const [hotels] = useState<Hotel[]>(() => genHotels());
  const [reservations] = useState<Reservation[]>(() => genReservations(hotels));
  const [inventory] = useState<InventorySlot[]>(() => genInventory(hotels));
  const [ratePlans] = useState<RatePlan[]>(() => genRatePlans(hotels));
  const [reviews] = useState<Review[]>(() => genReviews(hotels));
  const [housekeeping] = useState<HousekeepingItem[]>(() => genHousekeeping());
  const [alerts] = useState<AlertItem[]>(() => genAlerts(hotels));
  const [activities] = useState<ActivityLog[]>(() => genActivities(hotels));

  /* Filters (UI only) */
  const [search, setSearch] = useState("");
  const [filterArea, setFilterArea] = useState("");
  const [filterType, setFilterType] = useState("");
  const [filterStar, setFilterStar] = useState("");
  const [filterStatus, setFilterStatus] = useState<HotelStatus | "">("");
  const [priceMin, setPriceMin] = useState("");
  const [priceMax, setPriceMax] = useState("");
  const [filterRoomType, setFilterRoomType] = useState("");

  /* Collapsible sections */
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});
  const toggleCollapse = (k: string) =>
    setCollapsed((prev) => ({ ...prev, [k]: !prev[k] }));

  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set());
  const toggleSelectAll = (rows: Hotel[]) => {
    const ids = rows.map((h) => h.id);
    const all = ids.every((i) => selectedIds.has(i));
    setSelectedIds(all ? new Set() : new Set(ids));
  };
const toggleSelectOne = (id: number) =>
  setSelectedIds((prev) => {
    const next = new Set(prev);
    if (next.has(id)) {
      next.delete(id);
    } else {
      next.add(id);
    }
    return next;
  });

  /* Filtered hotels */
  const filteredHotels = useMemo(() => {
    return hotels.filter((h) => {
      if (search) {
        const q = search.toLowerCase();
        if (
          !h.title.toLowerCase().includes(q) &&
          !h.slug.toLowerCase().includes(q) &&
          !String(h.id).includes(q)
        )
          return false;
      }
      if (filterArea && h.area !== filterArea) return false;
      if (filterType && h.property_type !== filterType) return false;
      if (filterStatus && h.status !== filterStatus) return false;
      if (filterStar && h.star_rating < parseInt(filterStar, 10)) return false;
      if (priceMin && h.price_from < parseInt(priceMin, 10)) return false;
      if (priceMax && h.price_from > parseInt(priceMax, 10)) return false;
      if (filterRoomType) {
        // simple check: at least one rate plan with that room type
        const has = ratePlans.some(
          (rp) => rp.hotel_id === h.id && rp.room_type === filterRoomType
        );
        if (!has) return false;
      }
      return true;
    });
  }, [
    hotels,
    search,
    filterArea,
    filterType,
    filterStatus,
    filterStar,
    priceMin,
    priceMax,
    filterRoomType,
    ratePlans,
  ]);

  /* KPIs (mock formulas) */
  const kpis = useMemo(() => {
    const total = hotels.length;
    const totalRooms = hotels.reduce((s, h) => s + h.total_rooms, 0);
    const occupied = hotels.reduce((s, h) => s + h.occupied_rooms, 0);
    const occupancyRate = totalRooms ? (occupied / totalRooms) * 100 : 0;
    const adr =
      hotels.length > 0
        ? hotels.reduce((s, h) => s + h.price_from, 0) / hotels.length
        : 0;
    // RevPAR = (ADR * Occupancy%)
    const revPar = adr * (occupancyRate / 100);
    const pendingRes = reservations.filter(
      (r) => r.booking_status === "pending"
    ).length;
    return { total, occupancyRate, adr, revPar, pendingRes };
  }, [hotels, reservations]);

  /* Derived upcoming arrivals (today + next 3 days) */
  const upcomingArrivals = useMemo(() => {
    const today = new Date().toISOString().substring(0, 10);
    const in3 = new Date(Date.now() + 3 * 86400000)
      .toISOString()
      .substring(0, 10);
    return reservations
      .filter((r) => r.check_in >= today && r.check_in <= in3)
      .slice(0, 12);
  }, [reservations]);

  /* Availability (select hotel) */
  const [availabilityHotelId, setAvailabilityHotelId] = useState<number>(() =>
    hotels.length ? hotels[0].id : 0
  );
  const availabilityHeat = useMemo(() => {
    // map roomType -> array of 30 days
    const roomSet = new Set<string>();
    inventory
      .filter((s) => s.hotel_id === availabilityHotelId)
      .forEach((s) => roomSet.add(s.room_type));
    const roomList = Array.from(roomSet.values());
    const days: string[] = [];
    for (let d = 0; d < 30; d++) {
      days.push(
        new Date(Date.now() + d * 86400000).toISOString().substring(0, 10)
      );
    }
    return {
      roomList,
      days,
      matrix: roomList.map((rt) =>
        days.map(
          (date) =>
            inventory.find(
              (s) =>
                s.room_type === rt &&
                s.date === date &&
                s.hotel_id === availabilityHotelId
            ) || null
        )
      ),
    };
  }, [availabilityHotelId, inventory]);

  /* Recent subsets */
  const ratePlansPreview = useMemo(() => ratePlans.slice(0, 9), [ratePlans]);
  const reviewPreview = useMemo(() => reviews.slice(0, 5), [reviews]);
  const housekeepingProblems = useMemo(
    () => housekeeping.filter((h) => h.status !== "ready"),
    [housekeeping]
  );
  const alertsRecent = useMemo(() => alerts.slice(0, 6), [alerts]);
  const activityRecent = useMemo(() => activities.slice(0, 10), [activities]);

  /* Bulk mock actions */
  const bulkPublish = () => {
    console.log("Bulk publish hotels:", Array.from(selectedIds));
    alert("Bulk publish (mock)");
  };
  const bulkArchive = () => {
    console.log("Bulk archive hotels:", Array.from(selectedIds));
    alert("Bulk archive (mock)");
  };
  const clearFilters = () => {
    setSearch("");
    setFilterArea("");
    setFilterType("");
    setFilterStatus("");
    setFilterStar("");
    setPriceMin("");
    setPriceMax("");
    setFilterRoomType("");
  };

  /* Helpers UI */
  const statusBadge = (status: HotelStatus) => {
    const map: Record<HotelStatus, string> = {
      published:
        "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
      draft:
        "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
      archived: "bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-200",
      disabled: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300",
    };
    const label: Record<HotelStatus, string> = {
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
        >
          <span className="w-6 h-6 inline-flex items-center justify-center rounded theme-bg-secondary icon-brand">
            {icon || <Building2 className="w-4 h-4" />}
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
            <Building2 className="w-7 h-7 icon-brand" />
            Dashboard Khách Sạn
          </h1>
          <span className="body2-mobile sm:body2-tablet lg:body2-desktop theme-text-secondary">
            Nhà cung cấp: <strong>Mock Provider Co.</strong>
          </span>
          <div className="ml-auto flex gap-2">
            <button className="btn-primary btn-text-responsive flex items-center gap-2">
              <Plus className="w-4 h-4" />
              Tạo khách sạn
            </button>
            <button className="btn-outline btn-text-responsive flex items-center gap-2">
              <BedDouble className="w-4 h-4" />
              Tạo room-type nhanh
            </button>
          </div>
        </div>

        <div className="flex flex-wrap gap-3 items-end">
          <div className="flex items-center gap-2 theme-border rounded px-2 py-1 theme-bg-card body2-mobile sm:body2-tablet lg:body2-desktop">
            <Search className="w-4 h-4 icon-disabled" />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Tìm tiêu đề / slug / ID"
              className="outline-none bg-transparent body2-mobile sm:body2-tablet lg:body2-desktop placeholder:theme-text-secondary"
            />
          </div>
          {/* Area */}
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
          {/* Type */}
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Loại hình
            </label>
            <select
              value={filterType}
              onChange={(e) => setFilterType(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Tất cả</option>
              {propertyTypes.map((p) => (
                <option key={p}>{p}</option>
              ))}
            </select>
          </div>
          {/* Star */}
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Sao ≥
            </label>
            <select
              value={filterStar}
              onChange={(e) => setFilterStar(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Bất kỳ</option>
              {[3, 4, 5].map((s) => (
                <option key={s}>{s}</option>
              ))}
            </select>
          </div>
          {/* Status */}
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Trạng thái
            </label>
            <select
              value={filterStatus}
              onChange={(e) =>
                setFilterStatus(e.target.value as HotelStatus | "")
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
          {/* Room Type */}
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Room Type
            </label>
            <select
              value={filterRoomType}
              onChange={(e) => setFilterRoomType(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Tất cả</option>
              {roomTypes.map((r) => (
                <option key={r}>{r}</option>
              ))}
            </select>
          </div>
          {/* Price range */}
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
          <button
            onClick={clearFilters}
            className="caption-mobile sm:caption-tablet lg:caption-desktop theme-border rounded px-3 py-1 theme-bg-card hover:opacity-80"
          >
            Đặt lại
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <div>
        {sectionHeader("Chỉ số (KPI)", "kpi", <Filter className="w-4 h-4" />)}
        {!collapsed["kpi"] && (
          <div className="grid sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-5 gap-4">
            {renderKPI(
              "Tổng khách sạn",
              kpis.total,
              <Building2 className="w-4 h-4" />
            )}
            {renderKPI(
              "Occupancy",
              `${kpis.occupancyRate.toFixed(1)}%`,
              <BedDouble className="w-4 h-4" />
            )}
            {renderKPI(
              "ADR",
              fmtCurrency(Math.round(kpis.adr)),
              <DollarSign className="w-4 h-4" />
            )}
            {renderKPI(
              "RevPAR",
              fmtCurrency(Math.round(kpis.revPar)),
              <Layers3 className="w-4 h-4" />
            )}
            {renderKPI(
              "Pending res.",
              kpis.pendingRes,
              <Clock className="w-4 h-4" />
            )}
          </div>
        )}
      </div>

      {/* Listing Hotels */}
      <div>
        {sectionHeader(
          "Danh sách Khách sạn",
          "hotels",
          <Building2 className="w-4 h-4" />,
          <span className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
            {filteredHotels.length} kết quả
          </span>
        )}
        {!collapsed["hotels"] && (
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
                          filteredHotels.length > 0 &&
                          filteredHotels.every((h) => selectedIds.has(h.id))
                        }
                        onChange={() => toggleSelectAll(filteredHotels)}
                      />
                    </th>
                    <th className="p-2">Ảnh</th>
                    <th className="p-2">Tiêu đề / Slug</th>
                    <th className="p-2">Sao / Loại</th>
                    <th className="p-2">Phòng / Occ%</th>
                    <th className="p-2">Ngày trống</th>
                    <th className="p-2">Giá từ</th>
                    <th className="p-2">Rating</th>
                    <th className="p-2">Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredHotels.map((h) => {
                    const occPct = h.total_rooms
                      ? (h.occupied_rooms / h.total_rooms) * 100
                      : 0;
                    return (
                      <tr
                        key={h.id}
                        className="border-t theme-border hover:bg-gray-50 dark:hover:bg-gray-800/40 transition-colors"
                      >
                        <td className="p-2">
                          <input
                            type="checkbox"
                            checked={selectedIds.has(h.id)}
                            onChange={() => toggleSelectOne(h.id)}
                          />
                        </td>
                        <td className="p-2">
                          <div className="w-20 h-14 bg-gray-100 dark:bg-gray-700 rounded overflow-hidden flex items-center justify-center">
                            {h.thumbnail_url ? (
                              <img
                                src={h.thumbnail_url}
                                alt={h.title}
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
                              {h.title}
                            </button>
                            <span className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                              {h.slug}
                            </span>
                            {statusBadge(h.status)}
                          </div>
                        </td>
                        <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                          <div className="flex items-center gap-1">
                            <Star className="w-3 h-3 text-yellow-500 fill-yellow-500" />
                            {h.star_rating}★
                          </div>
                          <div className="overline-mobile sm:overline-tablet lg:overline-desktop">
                            {h.property_type}
                          </div>
                        </td>
                        <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                          {h.total_rooms} /{" "}
                          <span
                            className={
                              occPct > 85
                                ? "text-red-600 dark:text-red-400 font-semibold"
                                : occPct > 70
                                ? "text-amber-600 dark:text-amber-400"
                                : ""
                            }
                          >
                            {occPct.toFixed(0)}%
                          </span>
                        </td>
                        <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                          {h.next_available_date || "—"}
                        </td>
                        <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop whitespace-nowrap">
                          {fmtCurrency(h.price_from)}
                        </td>
                        <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                          {h.rating_average.toFixed(1)}
                        </td>
                        <td className="p-2 align-top">
                          <div className="flex flex-wrap gap-1">
                            {[
                              { ic: Eye, t: "Xem" },
                              { ic: Pencil, t: "Sửa" },
                              { ic: CalendarDays, t: "Lịch" },
                              { ic: BookOpen, t: "Bookings" },
                              { ic: Video, t: "Virtual" },
                              { ic: Power, t: "Publish" },
                              { ic: Archive, t: "Archive" },
                              { ic: Copy, t: "Clone" },
                            ].map((a, i) => {
                              const Icon = a.ic;
                              return (
                                <button
                                  key={i}
                                  className="p-1 hover:text-blue-600 dark:hover:text-blue-400"
                                  title={a.t}
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
                  {filteredHotels.length === 0 && (
                    <tr>
                      <td
                        className="p-4 text-center caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary"
                        colSpan={9}
                      >
                        Không tìm thấy khách sạn
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>

      {/* Reservations Snapshot */}
      <div>
        {sectionHeader(
          "Booking đến (3 ngày)",
          "reservations",
          <Clock className="w-4 h-4" />,
          <button className="caption-mobile sm:caption-tablet lg:caption-desktop flex items-center gap-1 px-2 py-1 rounded theme-border hover:opacity-80">
            <RefreshCw className="w-3 h-3" />
            Làm mới
          </button>
        )}
        {!collapsed["reservations"] && (
          <div className="theme-border rounded theme-bg-card p-3 overflow-auto">
            <table className="w-full border-collapse body2-mobile sm:body2-tablet lg:body2-desktop">
              <thead className="bg-gray-50 dark:bg-gray-800/60">
                <tr className="text-left theme-text-secondary caption-mobile sm:caption-tablet lg:caption-desktop">
                  <th className="p-2">ID</th>
                  <th className="p-2">Khách</th>
                  <th className="p-2">Khách sạn</th>
                  <th className="p-2">Room Type</th>
                  <th className="p-2">Check-in</th>
                  <th className="p-2">Check-out</th>
                  <th className="p-2">Trạng thái</th>
                  <th className="p-2">Thanh toán</th>
                  <th className="p-2">Hành động</th>
                </tr>
              </thead>
              <tbody>
                {upcomingArrivals.map((r) => {
                  const hotel = hotels.find((h) => h.id === r.hotel_id)!;
                  return (
                    <tr
                      key={r.id}
                      className="border-t theme-border hover:bg-gray-50 dark:hover:bg-gray-800/40 transition-colors"
                    >
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {r.id}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {r.guest_name}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        <span className="text-blue-600 dark:text-blue-400 hover:underline cursor-pointer">
                          {hotel.title}
                        </span>
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {r.room_type}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {r.check_in}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {r.check_out}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {r.booking_status}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {r.payment_status}
                      </td>
                      <td className="p-2">
                        <div className="flex flex-wrap gap-1">
                          <button
                            className="px-2 py-0.5 rounded bg-green-600 text-white hover:bg-green-700 caption-mobile sm:caption-tablet lg:caption-desktop"
                            title="Check-in"
                          >
                            Check-in
                          </button>
                          <button
                            className="px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-600 hover:bg-gray-300 dark:hover:bg-gray-500 caption-mobile sm:caption-tablet lg:caption-desktop"
                            title="Assign room"
                          >
                            Gán
                          </button>
                          <button
                            className="px-2 py-0.5 rounded bg-indigo-100 hover:bg-indigo-200 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300 caption-mobile sm:caption-tablet lg:caption-desktop"
                            title="Tin nhắn"
                          >
                            <MessageCircle className="w-3 h-3" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
                {upcomingArrivals.length === 0 && (
                  <tr>
                    <td
                      className="p-4 text-center caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary"
                      colSpan={9}
                    >
                      Không có booking sắp đến
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Availability Heatmap */}
      <div>
        {sectionHeader(
          "Tồn phòng (30 ngày)",
          "availability",
          <CalendarDays className="w-4 h-4" />,
          <select
            value={availabilityHotelId}
            onChange={(e) => setAvailabilityHotelId(Number(e.target.value))}
            className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
          >
            {hotels.slice(0, 10).map((h) => (
              <option key={h.id} value={h.id}>
                #{h.id} {h.title.slice(0, 24)}
              </option>
            ))}
          </select>
        )}
        {!collapsed["availability"] && (
          <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-4 overflow-auto">
            <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
              Màu: Xanh tốt • Vàng thấp • Đỏ block • Xám full
            </div>
            <div className="min-w-[900px]">
              <table className="w-full border-collapse caption-mobile sm:caption-tablet lg:caption-desktop">
                <thead>
                  <tr>
                    <th className="p-2 text-left theme-text-secondary">
                      Room Type
                    </th>
                    {availabilityHeat.days.map((d) => (
                      <th
                        key={d}
                        className="p-1 theme-text-secondary overline-mobile sm:overline-tablet lg:overline-desktop"
                      >
                        {d.slice(5)}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {availabilityHeat.roomList.map((rt, rIdx) => (
                    <tr key={rt} className="border-t theme-border">
                      <td className="p-2 font-semibold">{rt}</td>
                      {availabilityHeat.matrix[rIdx].map((slot, cIdx) => {
                        const remaining = slot ? slot.available_count : 0;
                        const blocked = slot?.blocked;
                        let color =
                          "bg-green-200 text-green-800 dark:bg-green-900/40 dark:text-green-300";
                        if (blocked)
                          color =
                            "bg-red-200 text-red-800 dark:bg-red-900/40 dark:text-red-300";
                        else if (!slot)
                          color =
                            "bg-gray-200 text-gray-600 dark:bg-gray-700 dark:text-gray-300";
                        else if (remaining <= 0)
                          color =
                            "bg-gray-300 text-gray-700 dark:bg-gray-700 dark:text-gray-300";
                        else if (remaining < 3)
                          color =
                            "bg-amber-200 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300";
                        return (
                          <td
                            key={cIdx}
                            title={availabilityHeat.days[cIdx]}
                            className="p-0.5"
                          >
                            <div
                              className={cx(
                                "h-8 rounded flex flex-col items-center justify-center relative cursor-pointer hover:ring-2 ring-light-focus dark:ring-dark-focus transition",
                                color
                              )}
                            >
                              <span className="overline-mobile sm:overline-tablet lg:overline-desktop">
                                {blocked ? "B" : slot ? `${remaining}` : "-"}
                              </span>
                              {slot?.price_override && (
                                <span className="absolute top-0.5 right-0.5 overline-mobile sm:overline-tablet lg:overline-desktop bg-black/30 text-white px-1 rounded">
                                  $
                                </span>
                              )}
                            </div>
                          </td>
                        );
                      })}
                    </tr>
                  ))}
                  {availabilityHeat.roomList.length === 0 && (
                    <tr>
                      <td
                        className="p-4 caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary"
                        colSpan={availabilityHeat.days.length + 1}
                      >
                        Không có dữ liệu tồn phòng
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
            <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
              (Giả lập) Click ô để chỉnh available / block / giá.
            </div>
          </div>
        )}
      </div>

      {/* Housekeeping & Maintenance */}
      <div>
        {sectionHeader(
          "Bảo trì & Housekeeping",
          "housekeeping",
          <Wrench className="w-4 h-4" />
        )}
        {!collapsed["housekeeping"] && (
          <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-6">
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3 md:col-span-2">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Trạng thái phòng
              </h4>
              <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
                {housekeepingProblems.map((r) => {
                  const mapColor =
                    r.status === "maintenance"
                      ? "bg-red-50 dark:bg-red-900/30 border-red-200 dark:border-red-700 text-red-700 dark:text-red-300"
                      : r.status === "cleaning"
                      ? "bg-amber-50 dark:bg-amber-900/30 border-amber-200 dark:border-amber-700 text-amber-700 dark:text-amber-300"
                      : "bg-green-50 dark:bg-green-900/30 border-green-200 dark:border-green-700 text-green-700 dark:text-green-300";
                  return (
                    <div
                      key={r.id}
                      className={cx(
                        "theme-border rounded p-3 flex flex-col gap-1 caption-mobile sm:caption-tablet lg:caption-desktop border",
                        mapColor
                      )}
                    >
                      <span className="font-semibold">
                        Phòng {r.room_label}
                      </span>
                      <span>Trạng thái: {r.status}</span>
                      {r.reason && <span>Lý do: {r.reason}</span>}
                      <div className="flex gap-2 pt-1">
                        <button className="px-2 py-0.5 rounded bg-indigo-600 text-white hover:bg-indigo-700">
                          Lịch bảo trì
                        </button>
                        <button className="px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-600 hover:bg-gray-300 dark:hover:bg-gray-500">
                          Báo housekeeping
                        </button>
                      </div>
                    </div>
                  );
                })}
                {housekeepingProblems.length === 0 && (
                  <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                    Không có vấn đề
                  </div>
                )}
              </div>
            </div>
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Ghi chú nhanh
              </h4>
              <div className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                <button className="px-3 py-2 rounded theme-border hover:opacity-80 flex items-center gap-2">
                  <Wrench className="w-4 h-4" /> Tạo bảo trì
                </button>
                <button className="px-3 py-2 rounded theme-border hover:opacity-80 flex items-center gap-2">
                  <DoorClosed className="w-4 h-4" /> Chặn phòng
                </button>
                <button className="px-3 py-2 rounded theme-border hover:opacity-80 flex items-center gap-2">
                  <MessageCircle className="w-4 h-4" /> Gửi thông báo
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Pricing & Rate Plans */}
      <div>
        {sectionHeader(
          "Rate Plans & Giá",
          "pricing",
          <Tag className="w-4 h-4" />
        )}
        {!collapsed["pricing"] && (
          <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-4">
            <div className="flex flex-wrap gap-2">
              <button className="btn-primary btn-text-responsive flex items-center gap-2">
                <Plus className="w-4 h-4" /> Thêm Rate Plan
              </button>
              <button className="btn-outline btn-text-responsive flex items-center gap-2">
                <Sparkles className="w-4 h-4" /> Thêm Rate Rule
              </button>
            </div>
            <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-4">
              {ratePlansPreview.map((rp) => {
                const h = hotels.find((x) => x.id === rp.hotel_id)!;
                return (
                  <div
                    key={rp.id}
                    className="theme-border rounded p-3 bg-gray-50 dark:bg-gray-800/40 flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop"
                  >
                    <div className="flex items-center justify-between">
                      <span className="font-semibold line-clamp-1">
                        {h.title}
                      </span>
                      <span className="overline-mobile sm:overline-tablet lg:overline-desktop">
                        #{rp.id}
                      </span>
                    </div>
                    <div>Room: {rp.room_type}</div>
                    <div>
                      Plan: <strong>{rp.name}</strong>
                    </div>
                    <div>
                      Giá: <strong>{fmtCurrency(rp.base_price)}</strong>
                    </div>
                    <div>
                      Hoàn hủy: {rp.refundable ? "Có" : "Không"}{" "}
                      {rp.meal_plan ? `• ${rp.meal_plan}` : ""}
                    </div>
                    <div className="flex gap-2 pt-1">
                      <button className="flex-1 px-2 py-0.5 rounded theme-border hover:opacity-80">
                        Sửa
                      </button>
                      <button className="flex-1 px-2 py-0.5 rounded theme-border hover:opacity-80">
                        Giả lập
                      </button>
                    </div>
                  </div>
                );
              })}
              {ratePlansPreview.length === 0 && (
                <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                  Không có rate plan
                </div>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Reviews Snapshot */}
      <div>
        {sectionHeader(
          "Đánh giá gần đây",
          "reviews",
          <Star className="w-4 h-4" />
        )}
        {!collapsed["reviews"] && (
          <div className="theme-border rounded theme-bg-card p-4 grid md:grid-cols-2 xl:grid-cols-3 gap-4">
            {reviewPreview.map((r) => {
              const h = hotels.find((x) => x.id === r.hotel_id)!;
              return (
                <div
                  key={r.id}
                  className="theme-border rounded p-3 flex flex-col gap-2 bg-gray-50 dark:bg-gray-800/40"
                >
                  <div className="flex items-center justify-between">
                    <span className="caption-mobile sm:caption-tablet lg:caption-desktop font-semibold line-clamp-1">
                      {h.title}
                    </span>
                    <span className="flex items-center gap-1 caption-mobile sm:caption-tablet lg:caption-desktop">
                      <Star className="w-3 h-3 text-yellow-500 fill-yellow-500" />
                      {r.rating.toFixed(1)}
                    </span>
                  </div>
                  <div className="flex flex-wrap gap-2 overline-mobile sm:overline-tablet lg:overline-desktop">
                    <span>Clean {r.aspects.cleanliness.toFixed(1)}</span>
                    <span>Service {r.aspects.service.toFixed(1)}</span>
                    <span>Facilities {r.aspects.facilities.toFixed(1)}</span>
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
            {reviewPreview.length === 0 && (
              <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary col-span-full">
                Không có đánh giá
              </div>
            )}
          </div>
        )}
      </div>

      {/* Media & Virtual Tours */}
      <div>
        {sectionHeader(
          "Media & Virtual Tours",
          "mediaVirtual",
          <Video className="w-4 h-4" />
        )}
        {!collapsed["mediaVirtual"] && (
          <div className="grid md:grid-cols-2 gap-6">
            <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-3">
              <h4 className="h6-mobile sm:h6-tablet lg:h6-desktop font-semibold">
                Virtual Tours
              </h4>
              <div className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                <div className="theme-border rounded p-3 bg-gray-50 dark:bg-gray-800/40 flex items-center justify-between">
                  <span>Tour sảnh chính</span>
                  <button className="px-2 py-0.5 rounded bg-blue-600 text-white hover:bg-blue-700">
                    Xem
                  </button>
                </div>
                <div className="theme-border rounded p-3 bg-gray-50 dark:bg-gray-800/40 flex items-center justify-between">
                  <span>Phòng mẫu Deluxe</span>
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
                SEO & Checklist
              </h4>
              <ul className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-green-500" />
                  Ảnh đại diện đầy đủ
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-green-500" />
                  Thẻ tiêu đề SEO
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-amber-500" />
                  Meta description (thiếu)
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-amber-500" />
                  Virtual tour (cần thêm phòng khác)
                </li>
              </ul>
              <div className="flex gap-2 pt-1">
                <button className="flex-1 px-3 py-2 rounded theme-border hover:opacity-80 caption-mobile sm:caption-tablet lg:caption-desktop">
                  Cập nhật SEO
                </button>
                <button className="flex-1 px-3 py-2 rounded theme-border hover:opacity-80 caption-mobile sm:caption-tablet lg:caption-desktop">
                  Thêm media
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
                        <TriangleAlert className="w-3 h-3" />
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
                Hoạt động
              </h4>
              <div className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                {activityRecent.map((act) => {
                  const h = hotels.find((x) => x.id === act.hotel_id);
                  return (
                    <div
                      key={act.id}
                      className="theme-border rounded px-2 py-1 bg-gray-50 dark:bg-gray-800/40 flex items-center gap-2"
                    >
                      <History className="w-3 h-3 text-gray-500 dark:text-gray-400" />
                      <span className="flex-1 line-clamp-1">
                        {act.action} {h ? `(${h.title})` : ""}
                      </span>
                      <span className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
                        {act.created_at.slice(11, 16)}
                      </span>
                    </div>
                  );
                })}
                {activityRecent.length === 0 && (
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
        <span>UI tĩnh • dữ liệu giả lập • tích hợp API sau.</span>
        <span>Heatmap: Xanh tốt • Vàng thấp • Xám hết / trống • Đỏ block.</span>
      </div>
    </div>
  );
};

export default DashboardHotelPage;
