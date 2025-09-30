import React, { useMemo, useState } from "react";
import {
  UtensilsCrossed,
  Plus,
  Search,
  Filter,
  Star,
  Pencil,
  CalendarDays,
  Power,
  Archive,
  ChevronDown,
  ChevronUp,
  Clock,
  Tag,
  RefreshCw,
  History,
  DollarSign,
  MessageCircle,
  XCircle,
  TriangleAlert,
  ShieldAlert,
  Table2,
  LayoutGrid,
  ChefHat,
  Sparkles,
  Check,
  Ban,
} from "lucide-react";

/* ===================== Types ===================== */
type RestaurantStatus = "draft" | "published" | "archived" | "disabled";

interface Restaurant {
  id: number;
  title: string;
  slug: string;
  area: string;
  cuisines: string[];
  price_level: 1 | 2 | 3 | 4; // $ - $$$$
  opening_hours: {
    breakfast: boolean;
    lunch: boolean;
    dinner: boolean;
  };
  status: RestaurantStatus;
  visibility: "public" | "private";
  thumbnail_url?: string | null;
  rating_average: number;
  upcoming_reservations: number;
  created_at: string;
  updated_at: string;
}

interface Reservation {
  id: number;
  restaurant_id: number;
  guest_name: string;
  pax: number;
  timeslot: string; // ISO date-time truncated to hour
  booking_status: "pending" | "confirmed" | "cancelled" | "no_show";
  payment_status: "pending" | "paid" | "partial";
  avg_spend: number;
}

interface TimeslotAgg {
  timeslot: string;
  count: number;
  confirmed: number;
  pending: number;
  no_show_risk: boolean;
}

interface TableSeat {
  id: number;
  label: string;
  capacity: number;
  status: "free" | "reserved" | "occupied" | "blocked";
  current_reservation_id?: number;
}

interface MenuItem {
  id: number;
  restaurant_id: number;
  name: string;
  price: number;
  currency: string;
  category: string;
  special: boolean;
}

interface Review {
  id: number;
  restaurant_id: number;
  guest: string;
  rating: number;
  aspects: {
    quality: number;
    ambience: number;
  };
  content: string;
  created_at: string;
}

interface AlertItem {
  id: number;
  type: "high_demand" | "no_show_repeat" | "certificate_expired";
  message: string;
  severity: "info" | "warn" | "critical";
  created_at: string;
}

interface ActivityLog {
  id: number;
  action:
    | "publish"
    | "unpublish"
    | "menu_update"
    | "reservation_confirm"
    | "reservation_cancel"
    | "table_assign"
    | "special_add";
  restaurant_id?: number;
  meta?: Record<string, unknown>;
  created_at: string;
}

/* ===================== Mock Data Generators ===================== */
const areas = ["Hà Nội", "TP.HCM", "Đà Nẵng", "Huế", "Phú Quốc"];
const cuisinePool = [
  "Vietnamese",
  "Japanese",
  "Italian",
  "Seafood",
  "BBQ",
  "Vegan",
  "Thai",
  "French",
];
function rand<T>(arr: T[]) {
  return arr[Math.floor(Math.random() * arr.length)];
}
function randomSubset<T>(arr: T[], min = 1, max = 3) {
  const copy = [...arr];
  const out: T[] = [];
  const n = Math.min(
    max,
    Math.max(min, Math.floor(Math.random() * (max - min + 1)) + min)
  );
  while (out.length < n && copy.length) {
    const idx = Math.floor(Math.random() * copy.length);
    out.push(copy.splice(idx, 1)[0]);
  }
  return out;
}

function genRestaurants(): Restaurant[] {
  const now = Date.now();
  const list: Restaurant[] = [];
  for (let i = 1; i <= 16; i++) {
    list.push({
      id: i,
      title: `Restaurant #${i}`,
      slug: `restaurant-${i}`,
      area: rand(areas),
      cuisines: randomSubset(cuisinePool, 1, 3),
      price_level: (1 + (i % 4)) as 1 | 2 | 3 | 4,
      opening_hours: {
        breakfast: Math.random() > 0.5,
        lunch: Math.random() > 0.3,
        dinner: Math.random() > 0.2,
      },
      status: rand(["published", "draft", "archived", "disabled"]),
      visibility: Math.random() > 0.2 ? "public" : "private",
      thumbnail_url:
        Math.random() > 0.1
          ? `https://picsum.photos/seed/restaurant-${i}/210/150.webp`
          : null,
      rating_average: parseFloat((3 + Math.random() * 2).toFixed(1)),
      upcoming_reservations: 2 + Math.floor(Math.random() * 18),
      created_at: new Date(now - i * 86400000).toISOString(),
      updated_at: new Date(now - i * 3600000).toISOString(),
    });
  }
  return list;
}

