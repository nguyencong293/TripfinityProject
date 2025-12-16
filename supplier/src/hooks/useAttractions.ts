import { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import type { AttractionDTO, AttractionFilters } from "../types";
import {
  getAttractionsByProvider,
  createAttraction,
} from "../services/attractionService";
import {
  uploadSingleImage,
  uploadMultipleImages,
  deleteImage,
  deleteMultipleImages,
} from "../services/uploadService";
import { getProviderByUserId } from "../services/providerService";

/* ============================================
 * LIST + FILTER HOOK
 * ============================================ */

interface UseAttractionsReturn {
  attractions: AttractionDTO[];
  filteredAttractions: AttractionDTO[];
  loading: boolean;
  error: string | null;
  providerId: number | null;
  filters: AttractionFilters;
  setFilters: React.Dispatch<React.SetStateAction<AttractionFilters>>;
  refetch: () => Promise<void>;
  clearFilters: () => void;
}

export const useAttractions = (): UseAttractionsReturn => {
  const [attractions, setAttractions] = useState<AttractionDTO[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [providerId, setProviderId] = useState<number | null>(null);
  const [filters, setFilters] = useState<AttractionFilters>({
    search: "",
    area: "",
    attractionType: "",
    status: "",
    priceMin: undefined,
    priceMax: undefined,
    visibility: "",
    suitableFor: "",
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

  const fetchAttractions = useCallback(async () => {
    if (!providerId) return;
    try {
      setLoading(true);
      setError(null);
      const data = await getAttractionsByProvider(providerId);
      setAttractions(data);
    } catch (err) {
      console.error("Error fetching attractions:", err);
      setError(err instanceof Error ? err.message : "Failed to fetch attractions");
    } finally {
      setLoading(false);
    }
  }, [providerId]);

  const refetch = useCallback(async () => {
    await fetchAttractions();
  }, [fetchAttractions]);

  useEffect(() => {
    (async () => {
      await fetchProviderId();
    })();
  }, [fetchProviderId]);

  useEffect(() => {
    if (providerId) {
      fetchAttractions();
    }
  }, [providerId, fetchAttractions]);

  const filteredAttractions = attractions.filter((attraction) => {
    if (filters.search) {
      const searchLower = filters.search.toLowerCase();
      const matchesTitle = attraction.title?.toLowerCase().includes(searchLower);
      const matchesSlug = attraction.slug?.toLowerCase().includes(searchLower);
      const matchesId = attraction.attractionId?.toString().includes(searchLower);
      if (!matchesTitle && !matchesSlug && !matchesId) return false;
    }

    if (filters.area && attraction.location) {
      if (!attraction.location.includes(filters.area)) return false;
    }

    if (filters.attractionType && attraction.attractionType !== filters.attractionType) {
      return false;
    }

    if (filters.status && attraction.attractionStatus !== filters.status) {
      return false;
    }

    if (filters.priceMin && attraction.price < filters.priceMin) return false;
    if (filters.priceMax && attraction.price > filters.priceMax) return false;

    if (filters.visibility && attraction.visibility !== filters.visibility) {
      return false;
    }

    if (filters.suitableFor && attraction.suitableForJson) {
      if (!attraction.suitableForJson.includes(filters.suitableFor)) {
        return false;
      }
    }

    return true;
  });

  const clearFilters = useCallback(() => {
    setFilters({
      search: "",
      area: "",
      attractionType: "",
      status: "",
      priceMin: undefined,
      priceMax: undefined,
      visibility: "",
      suitableFor: "",
    });
  }, []);

  return {
    attractions,
    filteredAttractions,
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

type AttractionType = NonNullable<AttractionDTO["attractionType"]>;
type Visibility = NonNullable<AttractionDTO["visibility"]>;
type AttractionStatus = AttractionDTO["attractionStatus"];

interface AttractionFormData {
  title: string;
  areaId: number | null;
  price: number;
  currencyCode: string;
  attractionType: AttractionType;
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
  averageVisitMinutes: number | null;
  visitTypesJson: string[];
  availableTimesJson: string[];
  suitableForJson: string[];
  featuresJson: number[];
  openingHoursJson: { [key: string]: string };
  highlightsJson: number[];
  badges: string[];
  policiesText: string;
  tipsText: string;
  slug: string;
  seoTitle: string;
  seoDescription: string;
}

interface ValidationErrors {
  [key: string]: string;
}

interface UseAttractionCreateReturn {
  formData: AttractionFormData;
  errors: ValidationErrors;
  loading: boolean;
  submitting: boolean;
  providerId: number | null;
  thumbnailFile: File | null;
  imageFiles: File[];
  thumbnailPreview: string | null;
  imagePreviews: string[];
  updateField: <K extends keyof AttractionFormData>(
    field: K,
    value: AttractionFormData[K]
  ) => void;
  updateArrayField: (
    field: "highlightsJson" | "featuresJson" | "badges" | "visitTypesJson" | "availableTimesJson" | "suitableForJson",
    value: (number | string)[]
  ) => void;
  updateOpeningHours: (day: string, value: string) => void;
  setThumbnailFile: (file: File | null) => void;
  setImageFiles: (files: File[]) => void;
  removeImageFile: (index: number) => void;
  validateForm: () => boolean;
  handleSubmit: (status?: AttractionStatus) => Promise<void>;
  resetForm: () => void;
}

const initialFormData: AttractionFormData = {
  title: "",
  areaId: null,
  price: 1,
  currencyCode: "VND",
  attractionType: "other",
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
  minParticipants: null,
  maxParticipants: null,
  averageVisitMinutes: null,
  visitTypesJson: [],
  availableTimesJson: [],
  suitableForJson: [],
  featuresJson: [],
  openingHoursJson: {
    monday: "",
    tuesday: "",
    wednesday: "",
    thursday: "",
    friday: "",
    saturday: "",
    sunday: "",
  },
  highlightsJson: [],
  badges: [],
  policiesText: "",
  tipsText: "",
  slug: "",
  seoTitle: "",
  seoDescription: "",
};

export const useAttractionCreate = (): UseAttractionCreateReturn => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState<AttractionFormData>(initialFormData);
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
    console.log("🔄 [Attraction] thumbnailFile changed:", thumbnailFile);
    if (thumbnailFile) {
      const url = URL.createObjectURL(thumbnailFile);
      console.log("✅ [Attraction] Created thumbnail preview:", url);
      setThumbnailPreview(url);
      return () => URL.revokeObjectURL(url);
    } else {
      setThumbnailPreview(null);
    }
  }, [thumbnailFile]);

  useEffect(() => {
    console.log("🔄 [Attraction] imageFiles changed:", imageFiles.length, "files");
    const urls = imageFiles.map((file) => URL.createObjectURL(file));
    console.log("✅ [Attraction] Created image previews:", urls.length);
    setImagePreviews(urls);
    return () => urls.forEach((url) => URL.revokeObjectURL(url));
  }, [imageFiles]);

  const updateField = useCallback(
    <K extends keyof AttractionFormData>(field: K, value: AttractionFormData[K]) => {
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
      field: "highlightsJson" | "featuresJson" | "badges" | "visitTypesJson" | "availableTimesJson" | "suitableForJson",
      value: (number | string)[]
    ) => {
      setFormData((prev) => ({
        ...prev,
        [field]:
          field === "badges" || field === "visitTypesJson" || field === "availableTimesJson" || field === "suitableForJson"
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

  const updateOpeningHours = useCallback((day: string, value: string) => {
    setFormData((prev) => ({
      ...prev,
      openingHoursJson: {
        ...prev.openingHoursJson,
        [day]: value,
      },
    }));
  }, []);

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
    if (!formData.attractionType)
      newErrors.attractionType = "Loại hình là bắt buộc";
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
    if (!formData.averageVisitMinutes || formData.averageVisitMinutes <= 0)
      newErrors.averageVisitMinutes = "Thời gian tham quan là bắt buộc";
    if (!formData.policiesText.trim())
      newErrors.policiesText = "Chính sách là bắt buộc";
    
    // Opening hours validation - at least one day should have hours
    const hasOpeningHours = Object.values(formData.openingHoursJson).some(
      (hours) => hours && hours.trim() !== ""
    );
    if (!hasOpeningHours)
      newErrors.openingHoursJson = "Cần nhập giờ mở cửa cho ít nhất một ngày";

    // Validation logic
    if (formData.minParticipants && formData.maxParticipants && 
        formData.minParticipants > formData.maxParticipants)
      newErrors.minParticipants = "Số lượng tối thiểu không được lớn hơn tối đa";

    if (formData.startDate && formData.endDate && 
        new Date(formData.startDate) > new Date(formData.endDate))
      newErrors.startDate = "Ngày bắt đầu không được sau ngày kết thúc";

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [formData]);

  const handleSubmit = useCallback(
    async (status: AttractionStatus = "published") => {
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

      let uploadedThumbnailUrl: string | null = null;
      let uploadedImageUrls: string[] = [];

      try {
        console.log("🚀 [Attraction] Starting upload process...");
        console.log("📦 [Attraction] thumbnailFile:", thumbnailFile);
        console.log("📦 [Attraction] imageFiles:", imageFiles);
        
        // STEP 1: Upload thumbnail first (independent of attraction ID)
        if (thumbnailFile) {
          console.log("📸 [Attraction] Uploading thumbnail...", thumbnailFile.name);
          uploadedThumbnailUrl = await uploadSingleImage(thumbnailFile);
          console.log("✅ [Attraction] Thumbnail uploaded:", uploadedThumbnailUrl);
        }

        // STEP 2: Upload gallery images (independent of attraction ID)
        if (imageFiles.length > 0) {
          console.log("🖼️ [Attraction] Uploading", imageFiles.length, "images...");
          uploadedImageUrls = await uploadMultipleImages(imageFiles);
          console.log("✅ [Attraction] Images uploaded:", uploadedImageUrls);
        }

        // STEP 3: Prepare attraction data
        const attractionData: Partial<AttractionDTO> = {
          providerId,
          areaId: formData.areaId!,
          title: formData.title,
          price: formData.price,
          currencyCode: formData.currencyCode,
          attractionType: formData.attractionType,
          visibility: formData.visibility,
          isFeatured: formData.isFeatured,
          attractionStatus: status,
          highlightsJson:
            formData.highlightsJson.length > 0 ? formData.highlightsJson : [],
          featuresJson:
            formData.featuresJson.length > 0 ? formData.featuresJson : [],
          badges: formData.badges.length > 0 ? formData.badges : [],
          visitTypesJson:
            formData.visitTypesJson.length > 0 ? formData.visitTypesJson : [],
          availableTimesJson:
            formData.availableTimesJson.length > 0 ? formData.availableTimesJson : [],
          suitableForJson:
            formData.suitableForJson.length > 0 ? formData.suitableForJson : [],
        };

        if (formData.serviceDescription.trim())
          attractionData.serviceDescription = formData.serviceDescription.trim();
        if (formData.location.trim())
          attractionData.location = formData.location.trim();
        if (formData.address.trim())
          attractionData.address = formData.address.trim();
        if (formData.latitude !== null && formData.latitude !== undefined)
          attractionData.latitude = formData.latitude;
        if (formData.longitude !== null && formData.longitude !== undefined)
          attractionData.longitude = formData.longitude;
        if (formData.slug.trim()) attractionData.slug = formData.slug.trim();
        if (formData.seoTitle.trim())
          attractionData.seoTitle = formData.seoTitle.trim();
        if (formData.seoDescription.trim())
          attractionData.seoDescription = formData.seoDescription.trim();
        if (formData.policiesText.trim())
          attractionData.policiesText = formData.policiesText.trim();
        if (formData.tipsText.trim())
          attractionData.tipsText = formData.tipsText.trim();

        if (formData.startDate) attractionData.startDate = formData.startDate;
        if (formData.endDate) attractionData.endDate = formData.endDate;

        if (formData.capacity) attractionData.capacity = formData.capacity;
        if (formData.minParticipants)
          attractionData.minParticipants = formData.minParticipants;
        if (formData.maxParticipants)
          attractionData.maxParticipants = formData.maxParticipants;
        if (formData.averageVisitMinutes)
          attractionData.averageVisitMinutes = formData.averageVisitMinutes;

        // Opening hours - store as JSON object
        attractionData.openingHoursJson = formData.openingHoursJson;

        // STEP 4: Attach uploaded URLs to attraction data
        if (uploadedThumbnailUrl) {
          attractionData.thumbnailUrl = uploadedThumbnailUrl;
        }
        if (uploadedImageUrls.length > 0) {
          attractionData.imageUrls = uploadedImageUrls;
        }

        // STEP 5: Create attraction with complete data (atomic DB operation)
        const createdAttraction = await createAttraction(attractionData);

        if (!createdAttraction.attractionId) {
          throw new Error("Attraction created but ID not returned");
        }

        navigate("/supplier/service/attraction");
        // Reload trang để map không bị loading
        setTimeout(() => window.location.reload(), 100);
      } catch (err) {
        console.error("❌ Error creating attraction:", err);
        
        // ROLLBACK: Delete uploaded images if attraction creation failed
        try {
          if (uploadedThumbnailUrl) {
            await deleteImage(uploadedThumbnailUrl);
          }
          if (uploadedImageUrls.length > 0) {
            await deleteMultipleImages(uploadedImageUrls);
          }
        } catch (rollbackErr) {
          console.error("❌ Rollback failed:", rollbackErr);
        }

        setErrors({
          general: err instanceof Error ? err.message : "Lỗi tạo điểm tham quan",
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
    updateOpeningHours,
    setThumbnailFile,
    setImageFiles,
    removeImageFile,
    validateForm,
    handleSubmit,
    resetForm,
  };
};
