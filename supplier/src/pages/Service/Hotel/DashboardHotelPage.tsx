import React, { useState, useMemo, type JSX } from "react";
import { useNavigate } from "react-router-dom";
import {
  Hotel,
  Plus,
  Search,
  RefreshCw,
  X,
  CheckSquare,
  Square,
  ChevronDown,
  ChevronUp,
  MapPin,
  Star,
  DollarSign,
  Calendar,
  TrendingUp,
  AlertCircle,
  Loader2,
  Clock,
  Bell,
  Activity,
  MessageSquare,
  Settings,
  Image as ImageIcon,
  Eye,
  Edit,
  Trash2,
  Archive,
  Upload,
} from "lucide-react";
import { useHotels } from "../../../hooks/useHotels";
import type { HotelDTO } from "../../../types";
import { deleteHotel } from "../../../services/hotelService";

/* ===================== Mock Types cho các phần tĩnh ===================== */
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
  meta?: {
    title?: string;
    [key: string]: string | number | boolean | undefined;
  };
  created_at: string;
}

/* ===================== Mock Generators ===================== */
const roomTypes = ["Standard", "Deluxe", "Suite", "Family", "Studio"] as const;

function rand<T>(arr: readonly T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

function genReservations(hotels: HotelDTO[]): Reservation[] {
  const arr: Reservation[] = [];
  const now = Date.now();
  for (let i = 1; i <= 30; i++) {
    const h = hotels[Math.floor(Math.random() * hotels.length)];
    if (!h || !h.hotelId) continue;
    const offset = Math.floor(Math.random() * 3);
    const ci = new Date(now + offset * 86400000).toISOString().substring(0, 10);
    const co = new Date(
      new Date(ci).getTime() + (1 + Math.floor(Math.random() * 3)) * 86400000
    )
      .toISOString()
      .substring(0, 10);
    const bookingStatuses: Array<
      "pending" | "confirmed" | "cancelled" | "checked_in"
    > = ["pending", "confirmed", "cancelled"];
    const paymentStatuses: Array<"pending" | "paid" | "partial"> = [
      "pending",
      "paid",
      "partial",
    ];
    arr.push({
      id: 5000 + i,
      hotel_id: h.hotelId,
      guest_name: `Guest ${i}`,
      room_type: rand(roomTypes),
      check_in: ci,
      check_out: co,
      booking_status: rand(bookingStatuses),
      payment_status: rand(paymentStatuses),
    });
  }
  return arr;
}

function genInventory(hotels: HotelDTO[]): InventorySlot[] {
  const now = Date.now();
  const arr: InventorySlot[] = [];
  hotels
    .filter((h) => h.hotelId !== undefined)
    .slice(0, 5)
    .forEach((h) => {
      roomTypes.slice(0, 3).forEach((rt) => {
        for (let d = 0; d < 30; d++) {
          const date = new Date(now + d * 86400000)
            .toISOString()
            .substring(0, 10);
          const total = 5 + Math.floor(Math.random() * 10);
          const occ = Math.floor(Math.random() * total);
          arr.push({
            date,
            hotel_id: h.hotelId!,
            room_type: rt,
            available_count: total - occ,
            occupied: occ,
            blocked: Math.random() > 0.9,
          });
        }
      });
    });
  return arr;
}

function genRatePlans(hotels: HotelDTO[]): RatePlan[] {
  const arr: RatePlan[] = [];
  let id = 1;
  hotels.slice(0, 6).forEach((h) => {
    if (!h.hotelId) return;
    roomTypes.slice(0, 3).forEach((rt, idx) => {
      arr.push({
        id: id++,
        hotel_id: h.hotelId!,
        room_type: rt,
        name:
          idx === 0 ? "Flexible" : idx === 1 ? "Non-Refundable" : "Early Bird",
        base_price: h.price + idx * 150000,
        currency: "VND",
        refundable: idx !== 1,
        meal_plan: idx === 2 ? "Breakfast" : undefined,
      });
    });
  });
  return arr;
}

function genReviews(hotels: HotelDTO[]): Review[] {
  const arr: Review[] = [];
  let id = 1;
  hotels.slice(0, 6).forEach((h) => {
    if (!h.hotelId) return;
    const n = 1 + ((h.hotelId || 0) % 3);
    for (let i = 0; i < n; i++) {
      arr.push({
        id: id++,
        hotel_id: h.hotelId,
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

function genAlerts(hotels: HotelDTO[]): AlertItem[] {
  const firstHotelTitle = hotels[0]?.title || "Hotel";
  return [
    {
      id: 1,
      type: "overbook_risk",
      message: `Nguy cơ overbook tại ${firstHotelTitle}`,
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

function genActivities(hotels: HotelDTO[]): ActivityLog[] {
  const actions: Array<ActivityLog["action"]> = [
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
    const h = hotels[Math.floor(Math.random() * hotels.length)];
    if (!h || !h.hotelId) continue;
    arr.push({
      id: i + 1,
      action: rand(actions),
      hotel_id: h.hotelId,
      meta: { title: h.title },
      created_at: new Date(Date.now() - i * 3600000).toISOString(),
    });
  }
  return arr;
}

/* ===================== Helpers ===================== */
const fmtCurrency = (v: number): string =>
  new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    minimumFractionDigits: 0,
  }).format(v);

const cx = (...c: Array<string | false | null | undefined>): string =>
  c.filter(Boolean).join(" ");

/* ===================== Main Component ===================== */
const DashboardHotelPage: React.FC = () => {
  const navigate = useNavigate();
  const {
    hotels,
    filteredHotels,
    loading,
    error,
    filters,
    setFilters,
    refetch,
    clearFilters,
  } = useHotels();

  const handleDeleteHotel = async (hotel: HotelDTO) => {
    if (!hotel.hotelId) return;

    const confirmed = window.confirm(
      `Bạn có chắc chắn muốn xóa khách sạn "${hotel.title}"?\nHành động này không thể hoàn tác.`
    );

    if (!confirmed) return;

    try {
      await deleteHotel(hotel.hotelId);
      alert("Xóa khách sạn thành công!");
      refetch(); // Reload danh sách
    } catch (err) {
      console.error("Error deleting hotel:", err);
      alert("Lỗi xóa khách sạn. Vui lòng thử lại.");
    }
  };

  /* Mock data cho các phần tĩnh */
  const [reservations] = useState<Reservation[]>(() => genReservations(hotels));
  const [inventory] = useState<InventorySlot[]>(() => genInventory(hotels));
  const [ratePlans] = useState<RatePlan[]>(() => genRatePlans(hotels));
  const [reviews] = useState<Review[]>(() => genReviews(hotels));
  const [housekeeping] = useState<HousekeepingItem[]>(() => genHousekeeping());
  const [alerts] = useState<AlertItem[]>(() => genAlerts(hotels));
  const [activities] = useState<ActivityLog[]>(() => genActivities(hotels));

  /* Collapsible sections */
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});
  const toggleCollapse = (k: string): void =>
    setCollapsed((prev) => ({ ...prev, [k]: !prev[k] }));

  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set());
  const toggleSelectAll = (): void => {
    const ids = filteredHotels.map((h) => h.hotelId!).filter(Boolean);
    const all = ids.every((i) => selectedIds.has(i));
    setSelectedIds(all ? new Set() : new Set(ids));
  };
  const toggleSelectOne = (id: number): void =>
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });

  /* KPIs */
  const kpis = useMemo(() => {
    const total = filteredHotels.length;
    const published = filteredHotels.filter(
      (h) => h.hotelStatus === "published"
    ).length;
    const archived = filteredHotels.filter(
      (h) => h.hotelStatus === "archived"
    ).length;
    const avgRating =
      filteredHotels.length > 0
        ? filteredHotels.reduce((sum, h) => sum + (h.ratingAverage || 0), 0) /
          filteredHotels.length
        : 0;
    const avgPrice =
      filteredHotels.length > 0
        ? filteredHotels.reduce((sum, h) => sum + h.price, 0) /
          filteredHotels.length
        : 0;

    return { total, published, archived, avgRating, avgPrice };
  }, [filteredHotels]);

  /* Derived upcoming arrivals */
  const upcomingArrivals = useMemo(() => {
    const today = new Date().toISOString().substring(0, 10);
    const in3 = new Date(Date.now() + 3 * 86400000)
      .toISOString()
      .substring(0, 10);
    return reservations
      .filter((r) => r.check_in >= today && r.check_in <= in3)
      .slice(0, 12);
  }, [reservations]);

  /* Availability heatmap */
  const [availabilityHotelId, setAvailabilityHotelId] = useState<number>(() =>
    hotels.length && hotels[0].hotelId ? hotels[0].hotelId : 0
  );
  const availabilityHeat = useMemo(() => {
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

  const ratePlansPreview = useMemo(() => ratePlans.slice(0, 9), [ratePlans]);
  const reviewPreview = useMemo(() => reviews.slice(0, 5), [reviews]);
  const housekeepingProblems = useMemo(
    () => housekeeping.filter((h) => h.status !== "ready"),
    [housekeeping]
  );
  const alertsRecent = useMemo(() => alerts.slice(0, 6), [alerts]);
  const activityRecent = useMemo(() => activities.slice(0, 10), [activities]);

  /* Bulk actions (mock) */
  const bulkPublish = (): void => {
    console.log("Bulk publish hotels:", Array.from(selectedIds));
    alert(`Publishing ${selectedIds.size} hotels (mock)`);
  };
  const bulkArchive = (): void => {
    console.log("Bulk archive hotels:", Array.from(selectedIds));
    alert(`Archiving ${selectedIds.size} hotels (mock)`);
  };

  /* Status badge */
  const statusBadge = (status: HotelDTO["hotelStatus"]): JSX.Element => {
    const map: Record<HotelDTO["hotelStatus"], string> = {
      published:
        "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
      archived:
        "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
      disabled: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300",
    };
    const label: Record<HotelDTO["hotelStatus"], string> = {
      published: "Đang xuất bản",
      archived: "Lưu trữ",
      disabled: "Ngưng",
    };
    return (
      <span
        className={cx(
          "text-xs px-2 py-0.5 rounded font-medium inline-block",
          map[status]
        )}
      >
        {label[status]}
      </span>
    );
  };

  /* Visibility badge */
  const visibilityBadge = (
    visibility?: HotelDTO["visibility"]
  ): JSX.Element | null => {
    if (!visibility) return null;
    const map: Record<HotelDTO["visibility"], string> = {
      public_:
        "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300",
      private_:
        "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300",
    };
    const label: Record<HotelDTO["visibility"], string> = {
      public_: "Công khai",
      private_: "Riêng tư",
    };
    return (
      <span
        className={cx(
          "text-xs px-2 py-0.5 rounded font-medium inline-block",
          map[visibility]
        )}
      >
        {label[visibility]}
      </span>
    );
  };

  const sectionHeader = (
    title: string,
    key: string,
    icon?: React.ReactNode,
    extra?: React.ReactNode
  ): JSX.Element => {
    const col = collapsed[key];
    return (
      <div className="flex items-center gap-2 mb-3">
        <button
          onClick={() => toggleCollapse(key)}
          className="flex items-center gap-2 flex-1 text-left group"
        >
          {icon}
          <h2 className="text-xl font-bold theme-text-primary">{title}</h2>
          {col ? (
            <ChevronDown className="w-5 h-5 icon-secondary group-hover:icon-brand transition-colors" />
          ) : (
            <ChevronUp className="w-5 h-5 icon-secondary group-hover:icon-brand transition-colors" />
          )}
        </button>
        {extra}
      </div>
    );
  };

  const renderKPI = (
    label: string,
    value: React.ReactNode,
    icon: React.ReactNode,
    sub?: React.ReactNode
  ): JSX.Element => (
    <div className="theme-border rounded-lg p-4 theme-bg-card flex flex-col gap-2 shadow-sm">
      <div className="flex items-center gap-2">
        <div className="p-2 rounded-lg bg-light-secondary dark:bg-dark-secondary">
          {icon}
        </div>
        <span className="text-sm theme-text-secondary font-medium">
          {label}
        </span>
      </div>
      <div className="text-2xl font-bold">{value}</div>
      {sub && <div className="text-xs theme-text-secondary">{sub}</div>}
    </div>
  );

  /* ===================== JSX ===================== */
  return (
    <div className="p-6 max-w-[1900px] mx-auto flex flex-col gap-10 theme-text-primary">
      {/* Header & Filters */}
      <div className="flex flex-col gap-4">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-xl bg-gradient-to-br from-blue-500 to-purple-600 text-white shadow-lg">
              <Hotel className="w-7 h-7" />
            </div>
            <div>
              <h1 className="text-3xl font-bold">Quản lý Khách sạn</h1>
              <p className="text-sm theme-text-secondary mt-0.5">
                Tổng quan và quản lý toàn bộ khách sạn
              </p>
            </div>
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => refetch()}
              className="btn-outline px-4 py-2 flex items-center gap-2"
              disabled={loading}
            >
              <RefreshCw className={cx("w-4 h-4", loading && "animate-spin")} />
              <span className="hidden sm:inline">Làm mới</span>
            </button>
            <button
              onClick={() => navigate("/supplier/service/hotel/create")}
              className="btn-primary px-4 py-2 flex items-center gap-2"
            >
              <Plus className="w-4 h-4" />
              Tạo khách sạn mới
            </button>
          </div>
        </div>

        {/* Filters */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 icon-secondary" />
            <input
              value={filters.search || ""}
              onChange={(e) =>
                setFilters((prev) => ({ ...prev, search: e.target.value }))
              }
              placeholder="Tìm theo tên, ID..."
              className="w-full pl-10 pr-3 py-2 border theme-border rounded-lg bg-white dark:bg-dark-card theme-text-primary focus-ring-primary text-sm"
            />
          </div>

          <select
            value={filters.status || ""}
            onChange={(e) => {
              const value = e.target.value;
              setFilters((prev) => ({
                ...prev,
                status: value === "" ? "" : (value as HotelDTO["hotelStatus"]),
              }));
            }}
            className="px-3 py-2 border theme-border rounded-lg bg-white dark:bg-dark-card theme-text-primary focus-ring-primary text-sm"
          >
            <option value="">Tất cả trạng thái</option>
            <option value="published">Đang xuất bản</option>
            <option value="archived">Lưu trữ</option>
            <option value="disabled">Ngưng</option>
          </select>

          <select
            value={filters.visibility || ""}
            onChange={(e) => {
              const value = e.target.value;
              setFilters((prev) => ({
                ...prev,
                visibility:
                  value === "" ? "" : (value as HotelDTO["visibility"]),
              }));
            }}
            className="px-3 py-2 border theme-border rounded-lg bg-white dark:bg-dark-card theme-text-primary focus-ring-primary text-sm"
          >
            <option value="">Tất cả hiển thị</option>
            <option value="public_">Công khai</option>
            <option value="private_">Riêng tư</option>
          </select>

          <select
            value={filters.propertyType || ""}
            onChange={(e) =>
              setFilters((prev) => ({ ...prev, propertyType: e.target.value }))
            }
            className="px-3 py-2 border theme-border rounded-lg bg-white dark:bg-dark-card theme-text-primary focus-ring-primary text-sm"
          >
            <option value="">Tất cả loại hình</option>
            <option value="hotel">Khách sạn</option>
            <option value="resort">Resort</option>
            <option value="apartment">Căn hộ</option>
            <option value="villa">Biệt thự</option>
            <option value="hostel">Hostel</option>
            <option value="guesthouse">Nhà khách</option>
            <option value="homestay">Homestay</option>
          </select>
        </div>

        {/* Active Filters */}
        {(filters.search ||
          filters.status ||
          filters.visibility ||
          filters.propertyType) && (
          <div className="flex items-center gap-2 flex-wrap">
            <span className="text-sm theme-text-secondary">Bộ lọc:</span>
            {filters.search && (
              <span className="inline-flex items-center gap-1 px-2 py-1 bg-light-secondary dark:bg-dark-secondary rounded text-sm">
                Tìm: &quot;{filters.search}&quot;
                <button
                  onClick={() =>
                    setFilters((prev) => ({ ...prev, search: "" }))
                  }
                >
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}
            {filters.status && (
              <span className="inline-flex items-center gap-1 px-2 py-1 bg-light-secondary dark:bg-dark-secondary rounded text-sm">
                Trạng thái: {filters.status}
                <button
                  onClick={() =>
                    setFilters((prev) => ({ ...prev, status: "" }))
                  }
                >
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}
            {filters.visibility && (
              <span className="inline-flex items-center gap-1 px-2 py-1 bg-light-secondary dark:bg-dark-secondary rounded text-sm">
                Hiển thị: {filters.visibility}
                <button
                  onClick={() =>
                    setFilters((prev) => ({ ...prev, visibility: "" }))
                  }
                >
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}
            {filters.propertyType && (
              <span className="inline-flex items-center gap-1 px-2 py-1 bg-light-secondary dark:bg-dark-secondary rounded text-sm">
                Loại: {filters.propertyType}
                <button
                  onClick={() =>
                    setFilters((prev) => ({ ...prev, propertyType: "" }))
                  }
                >
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}
            <button
              onClick={clearFilters}
              className="text-sm text-red-600 hover:underline"
            >
              Xóa tất cả
            </button>
          </div>
        )}
      </div>

      {/* Error State */}
      {error && (
        <div className="flex items-center gap-2 p-4 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-700 rounded-lg">
          <AlertCircle className="w-5 h-5 text-red-600 dark:text-red-400" />
          <span className="text-sm text-red-700 dark:text-red-300">
            {error}
          </span>
        </div>
      )}

      {/* Loading State */}
      {loading && (
        <div className="flex items-center justify-center gap-3 py-12">
          <Loader2 className="w-6 h-6 animate-spin icon-brand" />
          <span className="theme-text-secondary">Đang tải dữ liệu...</span>
        </div>
      )}

      {/* Content */}
      {!loading && (
        <>
          {/* KPIs */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
            {renderKPI(
              "Tổng khách sạn",
              kpis.total,
              <Hotel className="w-5 h-5 icon-brand" />,
              `${filteredHotels.length} đang hiển thị`
            )}
            {renderKPI(
              "Đang hoạt động",
              kpis.published,
              <TrendingUp className="w-5 h-5 text-green-600" />,
              `${((kpis.published / (kpis.total || 1)) * 100).toFixed(
                0
              )}% tổng số`
            )}
            {renderKPI(
              "Lưu trữ",
              kpis.archived,
              <Archive className="w-5 h-5 text-amber-600" />
            )}
            {renderKPI(
              "Đánh giá TB",
              kpis.avgRating.toFixed(1),
              <Star className="w-5 h-5 text-yellow-500" />,
              "⭐".repeat(Math.round(kpis.avgRating))
            )}
            {renderKPI(
              "Giá TB",
              fmtCurrency(kpis.avgPrice),
              <DollarSign className="w-5 h-5 text-blue-600" />
            )}
          </div>

          {/* Hotels List */}
          <div className="flex flex-col gap-4">
            {sectionHeader(
              `Danh sách khách sạn (${filteredHotels.length})`,
              "hotels-list",
              <Hotel className="w-6 h-6 icon-brand" />,
              <div className="flex gap-2">
                {selectedIds.size > 0 && (
                  <>
                    <button
                      onClick={bulkPublish}
                      className="btn-secondary px-3 py-1 text-sm flex items-center gap-1"
                    >
                      <Upload className="w-3 h-3" />
                      Xuất bản ({selectedIds.size})
                    </button>
                    <button
                      onClick={bulkArchive}
                      className="btn-outline px-3 py-1 text-sm flex items-center gap-1"
                    >
                      <Archive className="w-3 h-3" />
                      Lưu trữ ({selectedIds.size})
                    </button>
                  </>
                )}
              </div>
            )}

            {!collapsed["hotels-list"] && (
              <div className="border theme-border rounded-xl overflow-hidden theme-bg-card shadow-sm">
                {/* Table */}
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead className="bg-light-secondary dark:bg-dark-secondary">
                      <tr>
                        <th className="p-3 text-left">
                          <button onClick={toggleSelectAll}>
                            {filteredHotels.length > 0 &&
                            filteredHotels.every((h) =>
                              h.hotelId ? selectedIds.has(h.hotelId) : false
                            ) ? (
                              <CheckSquare className="w-4 h-4 icon-brand" />
                            ) : (
                              <Square className="w-4 h-4 icon-secondary" />
                            )}
                          </button>
                        </th>
                        <th className="p-3 text-left font-semibold">ID</th>
                        <th className="p-3 text-left font-semibold">
                          Khách sạn
                        </th>
                        <th className="p-3 text-left font-semibold">
                          Loại hình
                        </th>
                        <th className="p-3 text-left font-semibold">Vị trí</th>
                        <th className="p-3 text-left font-semibold">Giá</th>
                        <th className="p-3 text-left font-semibold">
                          Đánh giá
                        </th>
                        <th className="p-3 text-left font-semibold">
                          Trạng thái
                        </th>
                        <th className="p-3 text-left font-semibold">
                          Hiển thị
                        </th>
                        <th className="p-3 text-left font-semibold">
                          Hành động
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredHotels.length === 0 && (
                        <tr>
                          <td
                            colSpan={10}
                            className="p-8 text-center theme-text-secondary"
                          >
                            Không có khách sạn nào
                          </td>
                        </tr>
                      )}
                      {filteredHotels.map((hotel) => {
                        if (!hotel.hotelId) return null;
                        return (
                          <tr
                            key={hotel.hotelId}
                            className="border-t theme-border hover:bg-light-secondary dark:hover:bg-dark-secondary/50 transition-colors"
                          >
                            {/* Checkbox */}
                            <td className="p-3">
                              <button
                                onClick={() => toggleSelectOne(hotel.hotelId!)}
                              >
                                {selectedIds.has(hotel.hotelId) ? (
                                  <CheckSquare className="w-4 h-4 icon-brand" />
                                ) : (
                                  <Square className="w-4 h-4 icon-secondary" />
                                )}
                              </button>
                            </td>

                            {/* ID */}
                            <td className="p-3">
                              <span className="font-mono text-xs theme-text-secondary">
                                #{hotel.hotelId}
                              </span>
                            </td>

                            {/* Hotel Info */}
                            <td className="p-3">
                              <div className="flex items-center gap-3">
                                {hotel.thumbnailUrl ? (
                                  <img
                                    src={hotel.thumbnailUrl}
                                    alt={hotel.title}
                                    className="w-12 h-12 rounded object-cover"
                                  />
                                ) : (
                                  <div className="w-12 h-12 rounded bg-light-secondary dark:bg-dark-secondary flex items-center justify-center">
                                    <ImageIcon className="w-5 h-5 icon-secondary" />
                                  </div>
                                )}
                                <div className="flex flex-col">
                                  <span className="font-medium">
                                    {hotel.title}
                                  </span>
                                  {hotel.slug && (
                                    <span className="text-xs theme-text-secondary">
                                      {hotel.slug}
                                    </span>
                                  )}
                                  {hotel.isFeatured && (
                                    <span className="text-xs text-yellow-600 dark:text-yellow-400 flex items-center gap-1 mt-0.5">
                                      <Star className="w-3 h-3 fill-current" />
                                      Nổi bật
                                    </span>
                                  )}
                                </div>
                              </div>
                            </td>

                            {/* Property Type */}
                            <td className="p-3">
                              <span className="capitalize">
                                {hotel.propertyType || "hotel"}
                              </span>
                            </td>

                            {/* Location */}
                            <td className="p-3">
                              <div className="flex items-start gap-1">
                                <MapPin className="w-3 h-3 icon-secondary mt-0.5 flex-shrink-0" />
                                <span className="text-xs">
                                  {hotel.location || hotel.address || "—"}
                                </span>
                              </div>
                            </td>

                            {/* Price */}
                            <td className="p-3">
                              <span className="font-semibold">
                                {fmtCurrency(hotel.price)}
                              </span>
                            </td>

                            {/* Rating */}
                            <td className="p-3">
                              {hotel.ratingAverage ? (
                                <div className="flex items-center gap-1">
                                  <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                                  <span className="font-medium">
                                    {hotel.ratingAverage.toFixed(1)}
                                  </span>
                                </div>
                              ) : (
                                <span className="text-xs theme-text-secondary">
                                  Chưa có
                                </span>
                              )}
                              {hotel.starRating && (
                                <div className="text-xs theme-text-secondary mt-0.5">
                                  {hotel.starRating} sao
                                </div>
                              )}
                            </td>

                            {/* Status */}
                            <td className="p-3">
                              {statusBadge(hotel.hotelStatus)}
                            </td>

                            {/* Visibility */}
                            <td className="p-3">
                              {visibilityBadge(hotel.visibility)}
                            </td>

                            {/* Actions */}
                            <td className="p-3">
                              <div className="flex items-center gap-1">
                                <button
                                  onClick={() =>
                                    navigate(
                                      `/supplier/service/hotel/${hotel.hotelId}/view`
                                    )
                                  }
                                  className="p-1.5 rounded hover:bg-light-secondary dark:hover:bg-dark-secondary transition-colors"
                                  title="Xem chi tiết"
                                >
                                  <Eye className="w-4 h-4 icon-secondary" />
                                </button>
                                <button
                                  onClick={() =>
                                    navigate(
                                      `/supplier/service/hotel/${hotel.hotelId}/edit`
                                    )
                                  }
                                  className="p-1.5 rounded hover:bg-light-secondary dark:hover:bg-dark-secondary transition-colors"
                                  title="Chỉnh sửa"
                                >
                                  <Edit className="w-4 h-4 icon-secondary" />
                                </button>
                                <button
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    handleDeleteHotel(hotel);
                                  }}
                                  className="p-2 rounded hover:bg-red-50 dark:hover:bg-red-900/20 text-red-600 dark:text-red-400 transition-colors"
                                  title="Xóa"
                                >
                                  <Trash2 className="w-4 h-4" />
                                </button>
                              </div>
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </div>

          {/* Các phần tĩnh khác - giữ nguyên UI mock */}
          {/* Upcoming Arrivals (Mock) */}
          <div className="flex flex-col gap-4">
            {sectionHeader(
              `Check-in sắp tới (${upcomingArrivals.length})`,
              "arrivals",
              <Calendar className="w-6 h-6 icon-brand" />
            )}
            {!collapsed["arrivals"] && (
              <div className="border theme-border rounded-xl overflow-hidden theme-bg-card shadow-sm">
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead className="bg-light-secondary dark:bg-dark-secondary">
                      <tr>
                        <th className="p-3 text-left font-semibold">Khách</th>
                        <th className="p-3 text-left font-semibold">
                          Loại phòng
                        </th>
                        <th className="p-3 text-left font-semibold">
                          Check-in
                        </th>
                        <th className="p-3 text-left font-semibold">
                          Check-out
                        </th>
                        <th className="p-3 text-left font-semibold">
                          Trạng thái
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {upcomingArrivals.map((res) => (
                        <tr
                          key={res.id}
                          className="border-t theme-border hover:bg-light-secondary dark:hover:bg-dark-secondary/50"
                        >
                          <td className="p-3">{res.guest_name}</td>
                          <td className="p-3">{res.room_type}</td>
                          <td className="p-3">{res.check_in}</td>
                          <td className="p-3">{res.check_out}</td>
                          <td className="p-3">
                            <span className="text-xs px-2 py-0.5 rounded bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300">
                              {res.booking_status}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </div>

          {/* Availability Heatmap (Mock) */}
          <div className="flex flex-col gap-4">
            {sectionHeader(
              "Lịch phòng trống (30 ngày tới)",
              "availability",
              <Calendar className="w-6 h-6 icon-brand" />,
              <select
                value={availabilityHotelId}
                onChange={(e) => setAvailabilityHotelId(Number(e.target.value))}
                className="px-2 py-1 text-sm border theme-border rounded"
              >
                {hotels.slice(0, 5).map((h) => (
                  <option key={h.hotelId} value={h.hotelId}>
                    {h.title}
                  </option>
                ))}
              </select>
            )}
            {!collapsed["availability"] && (
              <div className="border theme-border rounded-xl p-4 theme-bg-card shadow-sm overflow-x-auto">
                <div className="min-w-[800px]">
                  <div className="grid grid-cols-[120px_1fr] gap-2">
                    <div className="font-semibold text-sm">Loại phòng</div>
                    <div className="grid grid-cols-7 gap-1">
                      {availabilityHeat.days.slice(0, 7).map((d) => (
                        <div key={d} className="text-xs text-center">
                          {new Date(d).getDate()}
                        </div>
                      ))}
                    </div>
                    {availabilityHeat.roomList.map((rt, ri) => (
                      <React.Fragment key={rt}>
                        <div className="text-sm font-medium">{rt}</div>
                        <div className="grid grid-cols-7 gap-1">
                          {availabilityHeat.matrix[ri]
                            ?.slice(0, 7)
                            .map((slot, di) => {
                              const pct = slot
                                ? (slot.available_count /
                                    (slot.available_count + slot.occupied)) *
                                  100
                                : 0;
                              const color =
                                pct > 70
                                  ? "bg-green-200 dark:bg-green-800"
                                  : pct > 30
                                  ? "bg-yellow-200 dark:bg-yellow-800"
                                  : "bg-red-200 dark:bg-red-800";
                              return (
                                <div
                                  key={di}
                                  className={cx(
                                    "h-8 rounded text-xs flex items-center justify-center",
                                    color
                                  )}
                                  title={`${slot?.available_count || 0} trống`}
                                >
                                  {slot?.available_count || 0}
                                </div>
                              );
                            })}
                        </div>
                      </React.Fragment>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Rate Plans (Mock) */}
          <div className="flex flex-col gap-4">
            {sectionHeader(
              `Rate Plans (${ratePlansPreview.length})`,
              "rate-plans",
              <DollarSign className="w-6 h-6 icon-brand" />
            )}
            {!collapsed["rate-plans"] && (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {ratePlansPreview.map((rp) => (
                  <div
                    key={rp.id}
                    className="border theme-border rounded-lg p-4 theme-bg-card shadow-sm flex flex-col gap-2"
                  >
                    <div className="font-semibold">{rp.name}</div>
                    <div className="text-sm theme-text-secondary">
                      {rp.room_type}
                    </div>
                    <div className="text-lg font-bold">
                      {fmtCurrency(rp.base_price)}
                    </div>
                    <div className="flex gap-2 flex-wrap text-xs">
                      {rp.refundable && (
                        <span className="px-2 py-0.5 bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300 rounded">
                          Hoàn tiền
                        </span>
                      )}
                      {rp.meal_plan && (
                        <span className="px-2 py-0.5 bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300 rounded">
                          {rp.meal_plan}
                        </span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Reviews (Mock) */}
          <div className="flex flex-col gap-4">
            {sectionHeader(
              `Đánh giá gần đây (${reviewPreview.length})`,
              "reviews",
              <MessageSquare className="w-6 h-6 icon-brand" />
            )}
            {!collapsed["reviews"] && (
              <div className="border theme-border rounded-xl overflow-hidden theme-bg-card shadow-sm">
                <div className="divide-y theme-border">
                  {reviewPreview.map((rev) => (
                    <div key={rev.id} className="p-4 flex flex-col gap-2">
                      <div className="flex items-center justify-between">
                        <span className="font-semibold">{rev.guest}</span>
                        <div className="flex items-center gap-1">
                          <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                          <span className="font-medium">{rev.rating}</span>
                        </div>
                      </div>
                      <p className="text-sm theme-text-secondary">
                        {rev.content}
                      </p>
                      <div className="flex gap-3 text-xs theme-text-secondary">
                        <span>Sạch sẽ: {rev.aspects.cleanliness}</span>
                        <span>Dịch vụ: {rev.aspects.service}</span>
                        <span>Tiện nghi: {rev.aspects.facilities}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Housekeeping (Mock) */}
          <div className="flex flex-col gap-4">
            {sectionHeader(
              `Vấn đề buồng phòng (${housekeepingProblems.length})`,
              "housekeeping",
              <Settings className="w-6 h-6 icon-brand" />
            )}
            {!collapsed["housekeeping"] && (
              <div className="border theme-border rounded-xl overflow-hidden theme-bg-card shadow-sm">
                <table className="w-full text-sm">
                  <thead className="bg-light-secondary dark:bg-dark-secondary">
                    <tr>
                      <th className="p-3 text-left font-semibold">Phòng</th>
                      <th className="p-3 text-left font-semibold">
                        Trạng thái
                      </th>
                      <th className="p-3 text-left font-semibold">Lý do</th>
                    </tr>
                  </thead>
                  <tbody>
                    {housekeepingProblems.map((hk) => (
                      <tr
                        key={hk.id}
                        className="border-t theme-border hover:bg-light-secondary dark:hover:bg-dark-secondary/50"
                      >
                        <td className="p-3 font-mono">{hk.room_label}</td>
                        <td className="p-3">
                          <span
                            className={cx(
                              "text-xs px-2 py-0.5 rounded",
                              hk.status === "maintenance"
                                ? "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300"
                                : "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300"
                            )}
                          >
                            {hk.status}
                          </span>
                        </td>
                        <td className="p-3 theme-text-secondary">
                          {hk.reason || "—"}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>

          {/* Alerts (Mock) */}
          <div className="flex flex-col gap-4">
            {sectionHeader(
              `Cảnh báo (${alertsRecent.length})`,
              "alerts",
              <Bell className="w-6 h-6 icon-brand" />
            )}
            {!collapsed["alerts"] && (
              <div className="border theme-border rounded-xl overflow-hidden theme-bg-card shadow-sm divide-y theme-border">
                {alertsRecent.map((alert) => {
                  const severityClass =
                    alert.severity === "critical"
                      ? "bg-red-50 border-red-200 dark:bg-red-900/20 dark:border-red-800"
                      : alert.severity === "warn"
                      ? "bg-yellow-50 border-yellow-200 dark:bg-yellow-900/20 dark:border-yellow-800"
                      : "bg-blue-50 border-blue-200 dark:bg-blue-900/20 dark:border-blue-800";
                  return (
                    <div
                      key={alert.id}
                      className={cx(
                        "p-4 flex items-start gap-3",
                        severityClass
                      )}
                    >
                      <AlertCircle className="w-5 h-5 mt-0.5 flex-shrink-0" />
                      <div className="flex-1">
                        <div className="font-medium">{alert.message}</div>
                        <div className="text-xs theme-text-secondary mt-1">
                          {new Date(alert.created_at).toLocaleString("vi-VN")}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          {/* Activity Log (Mock) */}
          <div className="flex flex-col gap-4">
            {sectionHeader(
              `Nhật ký hoạt động (${activityRecent.length})`,
              "activity",
              <Activity className="w-6 h-6 icon-brand" />
            )}
            {!collapsed["activity"] && (
              <div className="border theme-border rounded-xl overflow-hidden theme-bg-card shadow-sm">
                <div className="divide-y theme-border">
                  {activityRecent.map((act) => (
                    <div
                      key={act.id}
                      className="p-3 flex items-center gap-3 hover:bg-light-secondary dark:hover:bg-dark-secondary/50"
                    >
                      <Clock className="w-4 h-4 icon-secondary flex-shrink-0" />
                      <div className="flex-1 text-sm">
                        <span className="font-medium">{act.action}</span>
                        {act.meta?.title && (
                          <span className="theme-text-secondary">
                            {" "}
                            - {act.meta.title}
                          </span>
                        )}
                      </div>
                      <div className="text-xs theme-text-secondary">
                        {new Date(act.created_at).toLocaleString("vi-VN")}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
};

export default DashboardHotelPage;
