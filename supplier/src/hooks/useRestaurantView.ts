import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import type { RestaurantDTO } from "../types";
import { getRestaurantById, deleteRestaurant } from "../services/restaurantService";
import { getProviderByUserId } from "../services/providerService";

interface UseRestaurantViewReturn {
  restaurant: RestaurantDTO | null;
  loading: boolean;
  deleting: boolean;
  error: string | null;
  handleDelete: () => Promise<void>;
}

export const useRestaurantView = (
  restaurantId: string | undefined
): UseRestaurantViewReturn => {
  const navigate = useNavigate();
  const [restaurant, setRestaurant] = useState<RestaurantDTO | null>(null);
  const [loading, setLoading] = useState(true);
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);

        if (!restaurantId) {
          setError("Không tìm thấy ID nhà hàng");
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

        // Load restaurant data
        const restaurantData = await getRestaurantById(Number(restaurantId));

        // Check if user owns this restaurant
        if (restaurantData.providerId !== provider.providerId) {
          setError("Bạn không có quyền xem nhà hàng này");
          navigate("/supplier/service/restaurant");
          return;
        }

        setRestaurant(restaurantData);
      } catch (err) {
        console.error("Error loading restaurant:", err);
        setError(
          err instanceof Error ? err.message : "Lỗi tải dữ liệu nhà hàng"
        );
      } finally {
        setLoading(false);
      }
    })();
  }, [restaurantId, navigate]);

  const handleDelete = async () => {
    if (!restaurant?.restaurantId) return;

    const confirmed = window.confirm(
      `Bạn có chắc chắn muốn xóa nhà hàng "${restaurant.title}"?\nHành động này không thể hoàn tác.`
    );

    if (!confirmed) return;

    setDeleting(true);
    try {
      await deleteRestaurant(restaurant.restaurantId);
      alert("Xóa nhà hàng thành công!");
      navigate("/supplier/service/restaurant");
    } catch (err) {
      console.error("Error deleting restaurant:", err);
      setError(err instanceof Error ? err.message : "Lỗi xóa nhà hàng");
      alert("Lỗi xóa nhà hàng. Vui lòng thử lại.");
    } finally {
      setDeleting(false);
    }
  };

  return {
    restaurant,
    loading,
    deleting,
    error,
    handleDelete,
  };
};
