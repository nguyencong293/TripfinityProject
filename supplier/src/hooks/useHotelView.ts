import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import type { HotelDTO } from "../types";
import { getHotelById, deleteHotel } from "../services/hotelService";
import { getProviderByUserId } from "../services/providerService";

interface UseHotelViewReturn {
  hotel: HotelDTO | null;
  loading: boolean;
  deleting: boolean;
  error: string | null;
  handleDelete: () => Promise<void>;
}

export const useHotelView = (
  hotelId: string | undefined
): UseHotelViewReturn => {
  const navigate = useNavigate();
  const [hotel, setHotel] = useState<HotelDTO | null>(null);
  const [loading, setLoading] = useState(true);
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);

        if (!hotelId) {
          setError("Không tìm thấy ID khách sạn");
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

        // Load hotel data
        const hotelData = await getHotelById(Number(hotelId));

        // Check if user owns this hotel
        if (hotelData.providerId !== provider.providerId) {
          setError("Bạn không có quyền xem khách sạn này");
          navigate("/supplier/service/hotel");
          return;
        }

        setHotel(hotelData);
      } catch (err) {
        console.error("Error loading hotel:", err);
        setError(
          err instanceof Error ? err.message : "Lỗi tải dữ liệu khách sạn"
        );
      } finally {
        setLoading(false);
      }
    })();
  }, [hotelId, navigate]);

  const handleDelete = async () => {
    if (!hotel?.hotelId) return;

    const confirmed = window.confirm(
      `Bạn có chắc chắn muốn xóa khách sạn "${hotel.title}"?\nHành động này không thể hoàn tác.`
    );

    if (!confirmed) return;

    setDeleting(true);
    try {
      await deleteHotel(hotel.hotelId);
      alert("Xóa khách sạn thành công!");
      navigate("/supplier/service/hotel");
    } catch (err) {
      console.error("Error deleting hotel:", err);
      setError(err instanceof Error ? err.message : "Lỗi xóa khách sạn");
      alert("Lỗi xóa khách sạn. Vui lòng thử lại.");
    } finally {
      setDeleting(false);
    }
  };

  return {
    hotel,
    loading,
    deleting,
    error,
    handleDelete,
  };
};
