import React, { useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, Edit, Map, ChevronLeft, Trash2, Loader2 } from "lucide-react";
import { useTheme } from "../../../hooks/useTheme";
import { useAttractions } from "../../../hooks/useAttractions";
import type { AttractionDTO } from "../../../types";
import { deleteAttraction } from "../../../services/attractionService";

const ListAttractionPage: React.FC = () => {
  const navigate = useNavigate();
  const { dark } = useTheme();
  const { attractions, loading, error, refetch } = useAttractions();
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [deleteError, setDeleteError] = useState<string | null>(null);

  const onDelete = async (a: AttractionDTO) => {
    if (!a.attractionId) return;
    const ok = window.confirm(
      `Bạn có chắc chắn muốn xóa điểm tham quan "${a.title}" (ID: ${a.attractionId})?`
    );
    if (!ok) return;
    try {
      setDeleteError(null);
      setDeletingId(a.attractionId);
      await deleteAttraction(a.attractionId);
      await refetch();
    } catch (e) {
      const msg =
        e instanceof Error ? e.message : "Lỗi khi xóa điểm tham quan";
      setDeleteError(msg);
    } finally {
      setDeletingId(null);
    }
  };

  type ColumnKey =
    | "attractionId"
    | "thumb"
    | "title"
    | "attractionType"
    | "price"
    | "currencyCode"
    | "attractionStatus"
    | "visibility"
    | "ratingAverage"
    | "location"
    | "address"
    | "capacity"
    | "minParticipants"
    | "maxParticipants"
    | "averageVisitMinutes"
    | "createdAt"
    | "updatedAt"
    | "actions";

  const columns: Array<{ key: ColumnKey; label: string }> = useMemo(
    () => [
      { key: "attractionId", label: "ID" },
      { key: "thumb", label: "Ảnh" },
      { key: "title", label: "Tên điểm tham quan" },
      { key: "attractionType", label: "Loại hình" },
      { key: "price", label: "Giá" },
      { key: "currencyCode", label: "Tiền tệ" },
      { key: "attractionStatus", label: "Trạng thái" },
      { key: "visibility", label: "Hiển thị" },
      { key: "ratingAverage", label: "Đánh giá TB" },
      { key: "location", label: "Khu vực" },
      { key: "address", label: "Địa chỉ" },
      { key: "capacity", label: "Sức chứa" },
      { key: "minParticipants", label: "Tối thiểu" },
      { key: "maxParticipants", label: "Tối đa" },
      { key: "averageVisitMinutes", label: "Thời gian (phút)" },
      { key: "createdAt", label: "Ngày tạo" },
      { key: "updatedAt", label: "Cập nhật" },
      { key: "actions", label: "Thao tác" },
    ],
    []
  );

  const cell = (a: AttractionDTO, key: ColumnKey): React.ReactNode => {
    switch (key) {
      case "thumb":
        return a.thumbnailUrl ? (
          <img
            src={a.thumbnailUrl}
            alt={a.title}
            className="w-12 h-12 object-cover rounded"
          />
        ) : (
          <div
            className={`w-12 h-12 rounded flex items-center justify-center ${
              dark ? "bg-gray-700" : "bg-gray-100"
            }`}
          >
            <Map className="w-5 h-5 text-gray-400" />
          </div>
        );
      case "attractionId":
        return a.attractionId ?? "";
      case "title":
        return a.title ?? "";
      case "attractionType":
        return a.attractionType ?? "";
      case "price":
        return (
          <span className={dark ? "text-emerald-400" : "text-emerald-700"}>
            {`${a.price?.toLocaleString("vi-VN")} ${a.currencyCode}`}
          </span>
        );
      case "currencyCode":
        return a.currencyCode ?? "";
      case "attractionStatus":
        return (
          <span
            className={
              "px-2 py-0.5 rounded-full text-xs font-medium border " +
              (a.attractionStatus === "published"
                ? dark
                  ? "bg-emerald-500/20 text-emerald-400 border-emerald-500/30"
                  : "bg-emerald-50 text-emerald-700 border-emerald-200"
                : a.attractionStatus === "archived"
                ? dark
                  ? "bg-gray-500/20 text-gray-300 border-gray-500/30"
                  : "bg-gray-50 text-gray-700 border-gray-200"
                : dark
                ? "bg-red-500/20 text-red-400 border-red-500/30"
                : "bg-red-50 text-red-700 border-red-200")
            }
          >
            {a.attractionStatus === "published"
              ? "Đã xuất bản"
              : a.attractionStatus === "archived"
              ? "Đã lưu trữ"
              : "Vô hiệu hóa"}
          </span>
        );
      case "visibility":
        return a.visibility === "public_" ? "Công khai" : "Riêng tư";
      case "ratingAverage":
        return typeof a.ratingAverage === "number"
          ? a.ratingAverage.toFixed(1)
          : "";
      case "location":
        return a.location ?? "";
      case "address":
        return a.address ?? "";
      case "capacity":
        return a.capacity ?? "";
      case "minParticipants":
        return a.minParticipants ?? "";
      case "maxParticipants":
        return a.maxParticipants ?? "";
      case "averageVisitMinutes":
        return a.averageVisitMinutes ?? "";
      case "createdAt":
      case "updatedAt":
        return (() => {
          const v = key === "createdAt" ? a.createdAt : a.updatedAt;
          return v ? new Date(v).toLocaleString("vi-VN") : "";
        })();
      case "actions":
        return (
          <div className="flex items-center gap-2">
            <button
              onClick={() =>
                navigate(`/supplier/service/attraction/${a.attractionId}/view`)
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
                navigate(`/supplier/service/attraction/${a.attractionId}/edit`)
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
              onClick={() => onDelete(a)}
              disabled={deletingId === a.attractionId}
              className={
                "p-1 rounded flex items-center justify-center min-w-8 " +
                (dark
                  ? "bg-red-500/10 text-red-400 hover:bg-red-500/20 disabled:opacity-50"
                  : "bg-red-50 text-red-600 hover:bg-red-100 disabled:opacity-50")
              }
              title="Xóa điểm tham quan"
            >
              {deletingId === a.attractionId ? (
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
            Danh sách điểm tham quan
          </h1>
          <span
            className={"text-sm " + (dark ? "text-gray-400" : "text-gray-600")}
          >
            ({attractions.length} điểm)
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
        ) : attractions.length === 0 ? (
          <div className="p-8 text-center">
            <Map
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
              Chưa có điểm tham quan nào
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
                {attractions.map((a) => (
                  <tr
                    key={a.attractionId}
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
                        {cell(a, c.key)}
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

export default ListAttractionPage;
