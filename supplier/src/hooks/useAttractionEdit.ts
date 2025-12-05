import { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import type { AttractionDTO } from "../types";
import {
  getAttractionById,
  updateAttraction,
  uploadAttractionThumbnail,
  uploadAttractionImages,
  deleteAttractionImage,
} from "../services/attractionService";
import { getProviderByUserId } from "../services/providerService";

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

interface UseAttractionEditReturn {
  formData: AttractionFormData;
  errors: ValidationErrors;
  loading: boolean;
  submitting: boolean;
  attraction: AttractionDTO | null;
  providerId: number | null;
  thumbnailFile: File | null;
  imageFiles: File[];
  existingImages: string[];
  thumbnailPreview: string | null;
  imagePreviews: string[];
  updateField: <K extends keyof AttractionFormData>(
    field: K,
    value: AttractionFormData[K]
  ) => void;
  updateArrayField: (
    field: "visitTypesJson" | "availableTimesJson" | "suitableForJson" | "featuresJson" | "highlightsJson" | "badges",
    value: (number | string)[]
  ) => void;
  updateOpeningHours: (day: string, hours: string) => void;
  setThumbnailFile: (file: File | null) => void;
  setImageFiles: (files: File[]) => void;
  removeImageFile: (index: number) => void;
  removeExistingImage: (imageUrl: string) => void;
  validateForm: () => boolean;
  handleSubmit: (status?: AttractionStatus) => Promise<void>;
}

const toNumberArray = (arr: (string | number)[]): number[] =>
  arr
    .map((v) => (typeof v === "number" ? v : Number.parseInt(String(v), 10)))
    .filter((n) => !Number.isNaN(n));

export const useAttractionEdit = (
  attractionId: string | undefined
): UseAttractionEditReturn => {
  const navigate = useNavigate();
  const [attraction, setAttraction] = useState<AttractionDTO | null>(null);
  const [formData, setFormData] = useState<AttractionFormData>({
    title: "",
    areaId: null,
    price: 1,
    currencyCode: "VND",
    attractionType: "landmark",
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
    openingHoursJson: {},
    highlightsJson: [],
    badges: [],
    policiesText: "",
    tipsText: "",
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

  // Load attraction data
  useEffect(() => {
    (async () => {
      try {
        setLoading(true);

        if (!attractionId) {
          setErrors({ general: "Không tìm thấy ID địa điểm" });
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

        // Load attraction data
        const attractionData = await getAttractionById(Number(attractionId));

        // Check if user owns this attraction
        if (attractionData.providerId !== provider.providerId) {
          setErrors({ general: "Bạn không có quyền chỉnh sửa địa điểm này" });
          navigate("/supplier/service/attraction");
          return;
        }

        setAttraction(attractionData);

        // Populate form
        setFormData({
          title: attractionData.title || "",
          areaId: attractionData.areaId || null,
          price: attractionData.price || 1,
          currencyCode: attractionData.currencyCode || "VND",
          attractionType: attractionData.attractionType || "landmark",
          visibility: attractionData.visibility || "public_",
          isFeatured: attractionData.isFeatured || false,
          serviceDescription: attractionData.serviceDescription || "",
          location: attractionData.location || "",
          address: attractionData.address || "",
          latitude: attractionData.latitude ?? null,
          longitude: attractionData.longitude ?? null,
          startDate: attractionData.startDate || "",
          endDate: attractionData.endDate || "",
          capacity: attractionData.capacity || null,
          minParticipants: attractionData.minParticipants || null,
          maxParticipants: attractionData.maxParticipants || null,
          averageVisitMinutes: attractionData.averageVisitMinutes || null,
          visitTypesJson: attractionData.visitTypesJson || [],
          availableTimesJson: attractionData.availableTimesJson || [],
          suitableForJson: attractionData.suitableForJson || [],
          featuresJson: attractionData.featuresJson || [],
          openingHoursJson: attractionData.openingHoursJson || {},
          highlightsJson: attractionData.highlightsJson || [],
          badges: attractionData.badges || [],
          policiesText: attractionData.policiesText || "",
          tipsText: attractionData.tipsText || "",
          slug: attractionData.slug || "",
          seoTitle: attractionData.seoTitle || "",
          seoDescription: attractionData.seoDescription || "",
        });

        // Set existing images
        setExistingImages(attractionData.imageUrls || []);
        setThumbnailPreview(attractionData.thumbnailUrl || null);
      } catch (err) {
        console.error("Error loading attraction:", err);
        setErrors({
          general:
            err instanceof Error ? err.message : "Lỗi tải dữ liệu địa điểm",
        });
      } finally {
        setLoading(false);
      }
    })();
  }, [attractionId, navigate]);

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
      field: "visitTypesJson" | "availableTimesJson" | "suitableForJson" | "featuresJson" | "highlightsJson" | "badges",
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

  const updateOpeningHours = useCallback((day: string, hours: string) => {
    setFormData((prev) => ({
      ...prev,
      openingHoursJson: {
        ...prev.openingHoursJson,
        [day]: hours,
      },
    }));
  }, []);

  const removeImageFile = useCallback((index: number) => {
    setImageFiles((prev) => prev.filter((_, i) => i !== index));
  }, []);

  const removeExistingImage = useCallback(
    async (imageUrl: string) => {
      if (!attraction?.attractionId) return;

      try {
        await deleteAttractionImage(attraction.attractionId, imageUrl);
        setExistingImages((prev) => prev.filter((url) => url !== imageUrl));
      } catch (err) {
        console.error("Error deleting image:", err);
        setErrors({
          general: err instanceof Error ? err.message : "Lỗi xóa ảnh",
        });
      }
    },
    [attraction?.attractionId]
  );

  const validateForm = useCallback((): boolean => {
    const newErrors: ValidationErrors = {};

    // Required fields - Bắt buộc
    if (!formData.title.trim()) newErrors.title = "Tiêu đề là bắt buộc";
    if (!formData.areaId) newErrors.areaId = "Khu vực là bắt buộc";
    if (!formData.price || formData.price <= 0)
      newErrors.price = "Giá phải lớn hơn 0";
    if (!formData.attractionType)
      newErrors.attractionType = "Loại hình là bắt buộc";
    if (!formData.serviceDescription.trim())
      newErrors.serviceDescription = "Mô tả dịch vụ là bắt buộc";
    if (!formData.location.trim())
      newErrors.location = "Khu vực/địa phương là bắt buộc";
    if (!formData.address.trim()) newErrors.address = "Địa chỉ là bắt buộc";
    if (!formData.latitude || !formData.longitude)
      newErrors.address = "Vị trí bản đồ là bắt buộc";
    if (!formData.startDate) newErrors.startDate = "Ngày bắt đầu là bắt buộc";
    if (!formData.endDate) newErrors.endDate = "Ngày kết thúc là bắt buộc";
    if (!formData.capacity || formData.capacity <= 0)
      newErrors.capacity = "Sức chứa là bắt buộc";
    if (!formData.policiesText.trim())
      newErrors.policiesText = "Chính sách là bắt buộc";

    // Validation logic
    if (
      formData.averageVisitMinutes != null &&
      formData.averageVisitMinutes <= 0
    )
      newErrors.averageVisitMinutes = "Thời gian tham quan phải lớn hơn 0";

    if (
      formData.minParticipants &&
      formData.maxParticipants &&
      formData.minParticipants > formData.maxParticipants
    )
      newErrors.minParticipants =
        "Số lượng tối thiểu không được lớn hơn tối đa";

    if (
      formData.startDate &&
      formData.endDate &&
      new Date(formData.startDate) > new Date(formData.endDate)
    )
      newErrors.startDate = "Ngày bắt đầu không được sau ngày kết thúc";

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [formData]);

  const handleSubmit = useCallback(
    async (status: AttractionStatus = "published") => {
      // Ép attractionId vào biến riêng cho dễ quản lý
      const attractionId = attraction?.attractionId;

      if (!validateForm()) {
        setErrors((prev) => ({
          ...prev,
          general: "Vui lòng kiểm tra lại các trường bắt buộc",
        }));

        const shouldReload = window.confirm(
          "❌ Vui lòng điền đầy đủ các trường bắt buộc!\n\n" +
            "Bản đồ đang bị lỗi hiển thị. Bạn có muốn tải lại trang để tiếp tục không?\n\n" +
            "(Các thay đổi chưa lưu sẽ bị mất)"
        );
        if (shouldReload) window.location.reload();
        return;
      }

      if (!attractionId) {
        setErrors({ general: "Không tìm thấy thông tin địa điểm" });

        const shouldReload = window.confirm(
          "❌ Không tìm thấy thông tin địa điểm!\n\n" +
            "Bạn có muốn tải lại trang để thử lại không?"
        );
        if (shouldReload) window.location.reload();
        return;
      }

      if (!providerId) {
        setErrors({ general: "Không tìm thấy thông tin nhà cung cấp" });

        const shouldReload = window.confirm(
          "❌ Không tìm thấy thông tin nhà cung cấp!\n\n" +
            "Bạn có muốn tải lại trang để thử lại không?"
        );
        if (shouldReload) window.location.reload();
        return;
      }

      setSubmitting(true);
      setErrors({});

      try {
        const attractionData: Partial<AttractionDTO> = {
          providerId: providerId,
          areaId: formData.areaId!,
          title: formData.title,
          price: formData.price,
          currencyCode: formData.currencyCode,
          attractionType: formData.attractionType,
          visibility: formData.visibility,
          isFeatured: formData.isFeatured,
          attractionStatus: status,
          visitTypesJson:
            formData.visitTypesJson.length > 0 ? formData.visitTypesJson : [],
          availableTimesJson:
            formData.availableTimesJson.length > 0
              ? formData.availableTimesJson
              : [],
          suitableForJson:
            formData.suitableForJson.length > 0 ? formData.suitableForJson : [],
          featuresJson:
            formData.featuresJson.length > 0 ? formData.featuresJson : [],
          highlightsJson:
            formData.highlightsJson.length > 0 ? formData.highlightsJson : [],
          badges: formData.badges.length > 0 ? formData.badges : [],
          openingHoursJson:
            Object.keys(formData.openingHoursJson).length > 0
              ? formData.openingHoursJson
              : {},
        };

        if (formData.serviceDescription.trim())
          attractionData.serviceDescription = formData.serviceDescription.trim();
        if (formData.location.trim())
          attractionData.location = formData.location.trim();
        if (formData.address.trim())
          attractionData.address = formData.address.trim();
        if (formData.latitude != null) attractionData.latitude = formData.latitude;
        if (formData.longitude != null)
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

        // Không cần lưu biến updatedAttraction nếu không dùng
        await updateAttraction(Number(attractionId), attractionData);

        if (thumbnailFile) {
          await uploadAttractionThumbnail(Number(attractionId), thumbnailFile);
        }

        if (imageFiles.length > 0) {
          await uploadAttractionImages(Number(attractionId), imageFiles);
        }

        navigate("/supplier/service/attraction");
        window.location.reload();
      } catch (err) {
        console.error("❌ Error updating attraction:", err);
        setErrors({
          general:
            err instanceof Error ? err.message : "Lỗi cập nhật địa điểm",
        });
      } finally {
        setSubmitting(false);
      }
    },
    [
      formData,
      attraction?.attractionId,
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
    attraction,
    providerId,
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
  };
};
