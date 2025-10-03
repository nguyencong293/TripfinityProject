import { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import {
  getProviderByUserId,
  createProvider,
  uploadProviderLogo,
} from "../services/providerService";
import type { CreateProviderRequest } from "../types";

interface UseProviderInfoReturn {
  formData: CreateProviderRequest;
  loading: boolean;
  error: string;
  successMessage: string;
  showSuccessToast: boolean;
  logoFile: File | null;
  logoPreview: string | null;
  handleChange: (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => void;
  handleLogoChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  handleSubmit: (e: React.FormEvent) => Promise<void>;
  handleCancel: () => void;
}

export const useProviderInfo = (): UseProviderInfoReturn => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string>("");
  const [successMessage, setSuccessMessage] = useState<string>("");
  const [showSuccessToast, setShowSuccessToast] = useState(false);
  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [logoPreview, setLogoPreview] = useState<string | null>(null);

  const [formData, setFormData] = useState<CreateProviderRequest>({
    userId: 0,
    companyName: "",
    taxCode: "",
    address: "",
    contactEmail: "",
    contactPhone: "",
    bankAccountNumber: "",
    bankName: "",
    providerDescription: "",
  });

  const checkExistingProvider = useCallback(async () => {
    try {
      const userStr = localStorage.getItem("user");
      if (!userStr) {
        navigate("/supplier/login");
        return;
      }

      const user = JSON.parse(userStr);
      const userId = user.userId;

      setFormData((prev) => ({ ...prev, userId }));

      const provider = await getProviderByUserId(userId);
      if (provider) {
        // Nếu đã có provider, chuyển về trang chủ
        navigate("/supplier");
      }
    } catch (err) {
      console.error("Error checking provider:", err);
    }
  }, [navigate]);

  useEffect(() => {
    checkExistingProvider();
  }, [checkExistingProvider]);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    setError("");
  };

  const handleLogoChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      // Validate file size (10MB)
      if (file.size > 10 * 1024 * 1024) {
        setError("Kích thước file không được vượt quá 10MB");
        return;
      }

      // Validate file type
      if (!file.type.startsWith("image/")) {
        setError("Vui lòng chọn file ảnh");
        return;
      }

      setLogoFile(file);
      setError("");

      // Create preview
      const reader = new FileReader();
      reader.onloadend = () => {
        setLogoPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const validateForm = (): boolean => {
    if (!formData.companyName.trim()) {
      setError("Vui lòng nhập tên công ty");
      return false;
    }
    if (!formData.taxCode.trim()) {
      setError("Vui lòng nhập mã số thuế");
      return false;
    }
    if (!formData.address.trim()) {
      setError("Vui lòng nhập địa chỉ");
      return false;
    }
    if (!formData.contactEmail.trim()) {
      setError("Vui lòng nhập email liên hệ");
      return false;
    }
    if (!formData.contactPhone.trim()) {
      setError("Vui lòng nhập số điện thoại");
      return false;
    }
    return true;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!validateForm()) {
      return;
    }

    setLoading(true);

    try {
      // Tạo provider trước
      const result = await createProvider(formData);
      if (result.success && result.data) {
        const providerId = result.data.providerId;

        // Nếu có logo, upload logo
        if (logoFile && providerId) {
          try {
            await uploadProviderLogo(providerId, logoFile);
          } catch (logoError) {
            console.error("Error uploading logo:", logoError);
            // Không dừng quá trình, chỉ log lỗi
          }
        }

        setSuccessMessage("Tạo hồ sơ nhà cung cấp thành công!");
        setShowSuccessToast(true);
        setTimeout(() => {
          setShowSuccessToast(false);
          navigate("/supplier");
        }, 2000);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Đã có lỗi xảy ra");
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = () => {
    navigate("/supplier/login");
  };

  return {
    formData,
    loading,
    error,
    successMessage,
    showSuccessToast,
    logoFile,
    logoPreview,
    handleChange,
    handleLogoChange,
    handleSubmit,
    handleCancel,
  };
};