function genReservations(restaurants: Restaurant[]): Reservation[] {
  const arr: Reservation[] = [];
  const now = Date.now();
  for (let i = 1; i <= 120; i++) {
    const r = rand(restaurants);
    const hoursAhead = Math.floor(Math.random() * 48); // next 48h
    const start = new Date(now + hoursAhead * 3600000);
    start.setMinutes(0, 0, 0);
    arr.push({
      id: 9000 + i,
      restaurant_id: r.id,
      guest_name: `Guest ${i}`,
      pax: 2 + (i % 5),
      timeslot: start.toISOString(),
      booking_status: rand(["pending", "confirmed", "cancelled"]),
      payment_status: rand(["pending", "paid", "partial"]),
      avg_spend: 150000 + ((i * 27100) % 350000),
    });
  }
  return arr;
}

function genTimeslotAgg(reservations: Reservation[]): TimeslotAgg[] {
  const map = new Map<string, TimeslotAgg>();
  reservations.forEach((r) => {
    const key = r.timeslot;
    const item =
      map.get(key) ||
      ({
        timeslot: key,
        count: 0,
        confirmed: 0,
        pending: 0,
        no_show_risk: false,
      } as TimeslotAgg);
    item.count++;
    if (r.booking_status === "confirmed") item.confirmed++;
    if (r.booking_status === "pending") item.pending++;
    item.no_show_risk = item.pending > 2 && Math.random() > 0.6;
    map.set(key, item);
  });
  return Array.from(map.values())
    .sort(
      (a, b) => new Date(a.timeslot).getTime() - new Date(b.timeslot).getTime()
    )
    .slice(0, 24)
    .sort((a, b) => b.count - a.count);
}

function genSeatMap(restaurants: Restaurant[]): TableSeat[] {
  const tables: TableSeat[] = [];
  restaurants.slice(0, 4).forEach((r) => {
    for (let i = 1; i <= 10; i++) {
      tables.push({
        id: r.id * 100 + i,
        label: `T${i}`,
        capacity: 2 + (i % 4) * 2,
        status: rand(["free", "reserved", "occupied", "free", "free"]),
        current_reservation_id:
          Math.random() > 0.7
            ? 9000 + Math.floor(Math.random() * 50)
            : undefined,
      });
    }
  });
  return tables;
}

function genMenu(restaurants: Restaurant[]): MenuItem[] {
  const arr: MenuItem[] = [];
  let id = 1;
  restaurants.slice(0, 6).forEach((r) => {
    ["Starter", "Main", "Dessert"].forEach((cat) => {
      for (let i = 0; i < 3; i++) {
        arr.push({
          id: id++,
          restaurant_id: r.id,
          name: `${cat} #${i + 1} R${r.id}`,
          price: 90000 + (((r.id + i) * 17000) % 120000),
          currency: "VND",
          category: cat,
          special: Math.random() > 0.75,
        });
      }
    });
  });
  return arr;
}

function genReviews(restaurants: Restaurant[]): Review[] {
  const arr: Review[] = [];
  let id = 1;
  restaurants.slice(0, 6).forEach((r) => {
    const n = 1 + (r.id % 3);
    for (let i = 0; i < n; i++) {
      arr.push({
        id: id++,
        restaurant_id: r.id,
        guest: `Reviewer ${id}`,
        rating: parseFloat((3 + Math.random() * 2).toFixed(1)),
        aspects: {
          quality: parseFloat((3 + Math.random() * 2).toFixed(1)),
          ambience: parseFloat((3 + Math.random() * 2).toFixed(1)),
        },
        content: "Món ăn ngon, không gian ổn (mock).",
        created_at: new Date(Date.now() - i * 5400000).toISOString(),
      });
    }
  });
  return arr;
}

