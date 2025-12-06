import React, { useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, Edit, Utensils, ChevronLeft, Trash2, Loader2 } from "lucide-react";
import { useTheme } from "../../../hooks/useTheme";
import { useRestaurants } from "../../../hooks/useRestaurants";
import type { RestaurantDTO } from "../../../types";
import { deleteRestaurant } from "../../../services/restaurantService";

const ListRestaurantPage: React.FC = () => {
  const navigate = useNavigate();
  const { dark } = useTheme();
  const { restaurants, loading, error, refetch } = useRestaurants();
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [deleteError, setDeleteError] = useState<string | null>(null);

  const onDelete = async (r: RestaurantDTO) => {
    if (!r.restaurantId) return;
    const ok = window.confirm(
      `Bạn có chắc chắn muốn xóa nhà hàng "${r.title}" (ID: ${r.restaurantId})?`
    );
    if (!ok) return;
    try {
      setDeleteError(null);
      setDeletingId(r.restaurantId);
      await deleteRestaurant(r.restaurantId);
      await refetch();
    } catch (e) {
      const msg = e instanceof Error ? e.message : "Lỗi khi xóa nhà hàng";
      setDeleteError(msg);
    } finally {
      setDeletingId(null);
    }
  };

  type ColumnKey =
    | "restaurantId"
    | "thumb"
    | "title"
    | "priceLevel"
    | "price"
    | "currencyCode"
    | "restaurantStatus"
    | "visibility"
    | "ratingAverage"
    | "location"
    | "address"
    | "capacity"
    | "minParticipants"
    | "maxParticipants"
    | "phone"
    | "createdAt"
    | "updatedAt"
    | "actions";

  const columns: Array<{ key: ColumnKey; label: string }> = useMemo(
    () => [
      { key: "restaurantId", label: "ID" },
      { key: "thumb", label: "Ảnh" },
      { key: "title", label: "Tên nhà hàng" },
      { key: "priceLevel", label: "Mức giá" },
      { key: "price", label: "Giá TB/người" },
      { key: "currencyCode", label: "Tiền tệ" },
      { key: "restaurantStatus", label: "Trạng thái" },
      { key: "visibility", label: "Hiển thị" },
      { key: "ratingAverage", label: "Đánh giá" },
      { key: "location", label: "Khu vực" },
      { key: "address", label: "Địa chỉ" },
      { key: "capacity", label: "Sức chứa" },
      { key: "minParticipants", label: "Tối thiểu" },
      { key: "maxParticipants", label: "Tối đa" },
      { key: "phone", label: "SĐT" },
      { key: "createdAt", label: "Ngày tạo" },
      { key: "updatedAt", label: "Cập nhật" },
      { key: "actions", label: "Thao tác" },
    ],
    []
  );

  const cell = (r: RestaurantDTO, key: ColumnKey): React.ReactNode => {
    switch (key) {
      case "thumb":
        return r.thumbnailUrl ? (
          <img
            src={r.thumbnailUrl}
            alt={r.title}
            className="w-12 h-12 object-cover rounded"
          />
        ) : (
          <div
            className={`w-12 h-12 rounded flex items-center justify-center ${
              dark ? "bg-gray-700" : "bg-gray-100"
            }`}
          >
            <Utensils className="w-5 h-5 text-gray-400" />
          </div>
        );
      case "restaurantId":
        return r.restaurantId ?? "";
      case "title":
        return r.title ?? "";
      case "priceLevel":
        return (() => {
          const labels: Record<string, string> = {
            cheap: "Rẻ",
            moderate: "Trung bình",
            expensive: "Cao",
            luxury: "Sang trọng",
          };
          return labels[r.priceLevel || ""] || r.priceLevel || "";
        })();
      case "price":
        return (
          <span className={dark ? "text-emerald-400" : "text-emerald-700"}>
            {`${r.price?.toLocaleString("vi-VN")} ${r.currencyCode}`}
          </span>
        );
      case "currencyCode":
        return r.currencyCode ?? "";
      case "restaurantStatus":
        return (
          <span
            className={
              "px-2 py-0.5 rounded-full text-xs font-medium border " +
              (r.restaurantStatus === "published"
                ? dark
                  ? "bg-emerald-500/20 text-emerald-400 border-emerald-500/30"
                  : "bg-emerald-50 text-emerald-700 border-emerald-200"
                : r.restaurantStatus === "archived"
                ? dark
                  ? "bg-gray-500/20 text-gray-300 border-gray-500/30"
                  : "bg-gray-50 text-gray-700 border-gray-200"
                : dark
                ? "bg-red-500/20 text-red-400 border-red-500/30"
                : "bg-red-50 text-red-700 border-red-200")
            }
          >
            {r.restaurantStatus === "published"
              ? "Đã xuất bản"
              : r.restaurantStatus === "archived"
              ? "Đã lưu trữ"
              : "Vô hiệu hóa"}
          </span>
        );
      case "visibility":
        return r.visibility === "public_" ? "Công khai" : "Riêng tư";
      case "ratingAverage":
        return typeof r.ratingAverage === "number"
          ? r.ratingAverage.toFixed(1)
          : "";
      case "location":
        return r.location ?? "";
      case "address":
        return r.address ?? "";
      case "capacity":
        return r.capacity ?? "";
      case "minParticipants":
        return r.minParticipants ?? "";
      case "maxParticipants":
        return r.maxParticipants ?? "";
      case "phone":
        return r.phone ?? "";
      case "createdAt":
      case "updatedAt":
        return (() => {
          const v = key === "createdAt" ? r.createdAt : r.updatedAt;
          return v ? new Date(v).toLocaleString("vi-VN") : "";
        })();
      case "actions":
        return (
          <div className="flex items-center gap-2">
            <button
              onClick={() =>
                navigate(`/supplier/service/restaurant/${r.restaurantId}/view`)
              }
              className={
                "p-1 rounded " +
                (dark
                  ? "bg-blue-500/10 text-blue-400 hover:bg-blue-500/20"
                  : "bg-blue-50 text-blue-700 hover:bg-blue-100")
              }
            >
              <Eye className="w-4 h-4" />
            </button>
            <button
              onClick={() =>
                navigate(`/supplier/service/restaurant/${r.restaurantId}/edit`)
              }
              className={
                "p-1 rounded " +
                (dark
                  ? "bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20"
                  : "bg-emerald-50 text-emerald-700 hover:bg-emerald-100")
              }
            >
              <Edit className="w-4 h-4" />
            </button>
            <button
              onClick={() => onDelete(r)}
              disabled={deletingId === r.restaurantId}
              className={
                "p-1 rounded flex items-center justify-center min-w-8 " +
                (dark
                  ? "bg-red-500/10 text-red-400 hover:bg-red-500/20 disabled:opacity-50"
                  : "bg-red-50 text-red-600 hover:bg-red-100 disabled:opacity-50")
              }
              title="Xóa nhà hàng"
            >
              {deletingId === r.restaurantId ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                <Trash2 className="w-4 h-4" />
              )}
            </button>
          </div>
        );
      default:
        return "";
    }
  };

  return (
    <div className="p-4 md:p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <button
            onClick={() => navigate(-1)}
            className={
              "p-2 rounded-lg " +
              (dark
                ? "bg-gray-800 text-gray-200 hover:bg-gray-700"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200")
            }
            title="Quay lại"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <h1
            className={
              "text-xl font-semibold " + (dark ? "text-white" : "text-gray-900")
            }
          >
            Danh sách nhà hàng
          </h1>
          <span
            className={"text-sm " + (dark ? "text-gray-400" : "text-gray-600")}
          >
            ({restaurants.length} nhà hàng)
          </span>
        </div>
      </div>

      {/* Body */}
      <div
        className={
          "rounded-xl border overflow-hidden " +
          (dark ? "bg-gray-800/50 border-gray-700" : "bg-white border-gray-200")
        }
      >
        {deleteError && (
          <div
            className={
              "px-4 py-2 text-sm " +
              (dark ? "bg-red-900/30 text-red-300" : "bg-red-50 text-red-700")
            }
          >
            {deleteError}
          </div>
        )}
        {loading ? (
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-500 mx-auto mb-2"></div>
            <p
              className={
                "text-sm " + (dark ? "text-gray-400" : "text-gray-600")
              }
            >
              Đang tải...
            </p>
          </div>
        ) : error ? (
          <div className="p-8 text-center text-red-500 text-sm">{error}</div>
        ) : restaurants.length === 0 ? (
          <div className="p-8 text-center">
            <Utensils
              className={
                "w-12 h-12 mx-auto mb-3 " +
                (dark ? "text-gray-600" : "text-gray-400")
              }
            />
            <p
              className={
                "text-sm " + (dark ? "text-gray-400" : "text-gray-600")
              }
            >
              Chưa có nhà hàng nào
            </p>
          </div>
        ) : (
          <div className="overflow-auto">
            <table className="min-w-[1200px] w-full text-sm">
              <thead className={dark ? "bg-gray-900/40" : "bg-gray-50"}>
                <tr>
                  {columns.map((c) => (
                    <th
                      key={c.key as string}
                      className="px-3 py-2 text-left font-medium whitespace-nowrap"
                    >
                      {c.label}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {restaurants.map((r) => (
                  <tr
                    key={r.restaurantId}
                    className={
                      dark
                        ? "border-t border-gray-700 hover:bg-gray-800/60"
                        : "border-t hover:bg-gray-50"
                    }
                  >
                    {columns.map((c) => (
                      <td
                        key={String(c.key)}
                        className="px-3 py-2 align-middle whitespace-nowrap"
                      >
                        {cell(r, c.key)}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

export default ListRestaurantPage;
