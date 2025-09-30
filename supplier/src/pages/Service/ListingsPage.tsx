import React, { useEffect, useMemo, useState, useReducer } from "react";
import {
  Search,
  Filter,
  List as ListIcon,
  Grid3x3,
  Star,
  StarOff,
  Eye,
  Pencil,
  Copy,
  Power,
  Archive,
  Trash2,
  Tag,
  Calendar,
  Download,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  Globe,
  Lock,
  Layers,
  RefreshCw,
  BookOpen,
  AlertTriangle,
  X,
} from "lucide-react";
import { useParams, useNavigate } from "react-router-dom";

/* ============ i18n stub ============ */
const useLanguage = () => ({
  t: (k: string) => k,
});

/* ============ Types ============ */
export type ListingType = "tour" | "hotel" | "restaurant" | "attraction";
export type ListingStatus = "published" | "draft" | "archived";
export interface Listing {
  id: number;
  type: ListingType;
  title: string;
  slug: string;
  thumbnail_url: string | null;
  visibility: "public" | "private";
  is_featured: boolean;
  price: number | null;
  price_from?: number | null;
  currency: string;
  rating_average: number;
  bookings_count_period: number;
  listing_status: ListingStatus;
  published_at: string | null;
  area: string | null;
  channel?: string | null;
  auto_accept?: boolean;
  has_schedule?: boolean;
  created_at: string;
  updated_at: string;
}

interface FilterState {
  q: string;
  type: ListingType | "";
  status: ListingStatus | "";
  area: string;
  rating: string;
  featuredOnly: boolean;
  channel: string;
}

interface BulkActionResult {
  success: number;
  failed: number;
  items: {
    id: number;
    ok: boolean;
    errors?: string[];
    action: string;
  }[];
}

type SortField =
  | "title"
  | "type"
  | "visibility"
  | "is_featured"
  | "price"
  | "rating_average"
  | "bookings_count_period"
  | "listing_status"
  | "published_at"
  | "updated_at";

type SortDirection = "asc" | "desc";

/* ============ Static Seed Data ============ */
const seedListings = (): Listing[] => {
  const areas = ["Hà Nội", "TP.HCM", "Đà Nẵng", "Quảng Ninh", "Thanh Hóa"];
  const types: ListingType[] = ["tour", "hotel", "restaurant", "attraction"];
  const now = Date.now();
  const data: Listing[] = [];
  for (let i = 1; i <= 57; i++) {
    const type = types[i % types.length];
    const basePrice = type === "hotel" ? null : (i * 100000) % 4000000;
    data.push({
      id: i,
      type,
      title: `Demo ${type} #${i}`,
      slug: `demo-${type}-${i}`,
      thumbnail_url:
        i % 5 === 0
          ? null
          : `https://picsum.photos/seed/listing-${i}/200/140.webp`,
      visibility: i % 2 === 0 ? "public" : "private",
      is_featured: i % 7 === 0,
      price: basePrice,
      price_from: basePrice
        ? Math.max(50000, Math.round(basePrice * 0.8))
        : null,
      currency: "VND",
      rating_average: Number((Math.random() * 2 + 3).toFixed(1)),
      bookings_count_period: Math.floor(Math.random() * 120),
      listing_status:
        i % 11 === 0 ? "archived" : i % 3 === 0 ? "draft" : "published",
      published_at:
        i % 3 === 0
          ? null
          : new Date(now - i * 86400000).toISOString().split("T")[0],
      area: areas[i % areas.length],
      channel: i % 4 === 0 ? "B2B" : "",
      auto_accept: i % 2 === 0,
      has_schedule: i % 5 !== 0,
      created_at: new Date(now - i * 86400000 * 2).toISOString().split("T")[0],
      updated_at: new Date(now - i * 86400000).toISOString().split("T")[0],
    });
  }
  return data;
};

/* ============ Reducer (for paginated slice meta) ============ */
interface ListingViewState {
  page: number;
  perPage: number;
  loading: boolean;
  error: string | null;
}

type ListingViewAction =
  | { type: "SET_PAGE"; page: number }
  | { type: "SET_PER_PAGE"; perPage: number }
  | { type: "ERROR"; error: string | null }
  | { type: "LOADING"; loading: boolean };

const listingViewReducer = (
  s: ListingViewState,
  a: ListingViewAction
): ListingViewState => {
  switch (a.type) {
    case "SET_PAGE":
      return { ...s, page: a.page };
    case "SET_PER_PAGE":
      return { ...s, perPage: a.perPage, page: 1 };
    case "ERROR":
      return { ...s, error: a.error, loading: false };
    case "LOADING":
      return { ...s, loading: a.loading };
    default:
      return s;
  }
};

const initialViewState: ListingViewState = {
  page: 1,
  perPage: 10,
  loading: false,
  error: null,
};

/* ============ Helpers ============ */
const formatCurrency = (amount: number | null, currency = "VND") =>
  amount == null
    ? "—"
    : new Intl.NumberFormat("vi-VN", {
        style: "currency",
        currency: currency,
        minimumFractionDigits: 0,
      }).format(amount);

const cx = (...c: Array<string | false | null | undefined>) =>
  c.filter(Boolean).join(" ");

const statusConfig: Record<ListingStatus, { label: string; badge: string }> = {
  published: { label: "Published", badge: "bg-green-100 text-green-700" },
  draft: { label: "Draft", badge: "bg-amber-100 text-amber-700" },
  archived: { label: "Archived", badge: "bg-gray-200 text-gray-700" },
};

