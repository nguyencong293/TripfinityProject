import { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import type { HotelDTO, HotelFilters } from "../types";
import {
  getHotelsByProvider,
  createHotel,
  uploadHotelThumbnail,
  uploadHotelImages,
} from "../services/hotelService";
import { getProviderByUserId } from "../services/providerService";

/* ============================================
 * LIST + FILTER HOOK
 * ============================================ */

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

  const fetchProviderId = useCallback(async () => {
    try {
      const userStr = localStorage.getItem("user");
      if (!userStr) {
        setError("Không tìm thấy thông tin người dùng");
        return null;
      }
      const user = JSON.parse(userStr);
      const provider = await getProviderByUserId(user.userId);
      if (provider && provider.providerId) {
        setProviderId(provider.providerId);
        return provider.providerId;
      } else {
        setError("Không tìm thấy thông tin nhà cung cấp");
        return null;
      }
    } catch (err) {
      console.error("Error fetching provider ID:", err);
      setError(err instanceof Error ? err.message : "Failed to fetch provider");
      return null;
    }
  }, []);

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

  const refetch = useCallback(async () => {
    await fetchHotels();
  }, [fetchHotels]);

  useEffect(() => {
    (async () => {
      await fetchProviderId();
    })();
  }, [fetchProviderId]);

  useEffect(() => {
    if (providerId) {
      fetchHotels();
    }
  }, [providerId, fetchHotels]);

  const filteredHotels = hotels.filter((hotel) => {
    if (filters.search) {
      const searchLower = filters.search.toLowerCase();
      const matchesTitle = hotel.title?.toLowerCase().includes(searchLower);
      const matchesSlug = hotel.slug?.toLowerCase().includes(searchLower);
      const matchesId = hotel.hotelId?.toString().includes(searchLower);
      if (!matchesTitle && !matchesSlug && !matchesId) return false;
    }

    if (filters.area && hotel.location) {
      if (!hotel.location.includes(filters.area)) return false;
    }

    if (filters.propertyType && hotel.propertyType !== filters.propertyType) {
      return false;
    }

    if (filters.status && hotel.hotelStatus !== filters.status) {
      return false;
    }

    if (
      filters.starRating &&
      (!hotel.starRating || hotel.starRating < filters.starRating)
    ) {
      return false;
    }

    if (filters.priceMin && hotel.price < filters.priceMin) return false;
    if (filters.priceMax && hotel.price > filters.priceMax) return false;

    if (filters.visibility && hotel.visibility !== filters.visibility) {
      return false;
    }

    return true;
  });

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

/* ============================================
 * CREATE HOOK
 * ============================================ */

type PropertyType = NonNullable<HotelDTO["propertyType"]>;
type Visibility = NonNullable<HotelDTO["visibility"]>;
type HotelStatus = HotelDTO["hotelStatus"];

interface HotelFormData {
  title: string;
  areaId: number | null;
  price: number;
  pricePerNight?: number | null;
  currencyCode: string;
  propertyType: PropertyType; // type-safe union
  visibility: Visibility;
  isFeatured: boolean;
  serviceDescription: string;
  location: string;
  address: string;
  latitude?: number | null; // Coordinate for map
  longitude?: number | null; // Coordinate for map
  startDate: string;
  endDate: string;
  capacity: number | null;
  maxBedsPerRoom: number | null;
  totalRooms: number | null;
  minParticipants: number | null;
  maxParticipants: number | null;
  starRating: number | null;
  checkinTime: string;
  checkoutTime: string;
  highlightsJson: number[];
  amenitiesJson: number[];
  badges: string[];
  policiesText: string;
  slug: string;
  seoTitle: string;
  seoDescription: string;
}

interface ValidationErrors {
  [key: string]: string;
}

interface UseHotelCreateReturn {
  formData: HotelFormData;
  errors: ValidationErrors;
  loading: boolean;
  submitting: boolean;
  providerId: number | null;
  thumbnailFile: File | null;
  imageFiles: File[];
  thumbnailPreview: string | null;
  imagePreviews: string[];
  updateField: <K extends keyof HotelFormData>(
    field: K,
    value: HotelFormData[K]
  ) => void;
  updateArrayField: (
    field: "highlightsJson" | "amenitiesJson" | "badges",
    value: (number | string)[]
  ) => void;
  setThumbnailFile: (file: File | null) => void;
  setImageFiles: (files: File[]) => void;
  removeImageFile: (index: number) => void;
  validateForm: () => boolean;
  handleSubmit: (status?: HotelStatus) => Promise<void>;
  resetForm: () => void;
}

const initialFormData: HotelFormData = {
  title: "",
  areaId: null,
  price: 1,
  pricePerNight: null,
  currencyCode: "VND",
  propertyType: "hotel",
  visibility: "public_",
  isFeatured: false,
  serviceDescription: "",
  location: "",
  address: "",
  latitude: null,
  longitude: null,
  startDate: "",
  endDate: "",
  capacity: null,
  maxBedsPerRoom: 1,
  totalRooms: null,
  minParticipants: null,
  maxParticipants: null,
  starRating: null,
  checkinTime: "",
  checkoutTime: "",
  highlightsJson: [],
  amenitiesJson: [],
  badges: [],
  policiesText: "",
  slug: "",
  seoTitle: "",
  seoDescription: "",
};

export const useHotelCreate = (): UseHotelCreateReturn => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState<HotelFormData>(initialFormData);
  const [errors, setErrors] = useState<ValidationErrors>({});
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [providerId, setProviderId] = useState<number | null>(null);
  const [thumbnailFile, setThumbnailFile] = useState<File | null>(null);
  const [imageFiles, setImageFiles] = useState<File[]>([]);
  const [thumbnailPreview, setThumbnailPreview] = useState<string | null>(null);
  const [imagePreviews, setImagePreviews] = useState<string[]>([]);

  /* Helper: normalize array of (string|number) to number[] safely */
  const toNumberArray = (arr: (string | number)[]): number[] =>
    arr
      .map((v) =>
        typeof v === "number"
          ? v
          : v.trim() === ""
          ? NaN
          : Number.isNaN(Number(v))
          ? NaN
          : Number(v)
      )
      .filter((n) => !Number.isNaN(n));

  useEffect(() => {
    (async () => {
      try {
        const userStr = localStorage.getItem("user");
        if (!userStr) {
          setErrors({ general: "Không tìm thấy thông tin người dùng" });
          return;
        }
        const user = JSON.parse(userStr);
        const provider = await getProviderByUserId(user.userId);
        if (provider?.providerId) {
          setProviderId(provider.providerId);
        } else {
          setErrors({ general: "Không tìm thấy thông tin nhà cung cấp" });
        }
      } catch (err) {
        console.error("Error fetching provider ID:", err);
        setErrors({
          general: err instanceof Error ? err.message : "Lỗi không xác định",
        });
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  useEffect(() => {
    console.log("🔄 thumbnailFile changed:", thumbnailFile);
    if (thumbnailFile) {
      const url = URL.createObjectURL(thumbnailFile);
      console.log("✅ Created thumbnail preview:", url);
      setThumbnailPreview(url);
      return () => URL.revokeObjectURL(url);
    } else {
      setThumbnailPreview(null);
    }
  }, [thumbnailFile]);

  useEffect(() => {
    console.log("🔄 imageFiles changed:", imageFiles.length, "files");
    const urls = imageFiles.map((file) => URL.createObjectURL(file));
    console.log("✅ Created image previews:", urls.length);
    setImagePreviews(urls);
    return () => urls.forEach((url) => URL.revokeObjectURL(url));
  }, [imageFiles]);

  const updateField = useCallback(
    <K extends keyof HotelFormData>(field: K, value: HotelFormData[K]) => {
      // DEBUG: console.log(`🔄 updateField: ${String(field)} =`, value);
      setFormData((prev) => ({ ...prev, [field]: value }));
      setErrors((prev) => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    },
    []
  );

  const updateArrayField = useCallback(
    (
      field: "highlightsJson" | "amenitiesJson" | "badges",
      value: (number | string)[]
    ) => {
      // DEBUG: console.log(`🔄 updateArrayField: ${field} =`, value);
      setFormData((prev) => ({
        ...prev,
        [field]:
          field === "badges"
            ? (value.filter((v) => String(v).trim() !== "") as string[])
            : toNumberArray(value),
      }));
      setErrors((prev) => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    },
    []
  );

  const removeImageFile = useCallback((index: number) => {
    setImageFiles((prev) => prev.filter((_, i) => i !== index));
  }, []);

  const validateForm = useCallback((): boolean => {
    const newErrors: ValidationErrors = {};

    // Required fields - Bắt buộc
    if (!formData.title.trim()) 
      newErrors.title = "Tiêu đề là bắt buộc";
    if (!formData.areaId) 
      newErrors.areaId = "Khu vực là bắt buộc";
    if (!formData.price || formData.price <= 0)
      newErrors.price = "Giá phải lớn hơn 0";
    if (!formData.propertyType)
      newErrors.propertyType = "Loại hình là bắt buộc";
    if (!formData.serviceDescription.trim())
      newErrors.serviceDescription = "Mô tả dịch vụ là bắt buộc";
    if (!formData.location.trim())
      newErrors.location = "Khu vực/địa phương là bắt buộc";
    if (!formData.address.trim())
      newErrors.address = "Địa chỉ là bắt buộc";
    if (!formData.latitude || !formData.longitude)
      newErrors.address = "Vị trí bản đồ là bắt buộc";
    if (!formData.startDate)
      newErrors.startDate = "Ngày bắt đầu là bắt buộc";
    if (!formData.endDate)
      newErrors.endDate = "Ngày kết thúc là bắt buộc";
    if (!formData.capacity || formData.capacity <= 0)
      newErrors.capacity = "Sức chứa là bắt buộc";
    if (!formData.maxBedsPerRoom || formData.maxBedsPerRoom < 1)
      newErrors.maxBedsPerRoom = "Số giường/phòng là bắt buộc";
    if (!formData.totalRooms || formData.totalRooms <= 0)
      newErrors.totalRooms = "Tổng số phòng là bắt buộc";
    if (!formData.starRating)
      newErrors.starRating = "Xếp hạng sao là bắt buộc";
    if (!formData.checkinTime.trim())
      newErrors.checkinTime = "Giờ check-in là bắt buộc";
    if (!formData.checkoutTime.trim())
      newErrors.checkoutTime = "Giờ check-out là bắt buộc";
    if (!formData.policiesText.trim())
      newErrors.policiesText = "Chính sách là bắt buộc";
    
    // Validation logic
    if (formData.pricePerNight != null && formData.pricePerNight < 0)
      newErrors.pricePerNight = "Giá mỗi đêm không hợp lệ";
    
    if (formData.starRating && (formData.starRating < 1 || formData.starRating > 5))
      newErrors.starRating = "Đánh giá sao phải từ 1-5";

    if (formData.minParticipants && formData.maxParticipants && 
        formData.minParticipants > formData.maxParticipants)
      newErrors.minParticipants = "Số lượng tối thiểu không được lớn hơn tối đa";

    if (formData.startDate && formData.endDate && 
        new Date(formData.startDate) > new Date(formData.endDate))
      newErrors.startDate = "Ngày bắt đầu không được sau ngày kết thúc";

    // DEBUG: console.log("🔍 Validation errors:", newErrors);
    // DEBUG: console.log("🔍 Validation result:", Object.keys(newErrors).length === 0);
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [formData]);

  const handleSubmit = useCallback(
    async (status: HotelStatus = "published") => {
      if (!validateForm()) {
        setErrors((prev) => ({
          ...prev,
          general: "Vui lòng kiểm tra lại các trường bắt buộc",
        }));
        // Hiển thị popup xác nhận reload để fix map loading
        const shouldReload = window.confirm(
          "❌ Vui lòng điền đầy đủ các trường bắt buộc!\n\n" +
          "Bản đồ đang bị lỗi hiển thị. Bạn có muốn tải lại trang để tiếp tục không?\n\n" +
          "(Các thông tin bạn đã nhập sẽ bị mất)"
        );
        if (shouldReload) {
          window.location.reload();
        }
        return;
      }

      if (!providerId) {
        setErrors({ general: "Không tìm thấy thông tin nhà cung cấp" });
        const shouldReload = window.confirm(
          "❌ Không tìm thấy thông tin nhà cung cấp!\n\n" +
          "Bạn có muốn tải lại trang để thử lại không?"
        );
        if (shouldReload) {
          window.location.reload();
        }
        return;
      }

      setSubmitting(true);
      setErrors({});

      try {
        // STEP 1: Prepare hotel data (without images)
        const hotelData: Partial<HotelDTO> = {
          providerId,
          areaId: formData.areaId!,
          title: formData.title,
          price: formData.price,
          pricePerNight: formData.pricePerNight ?? undefined,
          currencyCode: formData.currencyCode,
          propertyType: formData.propertyType,
          visibility: formData.visibility,
          isFeatured: formData.isFeatured,
          hotelStatus: status,
          highlightsJson:
            formData.highlightsJson.length > 0 ? formData.highlightsJson : [],
          amenitiesJson:
            formData.amenitiesJson.length > 0 ? formData.amenitiesJson : [],
          badges: formData.badges.length > 0 ? formData.badges : [],
        };

        if (formData.serviceDescription.trim())
          hotelData.serviceDescription = formData.serviceDescription.trim();
        if (formData.location.trim())
          hotelData.location = formData.location.trim();
        if (formData.address.trim())
          hotelData.address = formData.address.trim();
        if (formData.latitude !== null && formData.latitude !== undefined)
          hotelData.latitude = formData.latitude;
        if (formData.longitude !== null && formData.longitude !== undefined)
          hotelData.longitude = formData.longitude;
        if (formData.slug.trim()) hotelData.slug = formData.slug.trim();
        if (formData.seoTitle.trim())
          hotelData.seoTitle = formData.seoTitle.trim();
        if (formData.seoDescription.trim())
          hotelData.seoDescription = formData.seoDescription.trim();
        if (formData.policiesText.trim())
          hotelData.policiesText = formData.policiesText.trim();

        if (formData.startDate) hotelData.startDate = formData.startDate;
        if (formData.endDate) hotelData.endDate = formData.endDate;

        if (formData.capacity) hotelData.capacity = formData.capacity;
        if (formData.maxBedsPerRoom)
          hotelData.maxBedsPerRoom = formData.maxBedsPerRoom;
        if (formData.totalRooms)
          hotelData.totalRooms = formData.totalRooms;
        if (formData.minParticipants)
          hotelData.minParticipants = formData.minParticipants;
        if (formData.maxParticipants)
          hotelData.maxParticipants = formData.maxParticipants;
        if (formData.starRating) hotelData.starRating = formData.starRating;

        if (formData.checkinTime) hotelData.checkinTime = formData.checkinTime;
        if (formData.checkoutTime)
          hotelData.checkoutTime = formData.checkoutTime;

        // STEP 2: Create hotel first (without images)
        const createdHotel = await createHotel(hotelData);
        console.log("✅ Hotel created:", createdHotel);

        if (!createdHotel.hotelId) {
          throw new Error("Hotel created but ID not returned");
        }

        // STEP 3: Upload thumbnail (using FormData like EDIT does)
        if (thumbnailFile) {
          await uploadHotelThumbnail(createdHotel.hotelId, thumbnailFile);
        }

        // STEP 4: Upload images (using FormData like EDIT does)
        if (imageFiles.length > 0) {
          await uploadHotelImages(createdHotel.hotelId, imageFiles);
        }

        navigate("/supplier/service/hotel");
        setTimeout(() => window.location.reload(), 100);
      } catch (err) {
        console.error("❌ Error creating hotel:", err);
        setErrors({
          general: err instanceof Error ? err.message : "Lỗi tạo khách sạn",
        });
      } finally {
        setSubmitting(false);
      }
    },
    [formData, providerId, thumbnailFile, imageFiles, validateForm, navigate]
  );

  const resetForm = useCallback(() => {
    setFormData(initialFormData);
    setErrors({});
    setThumbnailFile(null);
    setImageFiles([]);
  }, []);

  return {
    formData,
    errors,
    loading,
    submitting,
    providerId,
    thumbnailFile,
    imageFiles,
    thumbnailPreview,
    imagePreviews,
    updateField,
    updateArrayField,
    setThumbnailFile,
    setImageFiles,
    removeImageFile,
    validateForm,
    handleSubmit,
    resetForm,
  };
};
