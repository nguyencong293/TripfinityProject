import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import type { TourDTO } from "../types";
import { getTourById, deleteTour } from "../services/tourService";
import { getProviderByUserId } from "../services/providerService";

interface UseTourViewReturn {
  tour: TourDTO | null;
  loading: boolean;
  deleting: boolean;
  error: string | null;
  handleDelete: () => Promise<void>;
}

export const useTourView = (
  tourId: number | undefined
): UseTourViewReturn => {
  const navigate = useNavigate();
  const [tour, setTour] = useState<TourDTO | null>(null);
  const [loading, setLoading] = useState(true);
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);

        if (!tourId) {
          setError("Không tìm thấy ID tour");
          return;
        }

        const userStr = localStorage.getItem("user");
        if (!userStr) {
          navigate("/supplier/login");
          return;
        }

        const user = JSON.parse(userStr);
        const provider = await getProviderByUserId(user.userId);
        if (!provider || !provider.providerId) {
          setError("Không tìm thấy thông tin nhà cung cấp");
          return;
        }

        // Load tour data
        const tourData = await getTourById(tourId);

        // Check if user owns this tour
        if (tourData.providerId !== provider.providerId) {
          setError("Bạn không có quyền xem tour này");
          navigate("/supplier/service/tour");
          return;
        }

        setTour(tourData);
      } catch (err) {
        console.error("Error loading tour:", err);
        setError(
          err instanceof Error ? err.message : "Lỗi tải dữ liệu tour"
        );
      } finally {
        setLoading(false);
      }
    })();
  }, [tourId, navigate]);

  const handleDelete = async () => {
    if (!tour?.tourId) return;

    const confirmed = window.confirm(
      `Bạn có chắc chắn muốn xóa tour "${tour.title}"?\nHành động này không thể hoàn tác.`
    );

    if (!confirmed) return;

    setDeleting(true);
    try {
      await deleteTour(tour.tourId);
      alert("Xóa tour thành công!");
      navigate("/supplier/service/tour");
    } catch (err) {
      console.error("Error deleting tour:", err);
      setError(err instanceof Error ? err.message : "Lỗi xóa tour");
      alert("Lỗi xóa tour. Vui lòng thử lại.");
    } finally {
      setDeleting(false);
    }
  };

  return {
    tour,
    loading,
    deleting,
    error,
    handleDelete,
  };
};
