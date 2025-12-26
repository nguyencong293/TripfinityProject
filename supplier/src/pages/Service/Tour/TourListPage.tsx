import React, { useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, Edit, MapPin, ChevronLeft, Trash2, Loader2 } from "lucide-react";
import { useTours } from "../../../hooks/useTours";
import type { TourDTO } from "../../../types";
import { deleteTour } from "../../../services/tourService";
import { useLanguage } from "../../../hooks/useLanguage";

const TourListPage: React.FC = () => {
  const navigate = useNavigate();
  const { tours, loading, error, refetch } = useTours();
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [deleteError, setDeleteError] = useState<string | null>(null);
  const { t } = useLanguage();

  const onDelete = async (tour: TourDTO) => {
    if (!tour.tourId) return;
    const ok = window.confirm(
      `${t("tour_delete_confirm")} "${tour.title}" (ID: ${tour.tourId})?`
    );
    if (!ok) return;
    try {
      setDeleteError(null);
      setDeletingId(tour.tourId);
      await deleteTour(tour.tourId);
      await refetch();
    } catch (e) {
      const msg =
        e instanceof Error ? e.message : t("tour_delete_error");
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
      { key: "tourId", label: t("tour_col_id") },
      { key: "thumb", label: t("tour_col_thumbnail") },
      { key: "title", label: t("tour_col_name") },
      { key: "tourType", label: t("tour_col_type") },
      { key: "price", label: t("tour_col_price") },
      { key: "currencyCode", label: t("tour_col_currency") },
      { key: "tourStatus", label: t("tour_col_status") },
      { key: "visibility", label: t("tour_col_visibility") },
      { key: "difficultyLevel", label: t("tour_col_difficulty") },
      { key: "durationDays", label: t("tour_col_days") },
      { key: "ratingAverage", label: t("tour_col_rating") },
      { key: "location", label: t("tour_col_location") },
      { key: "address", label: t("tour_col_address") },
      { key: "capacity", label: t("tour_col_capacity") },
      { key: "minParticipants", label: t("tour_col_min") },
      { key: "maxParticipants", label: t("tour_col_max") },
      { key: "startDate", label: t("tour_col_start_date") },
      { key: "endDate", label: t("tour_col_end_date") },
      { key: "createdAt", label: t("tour_col_created_at") },
      { key: "updatedAt", label: t("tour_col_updated_at") },
      { key: "actions", label: t("tour_col_actions") },
    ],
    [t]
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
          <div className="w-12 h-12 rounded flex items-center justify-center theme-bg-skeleton">
            <MapPin className="w-5 h-5 theme-text-disabled" />
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
                ? "theme-bg-info theme-text-info border-light-info dark:border-dark-info"
                : tour.tourType === "private"
                ? "bg-light-secondary dark:bg-dark-secondary theme-text-primary border-light-border dark:border-dark-border"
                : "bg-light-errorBg dark:bg-dark-errorBg theme-text-error border-light-error dark:border-dark-error")
            }
          >
            {tour.tourType === "group"
              ? t("tour_type_group")
              : tour.tourType === "private"
              ? t("tour_type_private")
              : t("tour_type_custom")}
          </span>
        );
      case "price":
        return (
          <span className="theme-text-success">
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
                ? "theme-bg-success theme-text-success border-light-success dark:border-dark-success"
                : tour.tourStatus === "archived"
                ? "theme-bg-skeleton theme-text-disabled border-light-border dark:border-dark-border"
                : "theme-bg-error theme-text-error border-light-error dark:border-dark-error")
            }
          >
            {tour.tourStatus === "published"
              ? t("tour_status_published")
              : tour.tourStatus === "archived"
              ? t("tour_status_archived")
              : t("tour_status_draft")}
          </span>
        );
      case "visibility":
        return tour.visibility === "public" ? t("tour_visibility_public") : t("tour_visibility_private");
      case "difficultyLevel":
        return (
          <span
            className={
              "px-2 py-0.5 rounded-full text-xs font-medium border " +
              (tour.difficultyLevel === "easy"
                ? "theme-bg-success theme-text-success border-light-success dark:border-dark-success"
                : tour.difficultyLevel === "moderate"
                ? "theme-bg-warning theme-text-warning border-light-warning dark:border-dark-warning"
                : "theme-bg-error theme-text-error border-light-error dark:border-dark-error")
            }
          >
            {tour.difficultyLevel === "easy"
              ? t("tour_difficulty_easy")
              : tour.difficultyLevel === "moderate"
              ? t("tour_difficulty_moderate")
              : t("tour_difficulty_hard")}
          </span>
        );
      case "durationDays":
        return tour.durationDays ? `${tour.durationDays} ${t("tour_unit_days")}` : "";
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
              className="p-1 rounded theme-bg-info theme-text-info hover:opacity-80 transition-opacity"
              title={t("view")}
            >
              <Eye className="w-4 h-4" />
            </button>
            <button
              onClick={() =>
                navigate(`/supplier/service/tour/${tour.tourId}/edit`)
              }
              className="p-1 rounded theme-bg-success theme-text-success hover:opacity-80 transition-opacity"
              title={t("edit")}
            >
              <Edit className="w-4 h-4" />
            </button>
            <button
              onClick={() => onDelete(tour)}
              disabled={deletingId === tour.tourId}
              className="p-1 rounded flex items-center justify-center min-w-8 theme-bg-error theme-text-error hover:opacity-80 disabled:opacity-50 transition-opacity"
              title={t("delete")}
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
            className="p-2 rounded-lg theme-bg-card theme-text-primary hover:opacity-80 transition-opacity"
            title={t("previous")}
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <h1 className="text-xl font-semibold theme-text-primary">
            {t("tour_list_title")}
          </h1>
          <span className="text-sm theme-text-secondary">
            ({tours.length} {t("tour_list_count_suffix")})
          </span>
        </div>
        <button
          onClick={() => navigate("/supplier/service/tour/create")}
          className="px-4 py-2 rounded-lg font-medium theme-bg-primary theme-text-button hover:theme-bg-primaryHover transition-colors"
        >
          {t("tour_add_button")}
        </button>
      </div>

      {/* Body */}
      <div className="rounded-xl border theme-border theme-bg-card overflow-hidden">
        {deleteError && (
          <div className="px-4 py-2 text-sm theme-bg-error theme-text-error">
            {deleteError}
          </div>
        )}
        {loading ? (
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-light-primary dark:border-dark-primary mx-auto mb-2"></div>
            <p className="text-sm theme-text-secondary">
              {t("tour_loading")}
            </p>
          </div>
        ) : error ? (
          <div className="p-8 text-center theme-text-error text-sm">{error}</div>
        ) : tours.length === 0 ? (
          <div className="p-8 text-center">
            <MapPin className="w-12 h-12 mx-auto mb-3 theme-text-disabled" />
            <p className="text-sm theme-text-secondary">
              {t("tour_no_tours")}
            </p>
          </div>
        ) : (
          <div className="overflow-auto">
            <table className="min-w-[1600px] w-full text-sm">
              <thead className="theme-bg-secondary">
                <tr>
                  {columns.map((c) => (
                    <th
                      key={c.key as string}
                      className="px-3 py-2 text-left font-medium whitespace-nowrap theme-text-primary"
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
                    className="border-t theme-border hover:theme-bg-skeleton transition-colors"
                  >
                    {columns.map((c) => (
                      <td
                        key={String(c.key)}
                        className="px-3 py-2 align-middle whitespace-nowrap theme-text-primary"
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
