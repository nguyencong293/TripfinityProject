import { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import type { HotelDTO } from "../types";
import {
  getHotelById,
  updateHotel,
  uploadHotelThumbnail,
  uploadHotelImages,
  deleteHotelImage,
} from "../services/hotelService";
import { getProviderByUserId } from "../services/providerService";

type PropertyType = NonNullable<HotelDTO["propertyType"]>;
type Visibility = NonNullable<HotelDTO["visibility"]>;
type HotelStatus = HotelDTO["hotelStatus"];

interface HotelFormData {
  title: string;
  areaId: number | null;
  price: number;
  pricePerNight?: number | null;
  currencyCode: string;
  propertyType: PropertyType;
  visibility: Visibility;
  isFeatured: boolean;
  serviceDescription: string;
  location: string;
  address: string;
  startDate: string;
  endDate: string;
  capacity: number | null;
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

interface UseHotelEditReturn {
  formData: HotelFormData;
  errors: ValidationErrors;
  loading: boolean;
  submitting: boolean;
  hotel: HotelDTO | null;
  providerId: number | null;
  thumbnailFile: File | null;
  imageFiles: File[];
  existingImages: string[];
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
  removeExistingImage: (imageUrl: string) => void;
  validateForm: () => boolean;
  handleSubmit: (status?: HotelStatus) => Promise<void>;
}

const toNumberArray = (arr: (string | number)[]): number[] =>
  arr
    .map((v) => (typeof v === "number" ? v : Number.parseInt(String(v), 10)))
    .filter((n) => !Number.isNaN(n));

export const useHotelEdit = (
  hotelId: string | undefined
): UseHotelEditReturn => {
  const navigate = useNavigate();
  const [hotel, setHotel] = useState<HotelDTO | null>(null);
  const [formData, setFormData] = useState<HotelFormData>({
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
    startDate: "",
    endDate: "",
    capacity: null,
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
  });
  const [errors, setErrors] = useState<ValidationErrors>({});
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [providerId, setProviderId] = useState<number | null>(null);
  const [thumbnailFile, setThumbnailFile] = useState<File | null>(null);
  const [imageFiles, setImageFiles] = useState<File[]>([]);
  const [existingImages, setExistingImages] = useState<string[]>([]);
  const [thumbnailPreview, setThumbnailPreview] = useState<string | null>(null);
  const [imagePreviews, setImagePreviews] = useState<string[]>([]);

  // Load hotel data
  useEffect(() => {
    (async () => {
      try {
        setLoading(true);

        if (!hotelId) {
          setErrors({ general: "Không tìm thấy ID khách sạn" });
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
          setErrors({ general: "Không tìm thấy thông tin nhà cung cấp" });
          return;
        }

        setProviderId(provider.providerId);

        // Load hotel data
        const hotelData = await getHotelById(Number(hotelId));

        // Check if user owns this hotel
        if (hotelData.providerId !== provider.providerId) {
          setErrors({ general: "Bạn không có quyền chỉnh sửa khách sạn này" });
          navigate("/supplier/service/hotel");
          return;
        }

        setHotel(hotelData);

        // Populate form
        setFormData({
          title: hotelData.title || "",
          areaId: hotelData.areaId || null,
          price: hotelData.price || 1,
          pricePerNight: hotelData.pricePerNight ?? null,
          currencyCode: hotelData.currencyCode || "VND",
          propertyType: hotelData.propertyType || "hotel",
          visibility: hotelData.visibility || "public_",
          isFeatured: hotelData.isFeatured || false,
          serviceDescription: hotelData.serviceDescription || "",
          location: hotelData.location || "",
          address: hotelData.address || "",
          startDate: hotelData.startDate || "",
          endDate: hotelData.endDate || "",
          capacity: hotelData.capacity || null,
          minParticipants: hotelData.minParticipants || null,
          maxParticipants: hotelData.maxParticipants || null,
          starRating: hotelData.starRating || null,
          checkinTime: hotelData.checkinTime || "",
          checkoutTime: hotelData.checkoutTime || "",
          highlightsJson: hotelData.highlightsJson || [],
          amenitiesJson: hotelData.amenitiesJson || [],
          badges: hotelData.badges || [],
          policiesText: hotelData.policiesText || "",
          slug: hotelData.slug || "",
          seoTitle: hotelData.seoTitle || "",
          seoDescription: hotelData.seoDescription || "",
        });

        // Set existing images
        setExistingImages(hotelData.imageUrls || []);
        setThumbnailPreview(hotelData.thumbnailUrl || null);
      } catch (err) {
        console.error("Error loading hotel:", err);
        setErrors({
          general:
            err instanceof Error ? err.message : "Lỗi tải dữ liệu khách sạn",
        });
      } finally {
        setLoading(false);
      }
    })();
  }, [hotelId, navigate]);

  // Preview for new thumbnail
  useEffect(() => {
    if (thumbnailFile) {
      const url = URL.createObjectURL(thumbnailFile);
      setThumbnailPreview(url);
      return () => URL.revokeObjectURL(url);
    }
  }, [thumbnailFile]);

  // Preview for new images
  useEffect(() => {
    const urls = imageFiles.map((file) => URL.createObjectURL(file));
    setImagePreviews(urls);
    return () => urls.forEach((url) => URL.revokeObjectURL(url));
  }, [imageFiles]);

  const updateField = useCallback(
    <K extends keyof HotelFormData>(field: K, value: HotelFormData[K]) => {
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

  const removeExistingImage = useCallback(
    async (imageUrl: string) => {
      if (!hotel?.hotelId) return;

      try {
        await deleteHotelImage(hotel.hotelId, imageUrl);
        setExistingImages((prev) => prev.filter((url) => url !== imageUrl));
      } catch (err) {
        console.error("Error deleting image:", err);
        setErrors({
          general: err instanceof Error ? err.message : "Lỗi xóa ảnh",
        });
      }
    },
    [hotel?.hotelId]
  );

  const validateForm = useCallback((): boolean => {
    const newErrors: ValidationErrors = {};

    if (!formData.title.trim()) newErrors.title = "Tiêu đề là bắt buộc";
    if (!formData.areaId) newErrors.areaId = "Khu vực là bắt buộc";
    if (!formData.price || formData.price <= 0)
      newErrors.price = "Giá phải lớn hơn 0";
    if (formData.pricePerNight != null && formData.pricePerNight < 0)
      newErrors.pricePerNight = "Giá mỗi đêm không hợp lệ";

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
        return;
      }

      if (!hotel?.hotelId) {
        setErrors({ general: "Không tìm thấy thông tin khách sạn" });
        return;
      }

      // ✅ FIX: Kiểm tra providerId trước khi submit
      if (!providerId) {
        setErrors({ general: "Không tìm thấy thông tin nhà cung cấp" });
        return;
      }

      setSubmitting(true);
      setErrors({});

      try {
        console.log("🔍 Update payload - providerId:", providerId);

        // ✅ FIX: Thêm providerId vào payload
        const hotelData: Partial<HotelDTO> = {
          providerId: providerId, // ✅ BẮT BUỘC
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
        if (formData.minParticipants)
          hotelData.minParticipants = formData.minParticipants;
        if (formData.maxParticipants)
          hotelData.maxParticipants = formData.maxParticipants;
        if (formData.starRating) hotelData.starRating = formData.starRating;

        if (formData.checkinTime) hotelData.checkinTime = formData.checkinTime;
        if (formData.checkoutTime)
          hotelData.checkoutTime = formData.checkoutTime;

        console.log("🔍 Final update payload:", hotelData);

        const updatedHotel = await updateHotel(hotel.hotelId, hotelData);
        console.log("✅ Hotel updated:", updatedHotel);

        // Upload new thumbnail if provided
        if (thumbnailFile) {
          console.log("📸 Uploading new thumbnail...");
          await uploadHotelThumbnail(hotel.hotelId, thumbnailFile);
        }

        // Upload new images if provided
        if (imageFiles.length > 0) {
          console.log("🖼️ Uploading", imageFiles.length, "new images...");
          await uploadHotelImages(hotel.hotelId, imageFiles);
        }

        console.log("🎉 Hotel update completed successfully!");
        navigate("/supplier/service/hotel");
      } catch (err) {
        console.error("❌ Error updating hotel:", err);
        setErrors({
          general:
            err instanceof Error ? err.message : "Lỗi cập nhật khách sạn",
        });
      } finally {
        setSubmitting(false);
      }
    },
    [
      formData,
      hotel?.hotelId,
      providerId,
      thumbnailFile,
      imageFiles,
      validateForm,
      navigate,
    ]
  );

  return {
    formData,
    errors,
    loading,
    submitting,
    hotel,
    providerId,
    thumbnailFile,
    imageFiles,
    existingImages,
    thumbnailPreview,
    imagePreviews,
    updateField,
    updateArrayField,
    setThumbnailFile,
    setImageFiles,
    removeImageFile,
    removeExistingImage,
    validateForm,
    handleSubmit,
  };
};