const availableAreas = [
  "all",
  "Hà Nội",
  "TP.HCM",
  "Đà Nẵng",
  "Quảng Ninh",
  "Thanh Hóa",
];

const dateFields: ReadonlyArray<SortField> = ["published_at", "updated_at"];

/* ============ Main Component ============ */
const ListingsPage: React.FC = () => {
  const { providerId = "1" } = useParams<{ providerId: string }>();
  const { t } = useLanguage();
  const navigate = useNavigate();

  // Master dataset
  const [allListings, setAllListings] = useState<Listing[]>(() =>
    seedListings()
  );

  // Filters
  const [filters, setFilters] = useState<FilterState>({
    q: "",
    type: "",
    status: "",
    area: "all",
    rating: "",
    featuredOnly: false,
    channel: "",
  });

  // Sorting
  const [sortField, setSortField] = useState<SortField>("updated_at");
  const [sortDir, setSortDir] = useState<SortDirection>("desc");

  // View mode
  const [viewMode, setViewMode] = useState<"table" | "grid">("table");

  // Selection
  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set());

  // Modals & results
  const [showBulkMenu, setShowBulkMenu] = useState(false);
  const [showValidationModal, setShowValidationModal] = useState(false);
  const [lastBulkResult, setLastBulkResult] = useState<BulkActionResult | null>(
    null
  );
  const [deleteTarget, setDeleteTarget] = useState<Listing | null>(null);
  const [promoListing, setPromoListing] = useState<Listing | null>(null);

  // Pagination meta
  const [viewState, dispatchView] = useReducer(
    listingViewReducer,
    initialViewState
  );
  const { page, perPage } = viewState;

  /* ---------- Filtering ---------- */
  const filtered = useMemo(() => {
    return allListings.filter((l) => {
      if (filters.q) {
        const q = filters.q.toLowerCase();
        if (
          !l.title.toLowerCase().includes(q) &&
          !l.slug.toLowerCase().includes(q)
        )
          return false;
      }
      if (filters.type && l.type !== filters.type) return false;
      if (filters.status && l.listing_status !== filters.status) return false;
      if (filters.area !== "all" && l.area !== filters.area) return false;
      if (filters.rating) {
        if (l.rating_average < parseFloat(filters.rating)) return false;
      }
      if (filters.featuredOnly && !l.is_featured) return false;
      if (filters.channel) {
        if ((l.channel || "").toLowerCase() !== filters.channel.toLowerCase())
          return false;
      }
      return true;
    });
  }, [allListings, filters]);

  /* ---------- Sorting ---------- */
  const sorted = useMemo(() => {
    const list = [...filtered];
    list.sort((a, b) => {
      const av = a[sortField];
      const bv = b[sortField];
      const mult = sortDir === "asc" ? 1 : -1;

      // Dates
      if (dateFields.includes(sortField)) {
        const ad = av ? new Date(String(av)).getTime() : 0;
        const bd = bv ? new Date(String(bv)).getTime() : 0;
        return (ad - bd) * mult;
      }

      if (typeof av === "number" && typeof bv === "number") {
        if (av === bv) return 0;
        return av < bv ? -1 * mult : 1 * mult;
      }

      if (typeof av === "boolean" && typeof bv === "boolean") {
        return (Number(av) - Number(bv)) * mult;
      }

      return String(av).localeCompare(String(bv)) * mult;
    });
    return list;
  }, [filtered, sortField, sortDir]);

  /* ---------- Pagination Slice ---------- */
  const total = sorted.length;
  const totalPages = Math.ceil(total / perPage);
  const paginated = useMemo(
    () => sorted.slice((page - 1) * perPage, page * perPage),
    [sorted, page, perPage]
  );

  // Clear selection when dataset slice changes
  useEffect(() => {
    setSelectedIds(new Set());
  }, [paginated, filters, sortField, sortDir, perPage, page]);

  /* ---------- Handlers ---------- */
  const toggleSort = (field: SortField) => {
    if (sortField === field) {
      setSortDir((d) => (d === "asc" ? "desc" : "asc"));
    } else {
      setSortField(field);
      setSortDir("asc");
    }
  };

  const toggleSelectAllCurrent = (checked: boolean) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (checked) paginated.forEach((l) => next.add(l.id));
      else paginated.forEach((l) => next.delete(l.id));
      return next;
    });
  };

  const toggleSelectOne = (id: number) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  };

  const handleChangePage = (p: number) => {
    if (p < 1 || p > totalPages) return;
    dispatchView({ type: "SET_PAGE", page: p });
  };

  const handleChangePerPage = (pp: number) =>
    dispatchView({ type: "SET_PER_PAGE", perPage: pp });

  const clearFilters = () => {
    setFilters({
      q: "",
      type: "",
      status: "",
      area: "all",
      rating: "",
      featuredOnly: false,
      channel: "",
    });
    dispatchView({ type: "SET_PAGE", page: 1 });
  };

  const validateListingPublish = (l: Listing): string[] => {
    const errors: string[] = [];
    if (!l.thumbnail_url) errors.push("MISSING_THUMBNAIL");
    if (!l.price && !l.price_from) errors.push("MISSING_PRICE");
    if (l.auto_accept && !l.has_schedule) errors.push("MISSING_SCHEDULE");
    return errors;
  };

  const applyBulk = (ids: number[], action: string) => {
    const items: BulkActionResult["items"] = [];
    setAllListings((prev) => {
      const map = new Map(prev.map((l) => [l.id, l]));
      ids.forEach((id) => {
        const listing = map.get(id);
        if (!listing) {
          items.push({ id, ok: false, action, errors: ["NOT_FOUND"] });
          return;
        }
        if (action === "publish") {
          const errs = validateListingPublish(listing);
          if (errs.length) {
            items.push({ id, ok: false, action, errors: errs });
            return;
          }
          map.set(id, {
            ...listing,
            listing_status: "published",
            published_at: new Date().toISOString().split("T")[0],
          });
          items.push({ id, ok: true, action });
        } else if (action === "unpublish") {
          map.set(id, { ...listing, listing_status: "draft" });
          items.push({ id, ok: true, action });
        } else if (action === "archive" || action === "delete") {
          map.set(id, { ...listing, listing_status: "archived" });
          items.push({ id, ok: true, action });
        } else {
          // dummy for promotion
          items.push({ id, ok: true, action });
        }
      });
      setLastBulkResult({
        success: items.filter((i) => i.ok).length,
        failed: items.filter((i) => !i.ok).length,
        items,
      });
      if (action === "publish" && items.some((i) => !i.ok))
        setShowValidationModal(true);
      return Array.from(map.values());
    });
  };

  const performBulkAction = (action: string) => {
    if (!selectedIds.size) return;
    applyBulk(Array.from(selectedIds), action);
    setSelectedIds(new Set());
    setShowBulkMenu(false);
  };

  const performSingle = (id: number, action: string) => {
    applyBulk([id], action);
  };

  const handleTogglePublish = (l: Listing) => {
    if (l.listing_status !== "published") {
      const errs = validateListingPublish(l);
      if (errs.length) {
        setLastBulkResult({
          success: 0,
          failed: 1,
          items: [{ id: l.id, ok: false, action: "publish", errors: errs }],
        });
        setShowValidationModal(true);
        return;
      }
    }
    setAllListings((prev) =>
      prev.map((x) =>
        x.id === l.id
          ? {
              ...x,
              listing_status:
                x.listing_status === "published" ? "draft" : "published",
              published_at:
                x.listing_status === "published"
                  ? x.published_at
                  : new Date().toISOString().split("T")[0],
            }
          : x
      )
    );
  };

  const handleDuplicate = (l: Listing) => {
    setAllListings((prev) => {
      const slugBase = `${l.slug}-copy`;
      let candidate = slugBase;
      let counter = 1;
      while (prev.some((x) => x.slug === candidate)) {
        candidate = `${slugBase}-${counter++}`;
      }
      const maxId = Math.max(...prev.map((x) => x.id)) + 1;
      const clone: Listing = {
        ...l,
        id: maxId,
        title: l.title + " (Copy)",
        slug: candidate,
        listing_status: "draft",
        published_at: null,
        created_at: new Date().toISOString().split("T")[0],
        updated_at: new Date().toISOString().split("T")[0],
      };
      return [clone, ...prev];
    });
  };

  const handleDeleteConfirm = () => {
    if (deleteTarget) {
      performSingle(deleteTarget.id, "archive");
      setDeleteTarget(null);
    }
  };

  const handleExportSelectedCSV = () => {
    if (!selectedIds.size) return;
    const header = [
      "id",
      "type",
      "title",
      "slug",
      "status",
      "price",
      "rating",
      "bookings",
      "published_at",
      "area",
    ];
    const rows = [header.join(",")];
    const lookup = new Map(allListings.map((l) => [l.id, l]));
    selectedIds.forEach((id) => {
      const l = lookup.get(id);
      if (!l) return;
      rows.push(
        [
          l.id,
          l.type,
          `"${l.title.replace(/"/g, '""')}"`,
          l.slug,
          l.listing_status,
          l.price || l.price_from || "",
          l.rating_average,
          l.bookings_count_period,
          l.published_at || "",
          l.area || "",
        ].join(",")
      );
    });
    const blob = new Blob([rows.join("\n")], { type: "text/csv" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = `listings-selected-${
      new Date().toISOString().split("T")[0]
    }.csv`;
    a.click();
    a.remove();
  };

  const handleBulkBlockDates = () => {
    if (!selectedIds.size) return;
    const ids = Array.from(selectedIds).join(",");
    navigate(`/provider/${providerId}/calendar?listings=${ids}`);
  };

  /* ---------- Derived UI bits ---------- */
  const isAllCurrentPageSelected =
    paginated.length > 0 &&
    paginated.every((l) => selectedIds.has(l.id)) &&
    selectedIds.size > 0;

  const activeFilterTags = useMemo(() => {
    const tags: { key: keyof FilterState | "featuredOnly"; label: string }[] =
      [];
    if (filters.q) tags.push({ key: "q", label: `Search: "${filters.q}"` });
    if (filters.type)
      tags.push({ key: "type", label: `Type: ${filters.type}` });
    if (filters.status)
      tags.push({ key: "status", label: `Status: ${filters.status}` });
    if (filters.area !== "all")
      tags.push({ key: "area", label: `Area: ${filters.area}` });
    if (filters.rating)
      tags.push({ key: "rating", label: `Rating ≥ ${filters.rating}` });
    if (filters.featuredOnly)
      tags.push({ key: "featuredOnly", label: "Featured" });
    if (filters.channel)
      tags.push({ key: "channel", label: `Channel: ${filters.channel}` });
    return tags;
  }, [filters]);

  const removeFilterTag = (key: string) => {
    setFilters((prev) => {
      const next = { ...prev };
      if (key === "featuredOnly") next.featuredOnly = false;
      else if (key === "area") next.area = "all";
      return next;
    });
  };

  /* ---------- Render Helpers ---------- */
  const renderStatusBadge = (status: ListingStatus) => {
    const cfg = statusConfig[status];
    return (
      <span
        className={cx(
          "inline-flex items-center rounded px-2 py-0.5 text-xs font-medium",
          cfg.badge
        )}
      >
        {cfg.label}
      </span>
    );
  };

  /* ---------- Columns (table) ---------- */
  interface Column {
    key: "select" | "thumbnail" | SortField | "actions";
    label: string;
    sortable?: boolean;
    render?: (l: Listing) => React.ReactNode;
  }

  const columns: Column[] = [
    { key: "select", label: "" },
    {
      key: "thumbnail",
      label: "Thumbnail",
      render: (l) => (
        <div className="w-16 h-12 bg-gray-100 rounded overflow-hidden flex items-center justify-center">
          {l.thumbnail_url ? (
            <img
              src={l.thumbnail_url}
              alt={l.title}
              className="object-cover w-full h-full"
              loading="lazy"
            />
          ) : (
            <span className="text-xs text-gray-400">No image</span>
          )}
        </div>
      ),
    },
    {
      key: "title",
      label: "Title / Slug",
      sortable: true,
      render: (l) => (
        <div>
          <button
            onClick={() =>
              navigate(
                `/provider/${providerId}/listings/${l.type}/${l.id}/edit`
              )
            }
            className="text-sm font-medium text-blue-600 hover:underline"
          >
            {l.title}
          </button>
          <div className="text-xs text-gray-500">{l.slug}</div>
        </div>
      ),
    },
    {
      key: "type",
      label: "Type",
      sortable: true,
      render: (l) => (
        <span className="inline-block text-xs px-2 py-0.5 rounded bg-indigo-100 text-indigo-700 capitalize">
          {l.type}
        </span>
      ),
    },
    {
      key: "visibility",
      label: "Visibility",
      sortable: true,
      render: (l) => (
        <div className="flex items-center gap-1">
          {l.visibility === "public" ? (
            <Globe className="w-4 h-4 text-emerald-600" />
          ) : (
            <Lock className="w-4 h-4 text-gray-500" />
          )}
          <span className="text-xs">{l.visibility}</span>
        </div>
      ),
    },
    {
      key: "is_featured",
      label: "Featured",
      sortable: true,
      render: (l) =>
        l.is_featured ? (
          <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
        ) : (
          <StarOff className="w-4 h-4 text-gray-400" />
        ),
    },
    {
      key: "price",
      label: "Price",
      sortable: true,
      render: (l) =>
        l.price != null
          ? formatCurrency(l.price, l.currency)
          : l.price_from != null
          ? t("from") + " " + formatCurrency(l.price_from, l.currency)
          : "—",
    },
    {
      key: "rating_average",
      label: "Rating",
      sortable: true,
      render: (l) => (
        <div className="flex items-center gap-1">
          <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
          <span>{l.rating_average.toFixed(1)}</span>
        </div>
      ),
    },
    {
      key: "bookings_count_period",
      label: "Bookings",
      sortable: true,
      render: (l) => <span>{l.bookings_count_period}</span>,
    },
    {
      key: "listing_status",
      label: "Status",
      sortable: true,
      render: (l) => (
        <div className="flex flex-col gap-0.5">
          {renderStatusBadge(l.listing_status)}
          {l.listing_status === "published" && l.published_at && (
            <span className="text-[10px] text-gray-500">{l.published_at}</span>
          )}
        </div>
      ),
    },
    {
      key: "actions",
      label: "Actions",
      render: (l) => (
        <div className="flex items-center gap-1 flex-wrap">
          <button
            onClick={() =>
              window.open(
                `/preview/listing/${l.type}/${l.id}?token=dummy-token`,
                "_blank"
              )
            }
            className="p-1 text-gray-600 hover:text-blue-600"
            title="Preview"
          >
            <Eye className="w-4 h-4" />
          </button>
          <button
            onClick={() =>
              navigate(
                `/provider/${providerId}/listings/${l.type}/${l.id}/edit`
              )
            }
            className="p-1 text-gray-600 hover:text-blue-600"
            title="Edit"
          >
            <Pencil className="w-4 h-4" />
          </button>
          <button
            onClick={() => handleDuplicate(l)}
            className="p-1 text-gray-600 hover:text-blue-600"
            title="Duplicate"
          >
            <Copy className="w-4 h-4" />
          </button>
          <button
            onClick={() => handleTogglePublish(l)}
            className="p-1 text-gray-600 hover:text-blue-600"
            title={l.listing_status === "published" ? "Unpublish" : "Publish"}
          >
            <Power className="w-4 h-4" />
          </button>
          <button
            onClick={() => performSingle(l.id, "archive")}
            className="p-1 text-gray-600 hover:text-amber-600"
            title="Archive"
          >
            <Archive className="w-4 h-4" />
          </button>
          <button
            onClick={() => setDeleteTarget(l)}
            className="p-1 text-gray-600 hover:text-red-600"
            title="Delete (soft)"
          >
            <Trash2 className="w-4 h-4" />
          </button>
          <button
            onClick={() => setPromoListing(l)}
            className="p-1 text-gray-600 hover:text-fuchsia-600"
            title="Manage promotions"
          >
            <Tag className="w-4 h-4" />
          </button>
          <button
            onClick={() =>
              navigate(`/provider/${providerId}/bookings?listing_id=${l.id}`)
            }
            className="p-1 text-gray-600 hover:text-indigo-600"
            title="View bookings"
          >
            <BookOpen className="w-4 h-4" />
          </button>
        </div>
      ),
    },
  ];

  const renderTable = () => (
    <div className="overflow-auto border rounded-lg bg-white">
      <table className="min-w-full text-sm">
        <thead className="bg-gray-50">
          <tr>
            {columns.map((col) => {
              const active = col.sortable && col.key === sortField;
              return (
                <th
                  key={col.key}
                  className={cx(
                    "px-3 py-2 font-medium text-left whitespace-nowrap align-middle",
                    col.sortable &&
                      "cursor-pointer select-none hover:bg-gray-100",
                    active ? "text-blue-600" : "text-gray-700"
                  )}
                  onClick={() =>
                    col.sortable && toggleSort(col.key as SortField)
                  }
                >
                  <div className="flex items-center gap-1">
                    {col.key === "select" ? (
                      <input
                        type="checkbox"
                        checked={isAllCurrentPageSelected}
                        onChange={(e) =>
                          toggleSelectAllCurrent(e.target.checked)
                        }
                        className="w-4 h-4"
                      />
                    ) : (
                      col.label
                    )}
                    {col.sortable && col.key === sortField && (
                      <span>{sortDir === "asc" ? "▲" : "▼"}</span>
                    )}
                  </div>
                </th>
              );
            })}
          </tr>
        </thead>
        <tbody>
          {paginated.length === 0 && (
            <tr>
              <td
                colSpan={columns.length}
                className="py-10 text-center text-gray-500 text-sm"
              >
                No data
              </td>
            </tr>
          )}
          {paginated.map((l) => (
            <tr
              key={l.id}
              className="border-t hover:bg-gray-50 transition-colors"
            >
              {columns.map((col) => {
                if (col.key === "select") {
                  return (
                    <td key={col.key} className="px-3 py-2">
                      <input
                        type="checkbox"
                        checked={selectedIds.has(l.id)}
                        onChange={() => toggleSelectOne(l.id)}
                        className="w-4 h-4"
                      />
                    </td>
                  );
                }
                return (
                  <td key={col.key} className="px-3 py-2 align-middle">
                    {col.render
                      ? col.render(l)
                      : (() => {
                          const v = (l as unknown as Record<string, unknown>)[
                            col.key
                          ];
                          if (v === null || v === undefined) return "";
                          if (
                            typeof v === "string" ||
                            typeof v === "number" ||
                            typeof v === "boolean"
                          )
                            return String(v);
                          return v as React.ReactNode;
                        })()}
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );

  const renderGrid = () => (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
      {paginated.length === 0 && (
        <div className="col-span-full text-center text-gray-500">No data</div>
      )}
      {paginated.map((l) => (
        <div
          key={l.id}
          className={cx(
            "border rounded-lg bg-white flex flex-col overflow-hidden relative",
            selectedIds.has(l.id) && "ring-2 ring-blue-400"
          )}
        >
          <div className="relative">
            {l.thumbnail_url ? (
              <img
                src={l.thumbnail_url}
                alt={l.title}
                className="w-full h-40 object-cover"
                loading="lazy"
              />
            ) : (
              <div className="w-full h-40 bg-gray-100 flex items-center justify-center text-xs text-gray-400">
                No image
              </div>
            )}
            <div className="absolute top-2 left-2 flex gap-2">
              <input
                type="checkbox"
                checked={selectedIds.has(l.id)}
                onChange={() => toggleSelectOne(l.id)}
                className="w-4 h-4 shadow"
              />
              {l.is_featured && (
                <Star className="w-4 h-4 text-yellow-400 fill-yellow-400" />
              )}
            </div>
            <div className="absolute top-2 right-2 flex flex-col gap-1">
              {renderStatusBadge(l.listing_status)}
            </div>
          </div>
          <div className="p-3 flex flex-col gap-2 flex-1">
            <div>
              <button
                onClick={() =>
                  navigate(
                    `/provider/${providerId}/listings/${l.type}/${l.id}/edit`
                  )
                }
                className="text-sm font-semibold text-blue-600 hover:underline line-clamp-2 text-left"
              >
                {l.title}
              </button>
              <div className="text-[10px] text-gray-500">{l.slug}</div>
            </div>
            <div className="flex flex-wrap gap-2 text-xs">
              <span className="px-2 py-0.5 bg-indigo-100 text-indigo-700 rounded">
                {l.type}
              </span>
              <span className="px-2 py-0.5 bg-gray-100 text-gray-600 rounded">
                {l.visibility}
              </span>
              {l.area && (
                <span className="px-2 py-0.5 bg-emerald-100 text-emerald-700 rounded">
                  {l.area}
                </span>
              )}
            </div>
            <div className="text-xs text-gray-600 flex flex-col gap-1">
              <div className="flex items-center justify-between">
                <span>Price:</span>
                <span className="font-medium">
                  {l.price != null
                    ? formatCurrency(l.price)
                    : l.price_from != null
                    ? "From " + formatCurrency(l.price_from)
                    : "—"}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span>Rating:</span>
                <span className="flex items-center gap-1">
                  <Star className="w-3 h-3 text-yellow-500 fill-yellow-500" />
                  {l.rating_average.toFixed(1)}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span>Bookings:</span>
                <span>{l.bookings_count_period}</span>
              </div>
              {l.published_at && (
                <div className="flex items-center justify-between">
                  <span>Published:</span>
                  <span>{l.published_at}</span>
                </div>
              )}
            </div>
            <div className="mt-auto flex flex-wrap gap-2 pt-2 border-t">
              <button
                onClick={() =>
                  window.open(
                    `/preview/listing/${l.type}/${l.id}?token=dummy-token`,
                    "_blank"
                  )
                }
                className="px-2 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded"
              >
                Preview
              </button>
              <button
                onClick={() =>
                  navigate(
                    `/provider/${providerId}/listings/${l.type}/${l.id}/edit`
                  )
                }
                className="px-2 py-1 text-xs bg-blue-100 hover:bg-blue-200 text-blue-700 rounded"
              >
                Edit
              </button>
              <button
                onClick={() => handleDuplicate(l)}
                className="px-2 py-1 text-xs bg-purple-100 hover:bg-purple-200 text-purple-700 rounded"
              >
                Clone
              </button>
              <button
                onClick={() => handleTogglePublish(l)}
                className="px-2 py-1 text-xs bg-amber-100 hover:bg-amber-200 text-amber-700 rounded"
              >
                {l.listing_status === "published" ? "Unpublish" : "Publish"}
              </button>
              <button
                onClick={() => performSingle(l.id, "archive")}
                className="px-2 py-1 text-xs bg-gray-200 hover:bg-gray-300 text-gray-700 rounded"
              >
                Archive
              </button>
              <button
                onClick={() => setDeleteTarget(l)}
                className="px-2 py-1 text-xs bg-red-100 hover:bg-red-200 text-red-700 rounded"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      ))}
    </div>
  );

  /* ---------- JSX ---------- */
  return (
    <div className="flex gap-4">
      {/* Left Filters */}
      <div className="w-72 shrink-0 hidden lg:flex flex-col sticky top-0 h-[calc(82vh-1rem)] bg-white border rounded-lg p-4 overflow-auto">
        <div className="flex items-center gap-2 font-semibold mb-2">
          <Filter className="w-4 h-4" />
          <span>Filters</span>
          <button
            onClick={() => {
              // Chỉ để biểu tượng refresh (static data)
              dispatchView({ type: "SET_PAGE", page: 1 });
            }}
            className="ml-auto p-1 rounded hover:bg-gray-100"
            title="Refresh"
          >
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>
        <div className="space-y-4 text-sm">
          <div>
            <label className="font-medium mb-1 block">Search</label>
            <input
              value={filters.q}
              onChange={(e) => setFilters((f) => ({ ...f, q: e.target.value }))}
              placeholder="Title / Slug"
              className="w-full border rounded px-2 py-1 text-sm"
            />
          </div>
          <div>
            <label className="font-medium mb-1 block">Type</label>
            <select
              className="w-full border rounded px-2 py-1"
              value={filters.type}
              onChange={(e) =>
                setFilters((f) => ({
                  ...f,
                  type: e.target.value as ListingType | "",
                }))
              }
            >
              <option value="">All</option>
              <option value="tour">Tour</option>
              <option value="hotel">Hotel</option>
              <option value="restaurant">Restaurant</option>
              <option value="attraction">Attraction</option>
            </select>
          </div>
          <div>
            <label className="font-medium mb-1 block">Status</label>
            <select
              className="w-full border rounded px-2 py-1"
              value={filters.status}
              onChange={(e) =>
                setFilters((f) => ({
                  ...f,
                  status: e.target.value as ListingStatus | "",
                }))
              }
            >
              <option value="">All</option>
              <option value="published">Published</option>
              <option value="draft">Draft</option>
              <option value="archived">Archived</option>
            </select>
          </div>
          <div>
            <label className="font-medium mb-1 block">Area</label>
            <select
              className="w-full border rounded px-2 py-1"
              value={filters.area}
              onChange={(e) =>
                setFilters((f) => ({ ...f, area: e.target.value }))
              }
            >
              {availableAreas.map((a) => (
                <option key={a} value={a}>
                  {a === "all" ? "All" : a}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="font-medium mb-1 block">Rating ≥</label>
            <select
              className="w-full border rounded px-2 py-1"
              value={filters.rating}
              onChange={(e) =>
                setFilters((f) => ({ ...f, rating: e.target.value }))
              }
            >
              <option value="">Any</option>
              <option value="3">3.0</option>
              <option value="3.5">3.5</option>
              <option value="4">4.0</option>
              <option value="4.5">4.5</option>
            </select>
          </div>
          <div>
            <label className="font-medium mb-1 block">Channel</label>
            <input
              value={filters.channel}
              onChange={(e) =>
                setFilters((f) => ({ ...f, channel: e.target.value }))
              }
              placeholder="Channel name"
              className="w-full border rounded px-2 py-1 text-sm"
            />
          </div>
          <div className="flex items-center gap-2">
            <input
              id="featuredOnly"
              type="checkbox"
              className="w-4 h-4"
              checked={filters.featuredOnly}
              onChange={(e) =>
                setFilters((f) => ({ ...f, featuredOnly: e.target.checked }))
              }
            />
            <label htmlFor="featuredOnly" className="text-sm">
              Featured only
            </label>
          </div>
          <div className="flex flex-wrap gap-2 pt-2 border-t">
            {activeFilterTags.map((tag) => (
              <span
                key={tag.key}
                className="inline-flex items-center gap-1 bg-blue-50 text-blue-700 px-2 py-0.5 rounded text-xs"
              >
                {tag.label}
                <button
                  onClick={() => removeFilterTag(tag.key)}
                  className="hover:text-red-600"
                >
                  <X className="w-3 h-3" />
                </button>
              </span>
            ))}
          </div>
          <div className="pt-2 border-t flex gap-2">
            <button
              onClick={clearFilters}
              className="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-medium py-1 rounded"
            >
              Clear
            </button>
            <button
              onClick={() => dispatchView({ type: "SET_PAGE", page: 1 })}
              className="flex-1 bg-blue-600 hover:bg-blue-700 text-white text-xs font-medium py-1 rounded"
            >
              Apply
            </button>
          </div>
        </div>
      </div>

      {/* Right Content */}
      <div className="flex-1 flex flex-col gap-4">
        <div className="flex flex-col gap-2">
          <div className="flex flex-wrap items-center gap-3">
            <h1 className="text-xl font-bold flex items-center gap-2">
              <Layers className="w-5 h-5 text-blue-600" />
              Listings
            </h1>
            <div className="flex items-center gap-1 text-xs text-gray-500">
              <span>Total:</span>
              <span className="font-medium">{total}</span>
            </div>
            {!!activeFilterTags.length && (
              <div className="text-xs text-gray-500">
                Filters: {activeFilterTags.length}
              </div>
            )}
            <div className="ml-auto flex items-center gap-2">
              <div className="flex items-center border rounded-lg overflow-hidden">
                <button
                  onClick={() => setViewMode("table")}
                  className={cx(
                    "px-2 py-1 text-sm flex items-center gap-1",
                    viewMode === "table"
                      ? "bg-blue-600 text-white"
                      : "text-gray-600 hover:bg-gray-100"
                  )}
                  title="Table view"
                >
                  <ListIcon className="w-4 h-4" />
                </button>
                <button
                  onClick={() => setViewMode("grid")}
                  className={cx(
                    "px-2 py-1 text-sm flex items-center gap-1",
                    viewMode === "grid"
                      ? "bg-blue-600 text-white"
                      : "text-gray-600 hover:bg-gray-100"
                  )}
                  title="Grid view"
                >
                  <Grid3x3 className="w-4 h-4" />
                </button>
              </div>
              <div className="hidden lg:block">
                <div className="flex items-center gap-2 border rounded px-2 py-1">
                  <Search className="w-4 h-4 text-gray-400" />
                  <input
                    value={filters.q}
                    onChange={(e) =>
                      setFilters((f) => ({ ...f, q: e.target.value }))
                    }
                    className="outline-none text-sm"
                    placeholder="Search title / slug"
                  />
                </div>
              </div>
            </div>
          </div>
          <div className="lg:hidden">
            <div className="flex items-center gap-2 border rounded px-2 py-1">
              <Search className="w-4 h-4 text-gray-400" />
              <input
                value={filters.q}
                onChange={(e) =>
                  setFilters((f) => ({ ...f, q: e.target.value }))
                }
                className="outline-none text-sm flex-1"
                placeholder="Search..."
              />
              <button
                onClick={() => dispatchView({ type: "SET_PAGE", page: 1 })}
                className="text-xs bg-blue-600 text-white px-2 py-1 rounded"
              >
                Go
              </button>
            </div>
          </div>
        </div>

        {/* Bulk actions */}
        {selectedIds.size > 0 && (
          <div className="border rounded-lg bg-white p-3 flex items-center gap-4 flex-wrap">
            <div className="text-sm font-medium">
              {selectedIds.size} selected
            </div>
            <div className="relative">
              <button
                onClick={() => setShowBulkMenu((s) => !s)}
                className="flex items-center gap-1 bg-blue-600 text-white text-xs font-medium px-3 py-1.5 rounded"
              >
                Bulk Actions
                <ChevronDown className="w-3 h-3" />
              </button>
              {showBulkMenu && (
                <div className="absolute mt-1 w-56 bg-white border rounded shadow-lg z-10 p-1 text-sm">
                  <button
                    onClick={() => performBulkAction("publish")}
                    className="w-full text-left px-2 py-1 rounded hover:bg-gray-100 flex items-center gap-2"
                  >
                    <Power className="w-4 h-4 text-emerald-600" />
                    Publish
                  </button>
                  <button
                    onClick={() => performBulkAction("unpublish")}
                    className="w-full text-left px-2 py-1 rounded hover:bg-gray-100 flex items-center gap-2"
                  >
                    <Power className="w-4 h-4 text-gray-600" />
                    Unpublish
                  </button>
                  <button
                    onClick={() => performBulkAction("archive")}
                    className="w-full text-left px-2 py-1 rounded hover:bg-gray-100 flex items-center gap-2"
                  >
                    <Archive className="w-4 h-4 text-gray-600" />
                    Archive
                  </button>
                  <button
                    onClick={() => performBulkAction("assign_promotion")}
                    className="w-full text-left px-2 py-1 rounded hover:bg-gray-100 flex items-center gap-2"
                  >
                    <Tag className="w-4 h-4 text-fuchsia-600" />
                    Assign Promotion
                  </button>
                  <button
                    onClick={handleExportSelectedCSV}
                    className="w-full text-left px-2 py-1 rounded hover:bg-gray-100 flex items-center gap-2"
                  >
                    <Download className="w-4 h-4 text-blue-600" />
                    Export CSV
                  </button>
                  <button
                    onClick={handleBulkBlockDates}
                    className="w-full text-left px-2 py-1 rounded hover:bg-gray-100 flex items-center gap-2"
                  >
                    <Calendar className="w-4 h-4 text-amber-600" />
                    Bulk Block Dates
                  </button>
                </div>
              )}
            </div>
            <button
              onClick={() => setSelectedIds(new Set())}
              className="text-xs px-2 py-1 rounded bg-gray-100 hover:bg-gray-200"
            >
              Clear selection
            </button>
          </div>
        )}

        {/* Content */}
        <div>{viewMode === "table" ? renderTable() : renderGrid()}</div>

        {/* Pagination */}
        <div className="flex items-center justify-between flex-wrap gap-3">
          <div className="flex items-center gap-2 text-xs text-gray-500">
            <span>Rows per page:</span>
            <select
              value={perPage}
              onChange={(e) => handleChangePerPage(Number(e.target.value))}
              className="border rounded px-2 py-1 text-sm"
            >
              {[10, 20, 50, 100].map((p) => (
                <option key={p} value={p}>
                  {p}
                </option>
              ))}
            </select>
            <span>
              {total > 0
                ? `${(page - 1) * perPage + 1}–${Math.min(
                    page * perPage,
                    total
                  )} of ${total}`
                : `0 of ${total}`}
            </span>
          </div>
          <div className="flex items-center gap-1">
            <button
              onClick={() => handleChangePage(page - 1)}
              disabled={page === 1}
              className="px-2 py-1 border rounded text-sm disabled:opacity-50"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <div className="flex items-center gap-1">
              {Array.from({ length: totalPages }).map((_, i) => {
                const pNum = i + 1;
                if (
                  pNum === 1 ||
                  pNum === totalPages ||
                  Math.abs(pNum - page) <= 1
                ) {
                  return (
                    <button
                      key={pNum}
                      onClick={() => handleChangePage(pNum)}
                      className={cx(
                        "px-2 py-1 rounded text-sm",
                        pNum === page ? "bg-blue-600 text-white" : "border"
                      )}
                    >
                      {pNum}
                    </button>
                  );
                }
                if (pNum === page - 2 || pNum === page + 2) {
                  return (
                    <span key={pNum} className="px-2 text-sm">
                      …
                    </span>
                  );
                }
                return null;
              })}
            </div>
            <button
              onClick={() => handleChangePage(page + 1)}
              disabled={page === totalPages || totalPages === 0}
              className="px-2 py-1 border rounded text-sm disabled:opacity-50"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Delete Confirmation */}
      {deleteTarget && (
        <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/40">
          <div className="bg-white rounded-lg shadow-lg p-6 w-full max-w-sm">
            <div className="flex items-center gap-2 mb-4">
              <AlertTriangle className="w-5 h-5 text-red-500" />
              <h2 className="font-semibold text-sm">
                Confirm soft delete (archive)
              </h2>
            </div>
            <p className="text-xs text-gray-600 mb-4">
              Listing &quot;{deleteTarget.title}&quot; sẽ được chuyển sang trạng
              thái Archived. Bạn có thể khôi phục sau.
            </p>
            <div className="flex justify-end gap-2">
              <button
                onClick={() => setDeleteTarget(null)}
                className="px-3 py-1.5 text-xs border rounded hover:bg-gray-100"
              >
                Cancel
              </button>
              <button
                onClick={handleDeleteConfirm}
                className="px-3 py-1.5 text-xs rounded bg-red-600 text-white hover:bg-red-700"
              >
                Yes, archive
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Validation Modal */}
      {showValidationModal && lastBulkResult && (
        <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/40">
          <div className="bg-white rounded-lg shadow-lg p-6 w-full max-w-lg max-h-[70vh] overflow-auto">
            <div className="flex items-center gap-2 mb-4">
              <AlertTriangle className="w-5 h-5 text-amber-500" />
              <h2 className="font-semibold text-sm">
                Validation Errors (Publish)
              </h2>
            </div>
            <p className="text-xs text-gray-600 mb-4">
              Một số listing không thể publish do thiếu dữ liệu. Vui lòng sửa và
              thử lại.
            </p>
            <div className="space-y-3">
              {lastBulkResult.items
                .filter((i) => !i.ok)
                .map((item) => (
                  <div
                    key={item.id}
                    className="border rounded p-2 bg-amber-50 text-xs"
                  >
                    <div className="font-medium mb-1">
                      ID: {item.id} – Errors:
                    </div>
                    <ul className="list-disc ml-4 space-y-0.5">
                      {item.errors?.map((er) => (
                        <li key={er} className="text-amber-700">
                          {er === "MISSING_THUMBNAIL" && "Thiếu ảnh thumbnail"}
                          {er === "MISSING_PRICE" &&
                            "Thiếu giá (price hoặc price_from)"}
                          {er === "MISSING_SCHEDULE" &&
                            "Thiếu schedule (yêu cầu khi auto_accept)"}
                          {![
                            "MISSING_THUMBNAIL",
                            "MISSING_PRICE",
                            "MISSING_SCHEDULE",
                          ].includes(er) && er}
                        </li>
                      ))}
                    </ul>
                  </div>
                ))}
            </div>
            <div className="flex justify-end mt-4">
              <button
                onClick={() => setShowValidationModal(false)}
                className="px-3 py-1.5 text-xs border rounded hover:bg-gray-100"
              >
                Đóng
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Promotion Modal */}
      {promoListing && (
        <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/40">
          <div className="bg-white rounded-lg shadow-lg p-6 w-full max-w-md">
            <h2 className="text-sm font-semibold mb-2">
              Manage Promotions - {promoListing.title}
            </h2>
            <p className="text-xs text-gray-600 mb-4">
              Placeholder modal. Thêm UI chọn / gán promotion tại đây.
            </p>
            <div className="flex justify-end gap-2">
              <button
                onClick={() => setPromoListing(null)}
                className="px-3 py-1.5 text-xs border rounded hover:bg-gray-100"
              >
                Close
              </button>
              <button className="px-3 py-1.5 text-xs rounded bg-blue-600 text-white hover:bg-blue-700">
                Save
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ListingsPage;
