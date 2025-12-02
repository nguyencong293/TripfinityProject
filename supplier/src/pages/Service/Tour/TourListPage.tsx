import React, { useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, Edit, MapPin, ChevronLeft, Trash2, Loader2 } from "lucide-react";
import { useTheme } from "../../../hooks/useTheme";
import { useTours } from "../../../hooks/useTours";
import type { TourDTO } from "../../../types";
import { deleteTour } from "../../../services/tourService";
import { useLanguage } from "../../../hooks/useLanguage";

const TourListPage: React.FC = () => {
  const navigate = useNavigate();
  const { dark } = useTheme();
  const { tours, loading, error, refetch } = useTours();
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [deleteError, setDeleteError] = useState<string | null>(null);
  const { t } = useLanguage();

  const onDelete = async (tour: TourDTO) => {
    if (!tour.tourId) return;
    const ok = window.confirm(
      `Bạn có chắc chắn muốn xóa tour "${tour.title}" (ID: ${tour.tourId})?`
    );
    if (!ok) return;
    try {
      setDeleteError(null);
      setDeletingId(tour.tourId);
      await deleteTour(tour.tourId);
      await refetch();
    } catch (e) {
      const msg =
        e instanceof Error ? e.message : "Xóa tour thất bại";
      setDeleteError(msg);
    } finally {
      setDeletingId(null);
    }
  };

  type ColumnKey =
    | "tourId"
    | "thumb"
    | "title"
    | "tourType"
    | "price"
    | "currencyCode"
    | "tourStatus"
    | "visibility"
    | "difficultyLevel"
    | "durationDays"
    | "ratingAverage"
    | "location"
    | "address"
    | "capacity"
    | "minParticipants"
    | "maxParticipants"
    | "startDate"
    | "endDate"
    | "createdAt"
    | "updatedAt"
    | "actions";

  const columns: Array<{ key: ColumnKey; label: string }> = useMemo(
    () => [
      { key: "tourId", label: "ID" },
      { key: "thumb", label: "Ảnh đại diện" },
      { key: "title", label: "Tên tour" },
      { key: "tourType", label: "Loại tour" },
      { key: "price", label: "Giá" },
      { key: "currencyCode", label: "Tiền tệ" },
      { key: "tourStatus", label: "Trạng thái" },
      { key: "visibility", label: "Hiển thị" },
      { key: "difficultyLevel", label: "Độ khó" },
      { key: "durationDays", label: "Số ngày" },
      { key: "ratingAverage", label: "Đánh giá TB" },
      { key: "location", label: "Địa điểm" },
      { key: "address", label: "Địa chỉ" },
      { key: "capacity", label: "Sức chứa" },
      { key: "minParticipants", label: "Tối thiểu" },
      { key: "maxParticipants", label: "Tối đa" },
      { key: "startDate", label: "Ngày bắt đầu" },
      { key: "endDate", label: "Ngày kết thúc" },
      { key: "createdAt", label: "Ngày tạo" },
      { key: "updatedAt", label: "Cập nhật" },
      { key: "actions", label: "Hành động" },
    ],
    []
  );

  const cell = (tour: TourDTO, key: ColumnKey): React.ReactNode => {
    switch (key) {
      case "thumb":
        return tour.thumbnailUrl ? (
          <img
            src={tour.thumbnailUrl}
            alt={tour.title}
            className="w-12 h-12 object-cover rounded"
          />
        ) : (
          <div
            className={`w-12 h-12 rounded flex items-center justify-center ${
              dark ? "bg-gray-700" : "bg-gray-100"
            }`}
          >
            <MapPin className="w-5 h-5 text-gray-400" />
          </div>
        );
      case "tourId":
        return tour.tourId ?? "";
      case "title":
        return tour.title ?? "";
      case "tourType":
        return (
          <span
            className={
              "px-2 py-0.5 rounded-full text-xs font-medium border " +
              (tour.tourType === "group"
                ? dark
                  ? "bg-blue-500/20 text-blue-400 border-blue-500/30"
                  : "bg-blue-50 text-blue-700 border-blue-200"
                : tour.tourType === "private"
                ? dark
                  ? "bg-purple-500/20 text-purple-400 border-purple-500/30"
                  : "bg-purple-50 text-purple-700 border-purple-200"
                : dark
                ? "bg-pink-500/20 text-pink-400 border-pink-500/30"
                : "bg-pink-50 text-pink-700 border-pink-200")
            }
          >
            {tour.tourType === "group"
              ? "Nhóm"
              : tour.tourType === "private"
              ? "Riêng tư"
              : "Tùy chỉnh"}
          </span>
        );
      case "price":
        return (
          <span className={dark ? "text-emerald-400" : "text-emerald-700"}>
            {tour.price?.toLocaleString("vi-VN")} {tour.currencyCode}
          </span>
        );
      case "currencyCode":
        return tour.currencyCode ?? "";
      case "tourStatus":
        return (
          <span
            className={
              "px-2 py-0.5 rounded-full text-xs font-medium border " +
              (tour.tourStatus === "published"
                ? dark
                  ? "bg-emerald-500/20 text-emerald-400 border-emerald-500/30"
                  : "bg-emerald-50 text-emerald-700 border-emerald-200"
                : tour.tourStatus === "archived"
                ? dark
                  ? "bg-gray-500/20 text-gray-300 border-gray-500/30"
                  : "bg-gray-50 text-gray-700 border-gray-200"
                : dark
                ? "bg-red-500/20 text-red-400 border-red-500/30"
                : "bg-red-50 text-red-700 border-red-200")
            }
          >
            {tour.tourStatus === "published"
              ? "Đã xuất bản"
              : tour.tourStatus === "archived"
              ? "Lưu trữ"
              : "Nháp"}
          </span>
        );
      case "visibility":
        return tour.visibility === "public" ? "Công khai" : "Riêng tư";
      case "difficultyLevel":
        return (
          <span
            className={
              "px-2 py-0.5 rounded-full text-xs font-medium border " +
              (tour.difficultyLevel === "easy"
                ? dark
                  ? "bg-green-500/20 text-green-400 border-green-500/30"
                  : "bg-green-50 text-green-700 border-green-200"
                : tour.difficultyLevel === "moderate"
                ? dark
                  ? "bg-orange-500/20 text-orange-400 border-orange-500/30"
                  : "bg-orange-50 text-orange-700 border-orange-200"
                : dark
                ? "bg-red-500/20 text-red-400 border-red-500/30"
                : "bg-red-50 text-red-700 border-red-200")
            }
          >
            {tour.difficultyLevel === "easy"
              ? "Dễ"
              : tour.difficultyLevel === "moderate"
              ? "TB"
              : "Khó"}
          </span>
        );
      case "durationDays":
        return tour.durationDays ? `${tour.durationDays} ngày` : "";
      case "ratingAverage":
        return typeof tour.ratingAverage === "number"
          ? tour.ratingAverage.toFixed(1)
          : "";
      case "location":
        return tour.location ?? "";
      case "address":
        return tour.address ?? "";
      case "capacity":
        return tour.capacity ?? "";
      case "minParticipants":
        return tour.minParticipants ?? "";
      case "maxParticipants":
        return tour.maxParticipants ?? "";
      case "startDate":
      case "endDate":
        return (() => {
          const v = key === "startDate" ? tour.startDate : tour.endDate;
          return v ? new Date(v).toLocaleDateString("vi-VN") : "";
        })();
      case "createdAt":
      case "updatedAt":
        return (() => {
          const v = key === "createdAt" ? tour.createdAt : tour.updatedAt;
          return v ? new Date(v).toLocaleString("vi-VN") : "";
        })();
      case "actions":
        return (
          <div className="flex items-center gap-2">
            <button
              onClick={() =>
                navigate(`/supplier/service/tour/${tour.tourId}/view`)
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
                navigate(`/supplier/service/tour/${tour.tourId}/edit`)
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
              onClick={() => onDelete(tour)}
              disabled={deletingId === tour.tourId}
              className={
                "p-1 rounded flex items-center justify-center min-w-8 " +
                (dark
                  ? "bg-red-500/10 text-red-400 hover:bg-red-500/20 disabled:opacity-50"
                  : "bg-red-50 text-red-600 hover:bg-red-100 disabled:opacity-50")
              }
              title="Xóa tour"
            >
              {deletingId === tour.tourId ? (
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
            title={t("previous")}
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <h1
            className={
              "text-xl font-semibold " + (dark ? "text-white" : "text-gray-900")
            }
          >
            Danh sách Tours
          </h1>
          <span
            className={"text-sm " + (dark ? "text-gray-400" : "text-gray-600")}
          >
            ({tours.length} tours)
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
              Đang tải tours...
            </p>
          </div>
        ) : error ? (
          <div className="p-8 text-center text-red-500 text-sm">{error}</div>
        ) : tours.length === 0 ? (
          <div className="p-8 text-center">
            <MapPin
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
              Chưa có tour nào
            </p>
          </div>
        ) : (
          <div className="overflow-auto">
            <table className="min-w-[1600px] w-full text-sm">
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
                {tours.map((tour) => (
                  <tr
                    key={tour.tourId}
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
                        {cell(tour, c.key)}
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

export default TourListPage;
