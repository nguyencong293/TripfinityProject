import React, { useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, Edit, Hotel, ChevronLeft, Trash2, Loader2 } from "lucide-react";
import { useTheme } from "../../../hooks/useTheme";
import { useHotels } from "../../../hooks/useHotels";
import type { HotelDTO } from "../../../types";
import { deleteHotel } from "../../../services/hotelService";

const ListHotelPage: React.FC = () => {
  const navigate = useNavigate();
  const { dark } = useTheme();
  const { hotels, loading, error, refetch } = useHotels();
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [deleteError, setDeleteError] = useState<string | null>(null);

  const onDelete = async (h: HotelDTO) => {
    if (!h.hotelId) return;
    const ok = window.confirm(
      `Bạn có chắc muốn xóa khách sạn ID ${h.hotelId}?`
    );
    if (!ok) return;
    try {
      setDeleteError(null);
      setDeletingId(h.hotelId);
      await deleteHotel(h.hotelId);
      await refetch();
    } catch (e) {
      const msg = e instanceof Error ? e.message : "Xóa khách sạn thất bại";
      setDeleteError(msg);
    } finally {
      setDeletingId(null);
    }
  };

  type ColumnKey =
    | "hotelId"
    | "thumb"
    | "title"
    | "propertyType"
    | "price"
    | "currencyCode"
    | "hotelStatus"
    | "visibility"
    | "starRating"
    | "ratingAverage"
    | "location"
    | "address"
    | "capacity"
    | "minParticipants"
    | "maxParticipants"
    | "createdAt"
    | "updatedAt"
    | "actions";

  const columns: Array<{ key: ColumnKey; label: string }> = useMemo(
    () => [
      { key: "hotelId", label: "ID" },
      { key: "thumb", label: "Ảnh" },
      { key: "title", label: "Tiêu đề" },
      { key: "propertyType", label: "Loại hình" },
      { key: "price", label: "Giá" },
      { key: "currencyCode", label: "Tiền tệ" },
      { key: "hotelStatus", label: "Trạng thái" },
      { key: "visibility", label: "Hiển thị" },
      { key: "starRating", label: "Sao" },
      { key: "ratingAverage", label: "Điểm TB" },
      { key: "location", label: "Khu vực" },
      { key: "address", label: "Địa chỉ" },
      { key: "capacity", label: "Sức chứa" },
      { key: "minParticipants", label: "Tối thiểu" },
      { key: "maxParticipants", label: "Tối đa" },
      { key: "createdAt", label: "Tạo lúc" },
      { key: "updatedAt", label: "Cập nhật" },
      { key: "actions", label: "Thao tác" },
    ],
    []
  );

  const cell = (h: HotelDTO, key: ColumnKey): React.ReactNode => {
    switch (key) {
      case "thumb":
        return h.thumbnailUrl ? (
          <img
            src={h.thumbnailUrl}
            alt={h.title}
            className="w-12 h-12 object-cover rounded"
          />
        ) : (
          <div
            className={`w-12 h-12 rounded flex items-center justify-center ${
              dark ? "bg-gray-700" : "bg-gray-100"
            }`}
          >
            <Hotel className="w-5 h-5 text-gray-400" />
          </div>
        );
      case "hotelId":
        return h.hotelId ?? "";
      case "title":
        return h.title ?? "";
      case "propertyType":
        return h.propertyType ?? "";
      case "price":
        return (
          <span className={dark ? "text-emerald-400" : "text-emerald-700"}>
            {h.price?.toLocaleString("vi-VN")} {h.currencyCode}
          </span>
        );
      case "currencyCode":
        return h.currencyCode ?? "";
      case "hotelStatus":
        return (
          <span
            className={
              "px-2 py-0.5 rounded-full text-xs font-medium border " +
              (h.hotelStatus === "published"
                ? dark
                  ? "bg-emerald-500/20 text-emerald-400 border-emerald-500/30"
                  : "bg-emerald-50 text-emerald-700 border-emerald-200"
                : h.hotelStatus === "archived"
                ? dark
                  ? "bg-gray-500/20 text-gray-300 border-gray-500/30"
                  : "bg-gray-50 text-gray-700 border-gray-200"
                : dark
                ? "bg-red-500/20 text-red-400 border-red-500/30"
                : "bg-red-50 text-red-700 border-red-200")
            }
          >
            {h.hotelStatus === "published"
              ? "Đang hoạt động"
              : h.hotelStatus === "archived"
              ? "Đã lưu trữ"
              : "Vô hiệu hóa"}
          </span>
        );
      case "visibility":
        return h.visibility === "public_" ? "Công khai" : "Riêng tư";
      case "starRating":
        return h.starRating ?? "";
      case "ratingAverage":
        return typeof h.ratingAverage === "number"
          ? h.ratingAverage.toFixed(1)
          : "";
      case "location":
        return h.location ?? "";
      case "address":
        return h.address ?? "";
      case "capacity":
        return h.capacity ?? "";
      case "minParticipants":
        return h.minParticipants ?? "";
      case "maxParticipants":
        return h.maxParticipants ?? "";
      case "createdAt":
      case "updatedAt":
        return (() => {
          const v = key === "createdAt" ? h.createdAt : h.updatedAt;
          return v ? new Date(v).toLocaleString("vi-VN") : "";
        })();
      case "actions":
        return (
          <div className="flex items-center gap-2">
            <button
              onClick={() =>
                navigate(`/supplier/service/hotel/${h.hotelId}/view`)
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
                navigate(`/supplier/service/hotel/${h.hotelId}/edit`)
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
              onClick={() => onDelete(h)}
              disabled={deletingId === h.hotelId}
              className={
                "p-1 rounded flex items-center justify-center min-w-8 " +
                (dark
                  ? "bg-red-500/10 text-red-400 hover:bg-red-500/20 disabled:opacity-50"
                  : "bg-red-50 text-red-600 hover:bg-red-100 disabled:opacity-50")
              }
              title="Xóa khách sạn"
            >
              {deletingId === h.hotelId ? (
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
            Danh sách khách sạn
          </h1>
          <span
            className={"text-sm " + (dark ? "text-gray-400" : "text-gray-600")}
          >
            ({hotels.length} khách sạn)
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
              Đang tải danh sách khách sạn...
            </p>
          </div>
        ) : error ? (
          <div className="p-8 text-center text-red-500 text-sm">{error}</div>
        ) : hotels.length === 0 ? (
          <div className="p-8 text-center">
            <Hotel
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
              Chưa có khách sạn nào
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
                {hotels.map((h) => (
                  <tr
                    key={h.hotelId}
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
                        {cell(h, c.key)}
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

export default ListHotelPage;
