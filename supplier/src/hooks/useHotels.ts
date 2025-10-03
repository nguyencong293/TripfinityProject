import { useState, useEffect, useCallback } from "react";
import { getHotelsByProvider } from "../services/hotelService";
import { getProviderByUserId } from "../services/providerService";
import type { HotelDTO, HotelFilters } from "../types";

interface UseHotelsReturn {
  hotels: HotelDTO[];
  filteredHotels: HotelDTO[];
  loading: boolean;
  error: string | null;
  providerId: number | null;
  filters: HotelFilters;
  setFilters: React.Dispatch<React.SetStateAction<HotelFilters>>;
  refetch: () => Promise<void>;
  clearFilters: () => void;
}

export const useHotels = (): UseHotelsReturn => {
  const [hotels, setHotels] = useState<HotelDTO[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [providerId, setProviderId] = useState<number | null>(null);
  const [filters, setFilters] = useState<HotelFilters>({
    search: "",
    area: "",
    propertyType: "",
    status: "",
    starRating: undefined,
    priceMin: undefined,
    priceMax: undefined,
    visibility: "",
  });

  // Fetch provider ID from user info
  const fetchProviderId = useCallback(async () => {
    try {
      const userStr = localStorage.getItem("user");
      if (!userStr) {
        throw new Error("User not found in localStorage");
      }

      const user = JSON.parse(userStr);
      const provider = await getProviderByUserId(user.userId);

      if (provider && provider.providerId) {
        setProviderId(provider.providerId);
        return provider.providerId;
      } else {
        throw new Error("No provider found for this user");
      }
    } catch (err) {
      console.error("Error fetching provider ID:", err);
      setError(err instanceof Error ? err.message : "Failed to fetch provider");
      return null;
    }
  }, []);

  // Fetch hotels by provider
  const fetchHotels = useCallback(async () => {
    if (!providerId) return;

    try {
      setLoading(true);
      setError(null);

      const data = await getHotelsByProvider(providerId);
      setHotels(data);
    } catch (err) {
      console.error("Error fetching hotels:", err);
      setError(err instanceof Error ? err.message : "Failed to fetch hotels");
    } finally {
      setLoading(false);
    }
  }, [providerId]);

  // Refetch function
  const refetch = useCallback(async () => {
    await fetchHotels();
  }, [fetchHotels]);

  // Initial load
  useEffect(() => {
    const init = async () => {
      const pid = await fetchProviderId();
      if (pid) {
        // Will trigger fetchHotels via useEffect dependency
      }
    };
    init();
  }, [fetchProviderId]);

  // Fetch hotels when providerId changes
  useEffect(() => {
    if (providerId) {
      fetchHotels();
    }
  }, [providerId, fetchHotels]);

  // Filter hotels
  const filteredHotels = hotels.filter((hotel) => {
    // Search filter
    if (filters.search) {
      const searchLower = filters.search.toLowerCase();
      const matchesTitle = hotel.title?.toLowerCase().includes(searchLower);
      const matchesSlug = hotel.slug?.toLowerCase().includes(searchLower);
      const matchesId = hotel.hotelId?.toString().includes(searchLower);
      if (!matchesTitle && !matchesSlug && !matchesId) return false;
    }

    // Area filter (assuming area is part of location or address)
    if (filters.area && hotel.location) {
      if (!hotel.location.includes(filters.area)) return false;
    }

    // Property type filter
    if (filters.propertyType && hotel.propertyType !== filters.propertyType) {
      return false;
    }

    // Status filter
    if (filters.status && hotel.hotelStatus !== filters.status) {
      return false;
    }

    // Star rating filter (greater than or equal)
    if (
      filters.starRating &&
      (!hotel.starRating || hotel.starRating < filters.starRating)
    ) {
      return false;
    }

    // Price range filter
    if (filters.priceMin && hotel.price < filters.priceMin) {
      return false;
    }
    if (filters.priceMax && hotel.price > filters.priceMax) {
      return false;
    }

    // Visibility filter
    if (filters.visibility && hotel.visibility !== filters.visibility) {
      return false;
    }

    return true;
  });

  // Clear all filters
  const clearFilters = useCallback(() => {
    setFilters({
      search: "",
      area: "",
      propertyType: "",
      status: "",
      starRating: undefined,
      priceMin: undefined,
      priceMax: undefined,
      visibility: "",
    });
  }, []);

  return {
    hotels,
    filteredHotels,
    loading,
    error,
    providerId,
    filters,
    setFilters,
    refetch,
    clearFilters,
  };
};