function genAlerts(restaurants: Restaurant[]): AlertItem[] {
  return [
    {
      id: 1,
      type: "high_demand",
      message: `Slot 19:00 hôm nay nhu cầu cao (${restaurants[0].title})`,
      severity: "warn",
      created_at: new Date().toISOString(),
    },
    {
      id: 2,
      type: "no_show_repeat",
      message: "Khách A đã no-show 3 lần",
      severity: "info",
      created_at: new Date().toISOString(),
    },
    {
      id: 3,
      type: "certificate_expired",
      message: "Chứng nhận an toàn thực phẩm hết hạn",
      severity: "critical",
      created_at: new Date().toISOString(),
    },
  ];
}

function genActivities(restaurants: Restaurant[]): ActivityLog[] {
  const actions: ActivityLog["action"][] = [
    "publish",
    "unpublish",
    "menu_update",
    "reservation_confirm",
    "reservation_cancel",
    "table_assign",
    "special_add",
  ];
  const arr: ActivityLog[] = [];
  for (let i = 0; i < 20; i++) {
    const r = rand(restaurants);
    arr.push({
      id: i + 1,
      action: rand(actions),
      restaurant_id: r.id,
      meta: { title: r.title },
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
const DashboardRestaurantPage: React.FC = () => {
  // Seeds
  const [restaurants] = useState<Restaurant[]>(() => genRestaurants());
  const [reservations] = useState<Reservation[]>(() =>
    genReservations(restaurants)
  );
  const [seatMap] = useState<TableSeat[]>(() => genSeatMap(restaurants));
  const [menuItems] = useState<MenuItem[]>(() => genMenu(restaurants));
  const [reviews] = useState<Review[]>(() => genReviews(restaurants));
  const [alerts] = useState<AlertItem[]>(() => genAlerts(restaurants));
  const [activities] = useState<ActivityLog[]>(() =>
    genActivities(restaurants)
  );

  // Filters
  const [search, setSearch] = useState("");
  const [filterArea, setFilterArea] = useState("");
  const [filterCuisine, setFilterCuisine] = useState("");
  const [filterPrice, setFilterPrice] = useState("");
  const [filterHours, setFilterHours] = useState("");
  const [filterStatus, setFilterStatus] = useState<RestaurantStatus | "">("");

  // Collapse
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});
  const toggleCollapse = (k: string) =>
    setCollapsed((p) => ({ ...p, [k]: !p[k] }));

  // Selection
  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set());
  const toggleSelectAll = (rows: Restaurant[]) => {
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

  // Filtered list
  const filteredRestaurants = useMemo(() => {
    return restaurants.filter((r) => {
      if (search) {
        const q = search.toLowerCase();
        if (
          !r.title.toLowerCase().includes(q) &&
          !r.slug.toLowerCase().includes(q) &&
          !String(r.id).includes(q)
        )
          return false;
      }
      if (filterArea && r.area !== filterArea) return false;
      if (filterCuisine && !r.cuisines.includes(filterCuisine)) return false;
      if (filterPrice && r.price_level !== Number(filterPrice)) return false;
      if (filterHours) {
        if (!r.opening_hours[filterHours as keyof typeof r.opening_hours])
          return false;
      }
      if (filterStatus && r.status !== filterStatus) return false;
      return true;
    });
  }, [
    restaurants,
    search,
    filterArea,
    filterCuisine,
    filterPrice,
    filterHours,
    filterStatus,
  ]);

  // Timeslots aggregated (for snapshot)
  const timeslotAgg = useMemo(
    () => genTimeslotAgg(reservations),
    [reservations]
  );

  // Compute KPIs (mock)
  const kpis = useMemo(() => {
    const today = new Date().toISOString().substring(0, 10);
    const resToday = reservations.filter((r) => r.timeslot.startsWith(today));
    const reservationsToday = resToday.length;

    // Table turnover approx: (total covers / number of distinct tables?) - mock
    const totalPax = resToday.reduce((s, r) => s + r.pax, 0);
    const turnover = resToday.length
      ? totalPax / Math.max(1, resToday.length)
      : 0;

    // no-show rate: percent with status cancelled (mock treat cancelled as no-show surrogate)
    const noShows = resToday.filter(
      (r) => r.booking_status === "cancelled"
    ).length;
    const noShowRate = resToday.length ? (noShows / resToday.length) * 100 : 0;

    const avgSpend =
      resToday.length > 0
        ? resToday.reduce((s, r) => s + r.avg_spend, 0) / resToday.length
        : 0;

    const pending = reservations.filter(
      (r) => r.booking_status === "pending"
    ).length;

    return {
      reservationsToday,
      turnover,
      noShowRate,
      avgSpend,
      pending,
    };
  }, [reservations]);

  // Seat map selected restaurant
  const [seatRestaurantId, setSeatRestaurantId] = useState<number>(() =>
    restaurants.length ? restaurants[0].id : 0
  );
  const seatTables = useMemo(
    () => seatMap.filter((t) => Math.floor(t.id / 100) === seatRestaurantId),
    [seatMap, seatRestaurantId]
  );

  // Menu preview
  const menuPreview = useMemo(
    () =>
      menuItems.filter((m) => m.restaurant_id === seatRestaurantId).slice(0, 6),
    [menuItems, seatRestaurantId]
  );

  const reviewPreview = useMemo(() => reviews.slice(0, 5), [reviews]);
  const alertsRecent = useMemo(() => alerts.slice(0, 6), [alerts]);
  const activitiesRecent = useMemo(() => activities.slice(0, 10), [activities]);

  // Bulk actions (mock)
  const bulkPublish = () => {
    console.log("Bulk publish restaurants:", Array.from(selectedIds));
    alert("Bulk publish (mock)");
  };
  const bulkArchive = () => {
    console.log("Bulk archive restaurants:", Array.from(selectedIds));
    alert("Bulk archive (mock)");
  };
  const clearFilters = () => {
    setSearch("");
    setFilterArea("");
    setFilterCuisine("");
    setFilterPrice("");
    setFilterHours("");
    setFilterStatus("");
  };

  // Helpers
  const statusBadge = (status: RestaurantStatus) => {
    const map: Record<RestaurantStatus, string> = {
      published:
        "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
      draft:
        "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
      archived: "bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-200",
      disabled: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300",
    };
    const label: Record<RestaurantStatus, string> = {
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
            {icon || <UtensilsCrossed className="w-4 h-4" />}
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
            <UtensilsCrossed className="w-7 h-7 icon-brand" />
            Dashboard Nhà Hàng
          </h1>
          <span className="body2-mobile sm:body2-tablet lg:body2-desktop theme-text-secondary">
            Nhà cung cấp: <strong>Mock Provider Co.</strong>
          </span>
          <div className="ml-auto flex gap-2">
            <button className="btn-primary btn-text-responsive flex items-center gap-2">
              <Plus className="w-4 h-4" />
              Tạo nhà hàng
            </button>
            <button className="btn-outline btn-text-responsive flex items-center gap-2">
              <ChefHat className="w-4 h-4" />
              Thêm món đặc biệt
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
              Ẩm thực
            </label>
            <select
              value={filterCuisine}
              onChange={(e) => setFilterCuisine(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Tất cả</option>
              {cuisinePool.map((c) => (
                <option key={c}>{c}</option>
              ))}
            </select>
          </div>
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Price
            </label>
            <select
              value={filterPrice}
              onChange={(e) => setFilterPrice(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">All</option>
              {[1, 2, 3, 4].map((p) => (
                <option key={p} value={p}>
                  {"$".repeat(p)}
                </option>
              ))}
            </select>
          </div>
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Giờ phục vụ
            </label>
            <select
              value={filterHours}
              onChange={(e) => setFilterHours(e.target.value)}
              className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
            >
              <option value="">Tất cả</option>
              <option value="breakfast">Breakfast</option>
              <option value="lunch">Lunch</option>
              <option value="dinner">Dinner</option>
            </select>
          </div>
          <div className="flex flex-col">
            <label className="overline-mobile sm:overline-tablet lg:overline-desktop theme-text-secondary">
              Trạng thái
            </label>
            <select
              value={filterStatus}
              onChange={(e) =>
                setFilterStatus(e.target.value as RestaurantStatus | "")
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

      {/* KPI */}
      <div>
        {sectionHeader("Chỉ số (KPI)", "kpi", <Filter className="w-4 h-4" />)}
        {!collapsed["kpi"] && (
          <div className="grid sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-5 gap-4">
            {renderKPI(
              "Reservation hôm nay",
              kpis.reservationsToday,
              <CalendarDays className="w-4 h-4" />
            )}
            {renderKPI(
              "Turnover bàn (avg)",
              kpis.turnover.toFixed(1),
              <LayoutGrid className="w-4 h-4" />
            )}
            {renderKPI(
              "No-show rate",
              `${kpis.noShowRate.toFixed(1)}%`,
              <TriangleAlert className="w-4 h-4" />
            )}
            {renderKPI(
              "Chi tiêu TB",
              fmtCurrency(Math.round(kpis.avgSpend)),
              <DollarSign className="w-4 h-4" />
            )}
            {renderKPI("Pending", kpis.pending, <Clock className="w-4 h-4" />)}
          </div>
        )}
      </div>

      {/* Listings */}
      <div>
        {sectionHeader(
          "Danh sách Nhà hàng",
          "restaurants",
          <UtensilsCrossed className="w-4 h-4" />,
          <span className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
            {filteredRestaurants.length} kết quả
          </span>
        )}
        {!collapsed["restaurants"] && (
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
                          filteredRestaurants.length > 0 &&
                          filteredRestaurants.every((r) =>
                            selectedIds.has(r.id)
                          )
                        }
                        onChange={() => toggleSelectAll(filteredRestaurants)}
                      />
                    </th>
                    <th className="p-2">Ảnh</th>
                    <th className="p-2">Tiêu đề / Slug</th>
                    <th className="p-2">Ẩm thực</th>
                    <th className="p-2">Price</th>
                    <th className="p-2">Giờ</th>
                    <th className="p-2">Rating</th>
                    <th className="p-2">Resv sắp tới</th>
                    <th className="p-2">Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredRestaurants.map((r) => (
                    <tr
                      key={r.id}
                      className="border-t theme-border hover:bg-gray-50 dark:hover:bg-gray-800/40 transition-colors"
                    >
                      <td className="p-2">
                        <input
                          type="checkbox"
                          checked={selectedIds.has(r.id)}
                          onChange={() => toggleSelectOne(r.id)}
                        />
                      </td>
                      <td className="p-2">
                        <div className="w-20 h-14 bg-gray-100 dark:bg-gray-700 rounded overflow-hidden flex items-center justify-center">
                          {r.thumbnail_url ? (
                            <img
                              src={r.thumbnail_url}
                              alt={r.title}
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
                            {r.title}
                          </button>
                          <span className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                            {r.slug}
                          </span>
                          {statusBadge(r.status)}
                        </div>
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        <div className="flex flex-wrap gap-1">
                          {r.cuisines.map((c) => (
                            <span
                              key={c}
                              className="px-2 py-0.5 rounded bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-300 overline-mobile sm:overline-tablet lg:overline-desktop"
                            >
                              {c}
                            </span>
                          ))}
                        </div>
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {"$".repeat(r.price_level)}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {["breakfast", "lunch", "dinner"]
                          .filter(
                            (k) =>
                              r.opening_hours[k as keyof typeof r.opening_hours]
                          )
                          .join(" / ") || "—"}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {r.rating_average.toFixed(1)}
                      </td>
                      <td className="p-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                        {r.upcoming_reservations}
                      </td>
                      <td className="p-2 align-top">
                        <div className="flex flex-wrap gap-1">
                          {[
                            { ic: Pencil, t: "Menu" },
                            { ic: CalendarDays, t: "Reservations" },
                            { ic: Table2, t: "Tables" },
                            { ic: Power, t: "Publish" },
                            { ic: Archive, t: "Archive" },
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
                  ))}
                  {filteredRestaurants.length === 0 && (
                    <tr>
                      <td
                        className="p-4 text-center caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary"
                        colSpan={9}
                      >
                        Không tìm thấy nhà hàng
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>

      {/* Reservations Snapshot (Timeslots) */}
      <div>
        {sectionHeader(
          "Timeslot đặt chỗ (48h)",
          "reservations",
          <Clock className="w-4 h-4" />,
          <button className="caption-mobile sm:caption-tablet lg:caption-desktop flex items-center gap-1 px-2 py-1 rounded theme-border hover:opacity-80">
            <RefreshCw className="w-3 h-3" />
            Làm mới
          </button>
        )}
        {!collapsed["reservations"] && (
          <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-4">
            <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-4">
              {timeslotAgg.slice(0, 9).map((t) => {
                const date = new Date(t.timeslot);
                const label = `${date.toISOString().substring(5, 10)} ${date
                  .toISOString()
                  .substring(11, 16)}`;
                return (
                  <div
                    key={t.timeslot}
                    className={cx(
                      "theme-border rounded p-3 flex flex-col gap-2 bg-gray-50 dark:bg-gray-800/40 caption-mobile sm:caption-tablet lg:caption-desktop",
                      t.no_show_risk
                        ? "border-amber-300"
                        : t.count > 6
                        ? "border-green-300"
                        : ""
                    )}
                  >
                    <div className="flex items-center justify-between">
                      <span className="font-semibold">{label}</span>
                      <span
                        className={cx(
                          "px-2 py-0.5 rounded overline-mobile sm:overline-tablet lg:overline-desktop",
                          t.count > 6
                            ? "bg-green-200 text-green-800 dark:bg-green-900/30 dark:text-green-300"
                            : "bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-300"
                        )}
                      >
                        {t.count}
                      </span>
                    </div>
                    <div className="flex gap-3 overline-mobile sm:overline-tablet lg:overline-desktop">
                      <span>Conf: {t.confirmed}</span>
                      <span>Pending: {t.pending}</span>
                    </div>
                    {t.no_show_risk && (
                      <span className="overline-mobile sm:overline-tablet lg:overline-desktop text-amber-600 dark:text-amber-400">
                        Nguy cơ no-show
                      </span>
                    )}
                    <div className="flex flex-wrap gap-1 pt-1">
                      <button className="px-2 py-0.5 rounded bg-green-600 text-white hover:bg-green-700 overline-mobile sm:overline-tablet lg:overline-desktop flex items-center gap-1">
                        <Check className="w-3 h-3" /> Confirm
                      </button>
                      <button className="px-2 py-0.5 rounded bg-red-600 text-white hover:bg-red-700 overline-mobile sm:overline-tablet lg:overline-desktop flex items-center gap-1">
                        <Ban className="w-3 h-3" /> Cancel
                      </button>
                      <button className="px-2 py-0.5 rounded bg-indigo-100 hover:bg-indigo-200 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300 overline-mobile sm:overline-tablet lg:overline-desktop">
                        Waitlist
                      </button>
                      <button className="px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-600 hover:bg-gray-300 dark:hover:bg-gray-500 overline-mobile sm:overline-tablet lg:overline-desktop">
                        <MessageCircle className="w-3 h-3" />
                      </button>
                      <button className="px-2 py-0.5 rounded bg-blue-100 hover:bg-blue-200 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300 overline-mobile sm:overline-tablet lg:overline-desktop flex items-center gap-1">
                        <Table2 className="w-3 h-3" /> Assign
                      </button>
                    </div>
                  </div>
                );
              })}
              {timeslotAgg.length === 0 && (
                <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                  Không có dữ liệu timeslot
                </div>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Seat Map Mini */}
      <div>
        {sectionHeader(
          "Sơ đồ bàn (mini)",
          "seatmap",
          <Table2 className="w-4 h-4" />,
          <select
            value={seatRestaurantId}
            onChange={(e) => setSeatRestaurantId(Number(e.target.value))}
            className="theme-border rounded px-2 py-1 caption-mobile sm:caption-tablet lg:caption-desktop theme-bg-card"
          >
            {restaurants.slice(0, 8).map((r) => (
              <option key={r.id} value={r.id}>
                #{r.id} {r.title.slice(0, 22)}
              </option>
            ))}
          </select>
        )}
        {!collapsed["seatmap"] && (
          <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-4">
            <div className="grid grid-cols-5 sm:grid-cols-8 md:grid-cols-10 gap-2">
              {seatTables.map((t) => {
                const cls =
                  t.status === "free"
                    ? "bg-green-200 text-green-800 dark:bg-green-900/40 dark:text-green-300"
                    : t.status === "reserved"
                    ? "bg-amber-200 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300"
                    : t.status === "occupied"
                    ? "bg-red-200 text-red-800 dark:bg-red-900/40 dark:text-red-300"
                    : "bg-gray-300 text-gray-700 dark:bg-gray-700 dark:text-gray-300";
                return (
                  <div
                    key={t.id}
                    className={cx(
                      "h-16 rounded flex flex-col items-center justify-center relative cursor-pointer hover:ring-2 ring-light-focus dark:ring-dark-focus transition caption-mobile sm:caption-tablet lg:caption-desktop font-medium",
                      cls
                    )}
                    title={t.label}
                  >
                    <span>{t.label}</span>
                    <span className="overline-mobile sm:overline-tablet lg:overline-desktop">
                      {t.capacity}
                    </span>
                    {t.current_reservation_id && (
                      <span className="absolute bottom-1 right-1 overline-mobile sm:overline-tablet lg:overline-desktop bg-black/30 text-white px-1 rounded">
                        R
                      </span>
                    )}
                  </div>
                );
              })}
              {seatTables.length === 0 && (
                <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                  Không có dữ liệu bàn
                </div>
              )}
            </div>
            <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
              (Giả lập) — sau này click bàn để gán / bỏ gán / block bảo trì.
            </div>
          </div>
        )}
      </div>

      {/* Menu & Specials */}
      <div>
        {sectionHeader(
          "Menu & Specials",
          "menu",
          <ChefHat className="w-4 h-4" />
        )}
        {!collapsed["menu"] && (
          <div className="theme-border rounded theme-bg-card p-4 flex flex-col gap-4">
            <div className="flex flex-wrap gap-2">
              <button className="btn-primary btn-text-responsive flex items-center gap-2">
                <Plus className="w-4 h-4" /> Thêm món
              </button>
              <button className="btn-outline btn-text-responsive flex items-center gap-2">
                <Sparkles className="w-4 h-4" /> Thêm special
              </button>
              <button className="btn-outline btn-text-responsive flex items-center gap-2">
                <Tag className="w-4 h-4" /> Test promo
              </button>
            </div>
            <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-4">
              {menuPreview.map((m) => (
                <div
                  key={m.id}
                  className="theme-border rounded p-3 bg-gray-50 dark:bg-gray-800/40 flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop"
                >
                  <div className="flex items-center justify-between">
                    <span className="font-semibold line-clamp-1">{m.name}</span>
                    <span className="overline-mobile sm:overline-tablet lg:overline-desktop">
                      {fmtCurrency(m.price)}
                    </span>
                  </div>
                  <div className="overline-mobile sm:overline-tablet lg:overline-desktop">
                    {m.category} {m.special && "• Special"}
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
              ))}
              {menuPreview.length === 0 && (
                <div className="caption-mobile sm:caption-tablet lg:caption-desktop theme-text-secondary">
                  Không có món
                </div>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Reviews */}
      <div>
        {sectionHeader(
          "Đánh giá & Rating",
          "reviews",
          <Star className="w-4 h-4" />
        )}
        {!collapsed["reviews"] && (
          <div className="theme-border rounded theme-bg-card p-4 grid md:grid-cols-2 xl:grid-cols-3 gap-4">
            {reviewPreview.map((r) => {
              const rest = restaurants.find((x) => x.id === r.restaurant_id)!;
              return (
                <div
                  key={r.id}
                  className="theme-border rounded p-3 flex flex-col gap-2 bg-gray-50 dark:bg-gray-800/40"
                >
                  <div className="flex items-center justify-between">
                    <span className="caption-mobile sm:caption-tablet lg:caption-desktop font-semibold line-clamp-1">
                      {rest.title}
                    </span>
                    <span className="flex items-center gap-1 caption-mobile sm:caption-tablet lg:caption-desktop">
                      <Star className="w-3 h-3 text-yellow-500 fill-yellow-500" />
                      {r.rating.toFixed(1)}
                    </span>
                  </div>
                  <div className="flex flex-wrap gap-2 overline-mobile sm:overline-tablet lg:overline-desktop">
                    <span>Quality {r.aspects.quality.toFixed(1)}</span>
                    <span>Ambience {r.aspects.ambience.toFixed(1)}</span>
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
                Hoạt động gần đây
              </h4>
              <div className="flex flex-col gap-2 caption-mobile sm:caption-tablet lg:caption-desktop">
                {activitiesRecent.map((act) => {
                  const r = restaurants.find((x) => x.id === act.restaurant_id);
                  return (
                    <div
                      key={act.id}
                      className="theme-border rounded px-2 py-1 bg-gray-50 dark:bg-gray-800/40 flex items-center gap-2"
                    >
                      <History className="w-3 h-3 text-gray-500 dark:text-gray-400" />
                      <span className="flex-1 line-clamp-1">
                        {act.action} {r ? `(${r.title})` : ""}
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
        <span>UI tĩnh • dữ liệu mock • tích hợp API sau.</span>
        <span>
          Legend seat map: Xanh=free • Vàng=reserved • Đỏ=occupied •
          Xám=blocked.
        </span>
      </div>
    </div>
  );
};

export default DashboardRestaurantPage;
