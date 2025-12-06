import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import type { AttractionDTO } from "../types";
import { getAttractionById, deleteAttraction } from "../services/attractionService";
import { getProviderByUserId } from "../services/providerService";

interface UseAttractionViewReturn {
  attraction: AttractionDTO | null;
  loading: boolean;
  deleting: boolean;
  error: string | null;
  handleDelete: () => Promise<void>;
}

export const useAttractionView = (
  attractionId: string | undefined
): UseAttractionViewReturn => {
  const navigate = useNavigate();
  const [attraction, setAttraction] = useState<AttractionDTO | null>(null);
  const [loading, setLoading] = useState(true);
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);

        if (!attractionId) {
          setError("Không tìm thấy ID điểm tham quan");
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

        // Load attraction data
        const attractionData = await getAttractionById(Number(attractionId));

        // Check if user owns this attraction
        if (attractionData.providerId !== provider.providerId) {
          setError("Bạn không có quyền xem điểm tham quan này");
          navigate("/supplier/service/attraction");
          return;
        }

        setAttraction(attractionData);
      } catch (err) {
        console.error("Error loading attraction:", err);
        setError(
          err instanceof Error ? err.message : "Lỗi tải dữ liệu điểm tham quan"
        );
      } finally {
        setLoading(false);
      }
    })();
  }, [attractionId, navigate]);

  const handleDelete = async () => {
    if (!attraction?.attractionId) return;

    const confirmed = window.confirm(
      `Bạn có chắc chắn muốn xóa điểm tham quan "${attraction.title}"?\nHành động này không thể hoàn tác.`
    );

    if (!confirmed) return;

    setDeleting(true);
    try {
      await deleteAttraction(attraction.attractionId);
      alert("Xóa điểm tham quan thành công!");
      navigate("/supplier/service/attraction");
    } catch (err) {
      console.error("Error deleting attraction:", err);
      setError(err instanceof Error ? err.message : "Lỗi xóa điểm tham quan");
      alert("Lỗi xóa điểm tham quan. Vui lòng thử lại.");
    } finally {
      setDeleting(false);
    }
  };

  return {
    attraction,
    loading,
    deleting,
    error,
    handleDelete,
  };
};
