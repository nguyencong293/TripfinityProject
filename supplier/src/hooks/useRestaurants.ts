import { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import type { RestaurantDTO } from "../types";
import {
  getRestaurantsByProvider,
  createRestaurant,
  getRestaurantById,
  updateRestaurant,
} from "../services/restaurantService";
import {
  uploadSingleImage,
  uploadMultipleImages,
  deleteImage,
} from "../services/uploadService";
import { getProviderByUserId } from "../services/providerService";

// Price constraint
const MAX_PRICE = 1000000000; // 1,000,000,000 VND

/* ============================================
 * LIST + FILTER HOOK
 * ============================================ */

interface RestaurantFilters {
  search: string;
  area: string;
  priceLevel: string;
  status: string;
  priceMin?: number;
  priceMax?: number;
  visibility: string;
  cuisine: string;
}

interface UseRestaurantsReturn {
  restaurants: RestaurantDTO[];
  filteredRestaurants: RestaurantDTO[];
  loading: boolean;
  error: string | null;
  providerId: number | null;
  filters: RestaurantFilters;
  setFilters: React.Dispatch<React.SetStateAction<RestaurantFilters>>;
  refetch: () => Promise<void>;
  clearFilters: () => void;
}

export const useRestaurants = (): UseRestaurantsReturn => {
  const [restaurants, setRestaurants] = useState<RestaurantDTO[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [providerId, setProviderId] = useState<number | null>(null);
  const [filters, setFilters] = useState<RestaurantFilters>({
    search: "",
    area: "",
    priceLevel: "",
    status: "",
    priceMin: undefined,
    priceMax: undefined,
    visibility: "",
    cuisine: "",
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

  const fetchRestaurants = useCallback(async () => {
    if (!providerId) return;
    try {
      setLoading(true);
      setError(null);
      const data = await getRestaurantsByProvider(providerId);
      setRestaurants(data);
    } catch (err) {
      console.error("Error fetching restaurants:", err);
      setError(err instanceof Error ? err.message : "Failed to fetch restaurants");
    } finally {
      setLoading(false);
    }
  }, [providerId]);

  const refetch = useCallback(async () => {
    await fetchRestaurants();
  }, [fetchRestaurants]);

  useEffect(() => {
    (async () => {
      await fetchProviderId();
    })();
  }, [fetchProviderId]);

  useEffect(() => {
    if (providerId) {
      fetchRestaurants();
    }
  }, [providerId, fetchRestaurants]);

  const filteredRestaurants = restaurants.filter((restaurant) => {
    if (filters.search) {
      const searchLower = filters.search.toLowerCase();
      const matchesTitle = restaurant.title?.toLowerCase().includes(searchLower);
      const matchesSlug = restaurant.slug?.toLowerCase().includes(searchLower);
      const matchesId = restaurant.restaurantId?.toString().includes(searchLower);
      if (!matchesTitle && !matchesSlug && !matchesId) return false;
    }

    if (filters.area && restaurant.location) {
      if (!restaurant.location.includes(filters.area)) return false;
    }

    if (filters.priceLevel && restaurant.priceLevel !== filters.priceLevel) {
      return false;
    }

    if (filters.status && restaurant.restaurantStatus !== filters.status) {
      return false;
    }

    if (filters.priceMin && restaurant.price < filters.priceMin) return false;
    if (filters.priceMax && restaurant.price > filters.priceMax) return false;

    if (filters.visibility && restaurant.visibility !== filters.visibility) {
      return false;
    }

    if (filters.cuisine && restaurant.cuisinesJson) {
      if (!restaurant.cuisinesJson.includes(filters.cuisine)) {
        return false;
      }
    }

    return true;
  });

  const clearFilters = useCallback(() => {
    setFilters({
      search: "",
      area: "",
      priceLevel: "",
      status: "",
      priceMin: undefined,
      priceMax: undefined,
      visibility: "",
      cuisine: "",
    });
  }, []);

  return {
    restaurants,
    filteredRestaurants,
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

type PriceLevel = NonNullable<RestaurantDTO["priceLevel"]>;
type Visibility = NonNullable<RestaurantDTO["visibility"]>;
type RestaurantStatus = RestaurantDTO["restaurantStatus"];

interface RestaurantFormData {
  title: string;
  areaId: number | null;
  price: number;
  currencyCode: string;
  priceLevel: PriceLevel | "";
  visibility: Visibility;
  isFeatured: boolean;
  serviceDescription: string;
  location: string;
  address: string;
  latitude?: number | null;
  longitude?: number | null;
  phone: string;
  website: string;
  startDate: string;
  endDate: string;
  capacity: number | null;
  minParticipants: number | null;
  maxParticipants: number | null;
  cuisinesJson: string[];
  servicesJson: string[];
  dietsJson: string[];
  openingHoursJson: { [key: string]: string };
  menuHighlightsJson: string[];
  ambianceTagsJson: string[];
  paymentMethodsJson: string[];
  badges: string[];
  policiesText: string;
  slug: string;
  seoTitle: string;
  seoDescription: string;
}

interface ValidationErrors {
  [key: string]: string;
}

interface UseRestaurantCreateReturn {
  formData: RestaurantFormData;
  errors: ValidationErrors;
  loading: boolean;
  submitting: boolean;
  providerId: number | null;
  thumbnailFile: File | null;
  imageFiles: File[];
  thumbnailPreview: string | null;
  imagePreviews: string[];
  updateField: <K extends keyof RestaurantFormData>(
    field: K,
    value: RestaurantFormData[K]
  ) => void;
  updateArrayField: (
    field: "menuHighlightsJson" | "ambianceTagsJson" | "paymentMethodsJson" | "badges" | "cuisinesJson" | "servicesJson" | "dietsJson",
    value: string[]
  ) => void;
  updateOpeningHours: (day: string, value: string) => void;
  setThumbnailFile: (file: File | null) => void;
  setImageFiles: (files: File[]) => void;
  removeImageFile: (index: number) => void;
  validateForm: () => boolean;
  handleSubmit: (status?: RestaurantStatus) => Promise<void>;
  resetForm: () => void;
}

const initialFormData: RestaurantFormData = {
  title: "",
  areaId: null,
  price: 1,
  currencyCode: "VND",
  priceLevel: "",
  visibility: "public_",
  isFeatured: false,
  serviceDescription: "",
  location: "",
  address: "",
  latitude: null,
  longitude: null,
  phone: "",
  website: "",
  startDate: "",
  endDate: "",
  capacity: null,
  minParticipants: null,
  maxParticipants: null,
  cuisinesJson: [],
  servicesJson: [],
  dietsJson: [],
  openingHoursJson: {
    monday: "",
    tuesday: "",
    wednesday: "",
    thursday: "",
    friday: "",
    saturday: "",
    sunday: "",
  },
  menuHighlightsJson: [],
  ambianceTagsJson: [],
  paymentMethodsJson: [],
  badges: [],
  policiesText: "",
  slug: "",
  seoTitle: "",
  seoDescription: "",
};

export const useRestaurantCreate = (): UseRestaurantCreateReturn => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState<RestaurantFormData>(initialFormData);
  const [errors, setErrors] = useState<ValidationErrors>({});
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [providerId, setProviderId] = useState<number | null>(null);
  const [thumbnailFile, setThumbnailFile] = useState<File | null>(null);
  const [imageFiles, setImageFiles] = useState<File[]>([]);
  const [thumbnailPreview, setThumbnailPreview] = useState<string | null>(null);
  const [imagePreviews, setImagePreviews] = useState<string[]>([]);

  // Fetch provider ID
  useEffect(() => {
    const fetchProvider = async () => {
      try {
        const userStr = localStorage.getItem("user");
        if (!userStr) {
          setErrors({ general: "Không tìm thấy thông tin người dùng" });
          setLoading(false);
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
        console.error("Error fetching provider:", err);
        setErrors({ general: "Lỗi khi lấy thông tin nhà cung cấp" });
      } finally {
        setLoading(false);
      }
    };
    fetchProvider();
  }, []);

  // Handle thumbnail preview
  useEffect(() => {
    if (thumbnailFile) {
      const objectUrl = URL.createObjectURL(thumbnailFile);
      setThumbnailPreview(objectUrl);
      return () => URL.revokeObjectURL(objectUrl);
    } else {
      setThumbnailPreview(null);
    }
  }, [thumbnailFile]);

  // Handle image previews
  useEffect(() => {
    if (imageFiles.length > 0) {
      const objectUrls = imageFiles.map((file) => URL.createObjectURL(file));
      setImagePreviews(objectUrls);
      return () => objectUrls.forEach((url) => URL.revokeObjectURL(url));
    } else {
      setImagePreviews([]);
    }
  }, [imageFiles]);

  const updateField = useCallback(
    <K extends keyof RestaurantFormData>(
      field: K,
      value: RestaurantFormData[K]
    ) => {
      setFormData((prev) => ({ ...prev, [field]: value }));
      if (errors[field]) {
        setErrors((prev) => {
          const newErrors = { ...prev };
          delete newErrors[field];
          return newErrors;
        });
      }
    },
    [errors]
  );

  const updateArrayField = useCallback(
    (
      field: "menuHighlightsJson" | "ambianceTagsJson" | "paymentMethodsJson" | "badges" | "cuisinesJson" | "servicesJson" | "dietsJson",
      value: string[]
    ) => {
      setFormData((prev) => ({ ...prev, [field]: value }));
      if (errors[field]) {
        setErrors((prev) => {
          const newErrors = { ...prev };
          delete newErrors[field];
          return newErrors;
        });
      }
    },
    [errors]
  );

  const updateOpeningHours = useCallback((day: string, value: string) => {
    setFormData((prev) => ({
      ...prev,
      openingHoursJson: { ...prev.openingHoursJson, [day]: value },
    }));
  }, []);

  const removeImageFile = useCallback((index: number) => {
    setImageFiles((prev) => prev.filter((_, i) => i !== index));
  }, []);

  const validateForm = useCallback((): boolean => {
    const newErrors: ValidationErrors = {};

    if (!formData.title.trim()) {
      newErrors.title = "Tên nhà hàng là bắt buộc";
    }
    if (!formData.areaId) {
      newErrors.areaId = "Khu vực là bắt buộc";
    }
    if (formData.price <= 0) {
      newErrors.price = "Giá phải lớn hơn 0";
    }
    if (!formData.address.trim()) {
      newErrors.address = "Địa chỉ là bắt buộc";
    }
    if (!formData.slug.trim()) {
      newErrors.slug = "Slug là bắt buộc";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [formData]);

  const handleSubmit = useCallback(
    async (status: RestaurantStatus = "published") => {
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
        setErrors({ general: "Không tìm thấy Provider ID" });
        return;
      }

      setSubmitting(true);
      setErrors({});

      try {
        // Step 1: Upload thumbnail first (if exists)
        let thumbnailUrl = "";
        if (thumbnailFile) {
          const uploadedUrl = await uploadSingleImage(thumbnailFile);
          thumbnailUrl = uploadedUrl;
        }

        // Step 2: Upload gallery images (if any)
        let imageUrls: string[] = [];
        if (imageFiles.length > 0) {
          imageUrls = await uploadMultipleImages(imageFiles);
        }

        // Step 3: Create restaurant
        const createPayload: Partial<RestaurantDTO> = {
          providerId: providerId!,
          areaId: formData.areaId!,
          title: formData.title.trim(),
          serviceDescription: formData.serviceDescription.trim() || undefined,
          location: formData.location.trim() || undefined,
          address: formData.address.trim(),
          latitude: formData.latitude || undefined,
          longitude: formData.longitude || undefined,
          phone: formData.phone.trim() || undefined,
          website: formData.website.trim() || undefined,
          startDate: formData.startDate || undefined,
          endDate: formData.endDate || undefined,
          price: formData.price,
          currencyCode: formData.currencyCode,
          priceLevel: formData.priceLevel || undefined,
          capacity: formData.capacity || undefined,
          minParticipants: formData.minParticipants || undefined,
          maxParticipants: formData.maxParticipants || undefined,
          thumbnailUrl: thumbnailUrl || undefined,
          imageUrls: imageUrls.length > 0 ? imageUrls : undefined,
          ratingAverage: 0,
          badges: formData.badges.length > 0 ? formData.badges : undefined,
          restaurantStatus: status,
          visibility: formData.visibility,
          isFeatured: formData.isFeatured,
          cuisinesJson: formData.cuisinesJson.length > 0 ? formData.cuisinesJson : undefined,
          servicesJson: formData.servicesJson.length > 0 ? formData.servicesJson : undefined,
          dietsJson: formData.dietsJson.length > 0 ? formData.dietsJson : undefined,
          openingHoursJson: formData.openingHoursJson,
          menuHighlightsJson: formData.menuHighlightsJson.length > 0 ? formData.menuHighlightsJson : undefined,
          ambianceTagsJson: formData.ambianceTagsJson.length > 0 ? formData.ambianceTagsJson : undefined,
          paymentMethodsJson: formData.paymentMethodsJson.length > 0 ? formData.paymentMethodsJson : undefined,
          policiesText: formData.policiesText.trim() || undefined,
          slug: formData.slug.trim(),
          seoTitle: formData.seoTitle.trim() || undefined,
          seoDescription: formData.seoDescription.trim() || undefined,
        };

        console.log("🚀 Creating restaurant with payload:", createPayload);
        await createRestaurant(createPayload);

        // Success: navigate back to dashboard
        navigate("/supplier/service/restaurant");
        // Reload trang để map không bị loading
        setTimeout(() => window.location.reload(), 100);
      } catch (err) {
        console.error("Error creating restaurant:", err);
        setErrors({
          general:
            err instanceof Error
              ? err.message
              : "Đã xảy ra lỗi khi tạo nhà hàng",
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

/* ============================================
 * EDIT HOOK
 * ============================================ */

interface UseRestaurantEditReturn extends Omit<UseRestaurantCreateReturn, "resetForm"> {
  restaurant: RestaurantDTO | null;
  existingImages: string[];
  loadRestaurant: (restaurantId: number) => Promise<void>;
  removeExistingImage: (index: number) => Promise<void>;
}

export const useRestaurantEdit = (restaurantIdParam?: string): UseRestaurantEditReturn => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState<RestaurantFormData>(initialFormData);
  const [errors, setErrors] = useState<ValidationErrors>({});
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [providerId, setProviderId] = useState<number | null>(null);
  const [restaurant, setRestaurant] = useState<RestaurantDTO | null>(null);
  const [thumbnailFile, setThumbnailFile] = useState<File | null>(null);
  const [imageFiles, setImageFiles] = useState<File[]>([]);
  const [existingImages, setExistingImages] = useState<string[]>([]);
  const [thumbnailPreview, setThumbnailPreview] = useState<string | null>(null);
  const [imagePreviews, setImagePreviews] = useState<string[]>([]);

  // Fetch provider ID
  useEffect(() => {
    const fetchProvider = async () => {
      try {
        const userStr = localStorage.getItem("user");
        if (!userStr) {
          setErrors({ general: "Không tìm thấy thông tin người dùng" });
          setLoading(false);
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
        console.error("Error fetching provider:", err);
        setErrors({ general: "Lỗi khi lấy thông tin nhà cung cấp" });
      } finally {
        setLoading(false);
      }
    };
    fetchProvider();
  }, []);

  // Auto-load restaurant if ID provided
  useEffect(() => {
    if (restaurantIdParam) {
      loadRestaurant(Number(restaurantIdParam));
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [restaurantIdParam]);

  // Handle thumbnail preview
  useEffect(() => {
    if (thumbnailFile) {
      const objectUrl = URL.createObjectURL(thumbnailFile);
      setThumbnailPreview(objectUrl);
      return () => URL.revokeObjectURL(objectUrl);
    } else if (restaurant?.thumbnailUrl) {
      setThumbnailPreview(restaurant.thumbnailUrl);
    } else {
      setThumbnailPreview(null);
    }
  }, [thumbnailFile, restaurant?.thumbnailUrl]);

  // Handle image previews
  useEffect(() => {
    if (imageFiles.length > 0) {
      const objectUrls = imageFiles.map((file) => URL.createObjectURL(file));
      setImagePreviews(objectUrls);
      return () => objectUrls.forEach((url) => URL.revokeObjectURL(url));
    } else {
      setImagePreviews([]);
    }
  }, [imageFiles]);

  const loadRestaurant = useCallback(async (restaurantId: number) => {
    setLoading(true);
    try {
      const data = await getRestaurantById(restaurantId);
      setRestaurant(data);

      // Populate form
      setFormData({
        title: data.title || "",
        areaId: data.areaId || null,
        price: data.price || 1,
        currencyCode: data.currencyCode || "VND",
        priceLevel: data.priceLevel || "",
        visibility: data.visibility || "public_",
        isFeatured: data.isFeatured || false,
        serviceDescription: data.serviceDescription || "",
        location: data.location || "",
        address: data.address || "",
        latitude: data.latitude || null,
        longitude: data.longitude || null,
        phone: data.phone || "",
        website: data.website || "",
        startDate: data.startDate || "",
        endDate: data.endDate || "",
        capacity: data.capacity || null,
        minParticipants: data.minParticipants || null,
        maxParticipants: data.maxParticipants || null,
        cuisinesJson: data.cuisinesJson || [],
        servicesJson: data.servicesJson || [],
        dietsJson: data.dietsJson || [],
        openingHoursJson: (data.openingHoursJson as { [key: string]: string }) || {
          monday: "",
          tuesday: "",
          wednesday: "",
          thursday: "",
          friday: "",
          saturday: "",
          sunday: "",
        },
        menuHighlightsJson: data.menuHighlightsJson || [],
        ambianceTagsJson: data.ambianceTagsJson || [],
        paymentMethodsJson: data.paymentMethodsJson || [],
        badges: data.badges || [],
        policiesText: data.policiesText || "",
        slug: data.slug || "",
        seoTitle: data.seoTitle || "",
        seoDescription: data.seoDescription || "",
      });

      setExistingImages(data.imageUrls || []);
    } catch (err) {
      console.error("Error loading restaurant:", err);
      setErrors({ general: "Lỗi khi tải thông tin nhà hàng" });
    } finally {
      setLoading(false);
    }
  }, []);

  const updateField = useCallback(
    <K extends keyof RestaurantFormData>(
      field: K,
      value: RestaurantFormData[K]
    ) => {
      setFormData((prev) => ({ ...prev, [field]: value }));
      if (errors[field]) {
        setErrors((prev) => {
          const newErrors = { ...prev };
          delete newErrors[field];
          return newErrors;
        });
      }
    },
    [errors]
  );

  const updateArrayField = useCallback(
    (
      field: "menuHighlightsJson" | "ambianceTagsJson" | "paymentMethodsJson" | "badges" | "cuisinesJson" | "servicesJson" | "dietsJson",
      value: string[]
    ) => {
      setFormData((prev) => ({ ...prev, [field]: value }));
      if (errors[field]) {
        setErrors((prev) => {
          const newErrors = { ...prev };
          delete newErrors[field];
          return newErrors;
        });
      }
    },
    [errors]
  );

  const updateOpeningHours = useCallback((day: string, value: string) => {
    setFormData((prev) => ({
      ...prev,
      openingHoursJson: { ...prev.openingHoursJson, [day]: value },
    }));
  }, []);

  const removeImageFile = useCallback((index: number) => {
    setImageFiles((prev) => prev.filter((_, i) => i !== index));
  }, []);

  const removeExistingImage = useCallback(
    async (index: number) => {
      if (!restaurant?.restaurantId) return;

      const imageUrl = existingImages[index];
      try {
        // Delete from server
        await deleteImage(imageUrl);

        // Update state
        setExistingImages((prev) => prev.filter((_, i) => i !== index));
      } catch (err) {
        console.error("Error deleting image:", err);
        setErrors((prev) => ({
          ...prev,
          general: "Lỗi khi xóa ảnh",
        }));
      }
    },
    [restaurant?.restaurantId, existingImages]
  );

  const validateForm = useCallback((): boolean => {
    const newErrors: ValidationErrors = {};

    if (!formData.title.trim()) {
      newErrors.title = "Tên nhà hàng là bắt buộc";
    }
    if (!formData.areaId) {
      newErrors.areaId = "Khu vực là bắt buộc";
    }
    if (formData.price <= 0) {
      newErrors.price = "Giá phải lớn hơn 0";
    }
    if (formData.price > MAX_PRICE) {
      newErrors.price = `Giá không được vượt quá ${MAX_PRICE.toLocaleString()} VND`;
    }
    if (!formData.address.trim()) {
      newErrors.address = "Địa chỉ là bắt buộc";
    }
    if (!formData.slug.trim()) {
      newErrors.slug = "Slug là bắt buộc";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [formData]);

  const handleSubmit = useCallback(
    async (status: RestaurantStatus = "published") => {
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

      if (!restaurant) {
        setErrors({ general: "Không tìm thấy Provider ID" });
        return;
      }

      if (!restaurant?.restaurantId) {
        setErrors({ general: "Không tìm thấy Restaurant ID" });
        return;
      }

      setSubmitting(true);
      setErrors({});

      try {
        // Step 1: Upload new thumbnail if changed
        let thumbnailUrl = restaurant.thumbnailUrl || "";
        if (thumbnailFile) {
          // Delete old thumbnail if exists
          if (thumbnailUrl) {
            try {
              await deleteImage(thumbnailUrl);
            } catch (err) {
              console.warn("Failed to delete old thumbnail:", err);
            }
          }
          thumbnailUrl = await uploadSingleImage(thumbnailFile);
        }

        // Step 2: Upload new gallery images
        let newImageUrls: string[] = [];
        if (imageFiles.length > 0) {
          newImageUrls = await uploadMultipleImages(imageFiles);
        }

        // Combine existing + new images
        const allImageUrls = [...existingImages, ...newImageUrls];

        // Step 3: Update restaurant
        const updatePayload: Partial<RestaurantDTO> = {
          providerId: restaurant.providerId,
          title: formData.title.trim(),
          areaId: formData.areaId!,
          serviceDescription: formData.serviceDescription.trim() || undefined,
          location: formData.location.trim() || undefined,
          address: formData.address.trim(),
          latitude: formData.latitude || undefined,
          longitude: formData.longitude || undefined,
          phone: formData.phone.trim() || undefined,
          website: formData.website.trim() || undefined,
          startDate: formData.startDate || undefined,
          endDate: formData.endDate || undefined,
          price: formData.price,
          currencyCode: formData.currencyCode,
          priceLevel: formData.priceLevel || undefined,
          capacity: formData.capacity || undefined,
          minParticipants: formData.minParticipants || undefined,
          maxParticipants: formData.maxParticipants || undefined,
          thumbnailUrl: thumbnailUrl || undefined,
          imageUrls: allImageUrls.length > 0 ? allImageUrls : undefined,
          badges: formData.badges.length > 0 ? formData.badges : undefined,
          restaurantStatus: status,
          visibility: formData.visibility,
          isFeatured: formData.isFeatured,
          cuisinesJson: formData.cuisinesJson.length > 0 ? formData.cuisinesJson : undefined,
          servicesJson: formData.servicesJson.length > 0 ? formData.servicesJson : undefined,
          dietsJson: formData.dietsJson.length > 0 ? formData.dietsJson : undefined,
          openingHoursJson: formData.openingHoursJson,
          menuHighlightsJson: formData.menuHighlightsJson.length > 0 ? formData.menuHighlightsJson : undefined,
          ambianceTagsJson: formData.ambianceTagsJson.length > 0 ? formData.ambianceTagsJson : undefined,
          paymentMethodsJson: formData.paymentMethodsJson.length > 0 ? formData.paymentMethodsJson : undefined,
          policiesText: formData.policiesText.trim() || undefined,
          slug: formData.slug.trim(),
          seoTitle: formData.seoTitle.trim() || undefined,
          seoDescription: formData.seoDescription.trim() || undefined,
        };

        await updateRestaurant(restaurant.restaurantId, updatePayload);

        // Success: navigate back
        navigate("/supplier/service/restaurant");
        // Reload trang để map không bị loading
        setTimeout(() => window.location.reload(), 100);
      } catch (err) {
        console.error("Error updating restaurant:", err);
        setErrors({
          general:
            err instanceof Error
              ? err.message
              : "Đã xảy ra lỗi khi cập nhật nhà hàng",
        });
      } finally {
        setSubmitting(false);
      }
    },
    [
      formData,
      restaurant,
      thumbnailFile,
      imageFiles,
      existingImages,
      validateForm,
      navigate,
    ]
  );

  return {
    formData,
    errors,
    loading,
    submitting,
    providerId,
    restaurant,
    thumbnailFile,
    imageFiles,
    existingImages,
    thumbnailPreview,
    imagePreviews,
    updateField,
    updateArrayField,
    updateOpeningHours,
    setThumbnailFile,
    setImageFiles,
    removeImageFile,
    removeExistingImage,
    validateForm,
    handleSubmit,
    loadRestaurant,
  };
};
