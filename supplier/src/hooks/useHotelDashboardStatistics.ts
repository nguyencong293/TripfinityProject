import { useState, useEffect, useCallback } from "react";
import { getHotelDashboardStatistics } from "../services/hotelService";
import type { HotelDashboardStatistics } from "../types";

interface UseHotelDashboardStatisticsReturn {
  statistics: HotelDashboardStatistics | null;
  loading: boolean;
  error: string | null;
  refetch: () => Promise<void>;
}

export const useHotelDashboardStatistics = (
  providerId?: number
): UseHotelDashboardStatisticsReturn => {
  const [statistics, setStatistics] = useState<HotelDashboardStatistics | null>(
    null
  );
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const fetchStatistics = useCallback(async () => {
    if (!providerId) {
      setError("Provider ID không hợp lệ");
      setLoading(false);
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const data = await getHotelDashboardStatistics(providerId);
      setStatistics(data);
      setError(null);
    } catch (err: unknown) {
      console.error("Error fetching hotel dashboard statistics:", err);

      let errorMessage = "Không thể tải thống kê. Vui lòng thử lại.";

      if (err && typeof err === "object" && "response" in err) {
        const axiosError = err as {
          response?: { data?: { message?: string } };
        };
        errorMessage = axiosError.response?.data?.message || errorMessage;
      }

      setError(errorMessage);
      setStatistics(null);
    } finally {
      setLoading(false);
    }
  }, [providerId]);

  useEffect(() => {
    fetchStatistics();
  }, [fetchStatistics]);

  return {
    statistics,
    loading,
    error,
    refetch: fetchStatistics,
  };
};
