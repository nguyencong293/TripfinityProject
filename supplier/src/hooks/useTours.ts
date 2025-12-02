import { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import type { TourDTO, TourFilters } from "../types";
import {
  getToursByProvider,
  createTour,
} from "../services/tourService";
import { 
  uploadSingleImage, 
  uploadMultipleImages,
  deleteImage,
  deleteMultipleImages 
} from "../services/uploadService";
import { getProviderByUserId } from "../services/providerService";

/* ============================================
 * LIST + FILTER HOOK
 * ============================================ */

interface UseToursReturn {
  tours: TourDTO[];
  filteredTours: TourDTO[];
  loading: boolean;
  error: string | null;
  providerId: number | null;
  filters: TourFilters;
  setFilters: React.Dispatch<React.SetStateAction<TourFilters>>;
  refetch: () => Promise<void>;
  clearFilters: () => void;
}

export const useTours = (): UseToursReturn => {
  const [tours, setTours] = useState<TourDTO[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [providerId, setProviderId] = useState<number | null>(null);
  const [filters, setFilters] = useState<TourFilters>({
    search: "",
    area: "",
    difficultyLevel: "",
    status: "",
    priceMin: undefined,
    priceMax: undefined,
    visibility: "",
    durationDays: undefined,
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

  const fetchTours = useCallback(async () => {
    if (!providerId) return;
    try {
      setLoading(true);
      setError(null);
      const data = await getToursByProvider(providerId);
      setTours(data);
    } catch (err) {
      console.error("Error fetching tours:", err);
      setError(err instanceof Error ? err.message : "Failed to fetch tours");
    } finally {
      setLoading(false);
    }
  }, [providerId]);

  const refetch = useCallback(async () => {
    await fetchTours();
  }, [fetchTours]);

  useEffect(() => {
    (async () => {
      await fetchProviderId();
    })();
  }, [fetchProviderId]);

  useEffect(() => {
    if (providerId) {
      fetchTours();
    }
  }, [providerId, fetchTours]);

  const filteredTours = tours.filter((tour) => {
    if (filters.search) {
      const searchLower = filters.search.toLowerCase();
      const matchesTitle = tour.title?.toLowerCase().includes(searchLower);
      const matchesSlug = tour.slug?.toLowerCase().includes(searchLower);
      const matchesId = tour.tourId?.toString().includes(searchLower);
      if (!matchesTitle && !matchesSlug && !matchesId) return false;
    }

    if (filters.area && tour.location) {
      if (!tour.location.includes(filters.area)) return false;
    }

    if (filters.difficultyLevel && tour.difficultyLevel !== filters.difficultyLevel) {
      return false;
    }

    if (filters.status && tour.tourStatus !== filters.status) {
      return false;
    }

    if (filters.priceMin && tour.price < filters.priceMin) return false;
    if (filters.priceMax && tour.price > filters.priceMax) return false;

    if (filters.visibility && tour.visibility !== filters.visibility) {
      return false;
    }

    if (filters.durationDays && tour.durationDays !== filters.durationDays) {
      return false;
    }

    return true;
  });

  const clearFilters = useCallback(() => {
    setFilters({
      search: "",
      area: "",
      difficultyLevel: "",
      status: "",
      priceMin: undefined,
      priceMax: undefined,
      visibility: "",
      durationDays: undefined,
    });
  }, []);

  return {
    tours,
    filteredTours,
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

type Visibility = NonNullable<TourDTO["visibility"]>;
type TourStatus = TourDTO["tourStatus"];
type DifficultyLevel = TourDTO["difficultyLevel"];
type TourType = TourDTO["tourType"];

interface ItineraryDay {
  day: number;
  title: string;
  activities: string[];
}

interface TourFormData {
  title: string;
  areaId: number | null;
  price: number;
  currencyCode: string;
  tourStatus: TourStatus;
  visibility: Visibility;
  isFeatured: boolean;
  serviceDescription: string;
  location: string;
  address: string;
  latitude?: number | null;
  longitude?: number | null;
  startDate: string;
  endDate: string;
  capacity: number | null;
  minParticipants: number | null;
  maxParticipants: number | null;
  durationDays: number | null;
  difficultyLevel: DifficultyLevel;
  departureLocation: string;
  meetingPoint: string;
  guideLanguagesJson: string[];
  itineraryOverview: string;
  itineraryDetailsJson: ItineraryDay[];
  includedJson: string[];
  excludedJson: string[];
  cancellationPolicy: string;
  policiesText: string;
  tourType: TourType;
  categoriesJson: string[];
  servicesJson: string[];
  badges: string[];
  slug: string;
  seoTitle: string;
  seoDescription: string;
}

interface ValidationErrors {
  [key: string]: string;
}

interface UseTourCreateReturn {
  formData: TourFormData;
  errors: ValidationErrors;
  loading: boolean;
  submitting: boolean;
  providerId: number | null;
  thumbnailFile: File | null;
  imageFiles: File[];
  thumbnailPreview: string | null;
  imagePreviews: string[];
  updateField: <K extends keyof TourFormData>(
    field: K,
    value: TourFormData[K]
  ) => void;
  updateArrayField: (
    field: "guideLanguagesJson" | "includedJson" | "excludedJson" | "categoriesJson" | "servicesJson" | "badges",
    value: string[]
  ) => void;
  setThumbnailFile: (file: File | null) => void;
  setImageFiles: (files: File[]) => void;
  removeImageFile: (index: number) => void;
  validateForm: () => { isValid: boolean; missingFields: string[] };
  handleSubmit: (status?: TourStatus) => Promise<{ success: boolean; missingFields: string[] }>;
  resetForm: () => void;
}

const initialFormData: TourFormData = {
  title: "",
  areaId: null,
  price: 1,
  currencyCode: "VND",
  tourStatus: "published",
  visibility: "public",
  isFeatured: false,
  serviceDescription: "",
  location: "",
  address: "",
  latitude: null,
  longitude: null,
  startDate: "",
  endDate: "",
  capacity: null,
  minParticipants: null,
  maxParticipants: null,
  durationDays: null,
  difficultyLevel: "easy",
  departureLocation: "",
  meetingPoint: "",
  guideLanguagesJson: [],
  itineraryOverview: "",
  itineraryDetailsJson: [],
  includedJson: [],
  excludedJson: [],
  cancellationPolicy: "",
  policiesText: "",
  tourType: "group",
  categoriesJson: [],
  servicesJson: [],
  badges: [],
  slug: "",
  seoTitle: "",
  seoDescription: "",
};

export const useTourCreate = (): UseTourCreateReturn => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState<TourFormData>(initialFormData);
  const [errors, setErrors] = useState<ValidationErrors>({});
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [providerId, setProviderId] = useState<number | null>(null);
  const [thumbnailFile, setThumbnailFile] = useState<File | null>(null);
  const [imageFiles, setImageFiles] = useState<File[]>([]);
  const [thumbnailPreview, setThumbnailPreview] = useState<string | null>(null);
  const [imagePreviews, setImagePreviews] = useState<string[]>([]);

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
        if (provider && provider.providerId) {
          setProviderId(provider.providerId);
        } else {
          setErrors({ general: "Không tìm thấy thông tin nhà cung cấp" });
        }
      } catch (err) {
        console.error("Error loading provider:", err);
        setErrors({
          general:
            err instanceof Error ? err.message : "Failed to load provider",
        });
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  useEffect(() => {
    if (thumbnailFile) {
      const url = URL.createObjectURL(thumbnailFile);
      setThumbnailPreview(url);
      return () => URL.revokeObjectURL(url);
    } else {
      setThumbnailPreview(null);
    }
  }, [thumbnailFile]);

  useEffect(() => {
    const urls = imageFiles.map((file) => URL.createObjectURL(file));
    setImagePreviews(urls);
    return () => urls.forEach((url) => URL.revokeObjectURL(url));
  }, [imageFiles]);

  const updateField = useCallback(
    <K extends keyof TourFormData>(field: K, value: TourFormData[K]) => {
      // DEBUG: console.log(`🔄 updateField: ${String(field)} =`, value);
      
      // Auto-clamp minParticipants và maxParticipants theo capacity
      let finalValue = value;
      if (field === 'minParticipants' || field === 'maxParticipants') {
        const numValue = value as number | null;
        if (numValue !== null && numValue !== undefined) {
          setFormData((prev) => {
            const capacity = prev.capacity;
            if (capacity && numValue > capacity) {
              // Tự động set về capacity nếu vượt quá
              finalValue = capacity as TourFormData[K];
            } else if (numValue < 1) {
              // Tối thiểu là 1
              finalValue = 1 as TourFormData[K];
            }
            return { ...prev, [field]: finalValue };
          });
          setErrors((prev) => {
            const newErrors = { ...prev };
            delete newErrors[field];
            return newErrors;
          });
          return;
        }
      }
      
      setFormData((prev) => ({ ...prev, [field]: finalValue }));
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
      field: "guideLanguagesJson" | "includedJson" | "excludedJson" | "categoriesJson" | "servicesJson" | "badges",
      value: string[]
    ) => {
      // DEBUG: console.log(`🔄 updateArrayField: ${field} =`, value);
      setFormData((prev) => ({
        ...prev,
        [field]: value.filter((v) => String(v).trim() !== ""),
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

  const validateForm = useCallback((): { isValid: boolean; missingFields: string[] } => {
    const newErrors: ValidationErrors = {};
    const missingFields: string[] = [];

    if (!formData.title.trim()) {
      newErrors.title = "Tên tour là bắt buộc";
      missingFields.push("Tên tour");
    }
    if (!formData.areaId) {
      newErrors.areaId = "Vui lòng chọn khu vực";
      missingFields.push("Khu vực");
    }
    if (formData.price <= 0) {
      newErrors.price = "Giá phải lớn hơn 0";
      missingFields.push("Giá tour");
    }
    if (!formData.location.trim()) {
      newErrors.location = "Địa điểm là bắt buộc";
      missingFields.push("Địa điểm");
    }
    if (!formData.address.trim()) {
      newErrors.address = "Địa chỉ là bắt buộc";
      missingFields.push("Địa chỉ");
    }
    if (!formData.serviceDescription.trim()) {
      newErrors.serviceDescription = "Mô tả tour là bắt buộc";
      missingFields.push("Mô tả tour");
    }
    if (!formData.durationDays || formData.durationDays <= 0) {
      newErrors.durationDays = "Số ngày tour là bắt buộc";
      missingFields.push("Số ngày");
    }
    if (!formData.capacity || formData.capacity <= 0) {
      newErrors.capacity = "Sức chứa là bắt buộc";
      missingFields.push("Sức chứa");
    }

    // Validate minParticipants và maxParticipants dựa trên capacity
    if (formData.minParticipants !== null && formData.minParticipants !== undefined) {
      if (formData.minParticipants < 1) {
        newErrors.minParticipants = "Số người tối thiểu phải ít nhất là 1";
        missingFields.push("Số người tối thiểu hợp lệ");
      }
      if (formData.capacity && formData.minParticipants > formData.capacity) {
        newErrors.minParticipants = `Số người tối thiểu không được vượt quá sức chứa (${formData.capacity})`;
        missingFields.push("Số người tối thiểu hợp lệ");
      }
    }

    if (formData.maxParticipants !== null && formData.maxParticipants !== undefined) {
      if (formData.capacity && formData.maxParticipants > formData.capacity) {
        newErrors.maxParticipants = `Số người tối đa không được vượt quá sức chứa (${formData.capacity})`;
        missingFields.push("Số người tối đa hợp lệ");
      }
    }

    if (formData.minParticipants && formData.maxParticipants && 
        formData.minParticipants > formData.maxParticipants) {
      newErrors.minParticipants = "Số người tối thiểu không được lớn hơn số người tối đa";
      missingFields.push("Số người tối thiểu/tối đa hợp lệ");
    }

    if (formData.startDate && formData.endDate && 
        new Date(formData.startDate) > new Date(formData.endDate)) {
      newErrors.startDate = "Ngày bắt đầu không được sau ngày kết thúc";
      missingFields.push("Ngày bắt đầu/kết thúc hợp lệ");
    }

    // DEBUG: console.log("🔍 Validation errors:", newErrors);
    // DEBUG: console.log("🔍 Missing fields:", missingFields);
    
    setErrors(newErrors);
    return { 
      isValid: Object.keys(newErrors).length === 0,
      missingFields 
    };
  }, [formData]);

  const handleSubmit = useCallback(
    async (status?: TourStatus) => {
      if (!providerId) {
        setErrors({ general: "Provider ID không hợp lệ" });
        return { success: false, missingFields: ["Provider ID"] };
      }

      const validation = validateForm();
      if (!validation.isValid) {
        if (window.scrollY > 0) {
          window.scrollTo({ top: 0, behavior: "smooth" });
        }
        return { success: false, missingFields: validation.missingFields };
      }

      setSubmitting(true);
      setErrors({});

      let uploadedThumbnailUrl: string | null = null;
      let uploadedImageUrls: string[] = [];

      try {
        // STEP 1: Upload thumbnail trước (nếu có)
        if (thumbnailFile) {
          uploadedThumbnailUrl = await uploadSingleImage(thumbnailFile);
        }

        // STEP 2: Upload gallery images trước (nếu có)
        if (imageFiles.length > 0) {
          uploadedImageUrls = await uploadMultipleImages(imageFiles);
        }

        // STEP 3: Tạo tourData với URLs đã upload
        // DEBUG: console.log("🚀 Submitting tour with data (raw form):", formData);

        const tourData: Partial<TourDTO> = {
          providerId,
          areaId: formData.areaId!,
          title: formData.title,
          price: formData.price,
          currencyCode: formData.currencyCode,
          tourStatus: status || formData.tourStatus,
          visibility: formData.visibility,
          isFeatured: formData.isFeatured,
          thumbnailUrl: uploadedThumbnailUrl || undefined,
          imageUrls: uploadedImageUrls.length > 0 ? uploadedImageUrls : undefined,
          serviceDescription: formData.serviceDescription || undefined,
          location: formData.location || undefined,
          address: formData.address || undefined,
          latitude: formData.latitude ?? undefined,
          longitude: formData.longitude ?? undefined,
          startDate: formData.startDate || undefined,
          endDate: formData.endDate || undefined,
          capacity: formData.capacity ?? undefined,
          minParticipants: formData.minParticipants ?? undefined,
          maxParticipants: formData.maxParticipants ?? undefined,
          durationDays: formData.durationDays ?? undefined,
          difficultyLevel: formData.difficultyLevel || undefined,
          departureLocation: formData.departureLocation || undefined,
          meetingPoint: formData.meetingPoint || undefined,
          guideLanguagesJson: formData.guideLanguagesJson.length > 0 ? formData.guideLanguagesJson : undefined,
          itineraryOverview: formData.itineraryOverview || undefined,
          itineraryDetailsJson: formData.itineraryDetailsJson.length > 0 
            ? JSON.stringify(formData.itineraryDetailsJson) 
            : undefined,
          includedJson: formData.includedJson.length > 0 ? formData.includedJson : undefined,
          excludedJson: formData.excludedJson.length > 0 ? formData.excludedJson : undefined,
          cancellationPolicy: formData.cancellationPolicy || undefined,
          policiesText: formData.policiesText || undefined,
          tourType: formData.tourType || undefined,
          categoriesJson: formData.categoriesJson.length > 0 ? formData.categoriesJson : undefined,
          servicesJson: formData.servicesJson.length > 0 ? formData.servicesJson : undefined,
          badges: formData.badges.length > 0 ? formData.badges : undefined,
          slug: formData.slug || undefined,
          seoTitle: formData.seoTitle || undefined,
          seoDescription: formData.seoDescription || undefined,
        };

        // DEBUG: console.log("🔍 Final tour payload:", tourData);

        // STEP 4: Create tour trong database với đầy đủ data (bao gồm image URLs)
        const createdTour = await createTour(tourData);
        // DEBUG: console.log("✅ Tour created:", createdTour);

        if (!createdTour.tourId) {
          throw new Error("Tour created but ID not returned");
        }

        // DEBUG: console.log("🎉 Tour creation completed successfully!");
        navigate("/supplier/service/tour");
        setTimeout(() => window.location.reload(), 100);
        return { success: true, missingFields: [] };
      } catch (err) {
        console.error("❌ Error creating tour:", err);
        
        // ROLLBACK: Xóa ảnh đã upload nếu có lỗi
        try {
          if (uploadedThumbnailUrl) {
            await deleteImage(uploadedThumbnailUrl);
          }
          if (uploadedImageUrls.length > 0) {
            await deleteMultipleImages(uploadedImageUrls);
          }
        } catch (cleanupErr) {
          console.error("⚠️ Error cleaning up uploaded images:", cleanupErr);
        }

        setErrors({
          general:
            err instanceof Error ? err.message : "Không thể tạo tour",
        });
        return { success: false, missingFields: [] };
      } finally {
        setSubmitting(false);
      }
    },
    [
      formData,
      providerId,
      validateForm,
      thumbnailFile,
      imageFiles,
      navigate,
    ]
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
