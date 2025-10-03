import { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import {
  getProviderByUserId,
  updateProvider,
  uploadProviderLogo,
  deleteProviderLogo,
} from "../services/providerService";
import {
  getUserById,
  updateUser,
  uploadUserAvatar,
  deleteUserAvatar,
} from "../services/providerService";
import type { ProviderDTO, UserDTO } from "../types";

interface UseProfileProviderReturn {
  provider: ProviderDTO | null;
  user: UserDTO | null;
  loading: boolean;
  error: string;
  successMessage: string;
  showSuccessToast: boolean;
  isEditingProvider: boolean;
  isEditingUser: boolean;
  showUserModal: boolean;
  providerForm: Partial<ProviderDTO>;
  userForm: Partial<UserDTO>;
  setShowUserModal: (show: boolean) => void;
  handleProviderChange: (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => void;
  handleUserChange: (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => void;
  handleEditProvider: () => void;
  handleCancelEditProvider: () => void;
  handleSaveProvider: () => Promise<void>;
  handleEditUser: () => void;
  handleCancelEditUser: () => void;
  handleSaveUser: () => Promise<void>;
  handleUploadLogo: (file: File) => Promise<void>;
  handleDeleteLogo: () => Promise<void>;
  handleUploadAvatar: (file: File) => Promise<void>;
  handleDeleteAvatar: () => Promise<void>;
  refreshData: () => Promise<void>;
}

export const useProfileProvider = (): UseProfileProviderReturn => {
  const navigate = useNavigate();
  const [provider, setProvider] = useState<ProviderDTO | null>(null);
  const [user, setUser] = useState<UserDTO | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string>("");
  const [successMessage, setSuccessMessage] = useState<string>("");
  const [showSuccessToast, setShowSuccessToast] = useState(false);
  const [isEditingProvider, setIsEditingProvider] = useState(false);
  const [isEditingUser, setIsEditingUser] = useState(false);
  const [showUserModal, setShowUserModal] = useState(false);
  const [providerForm, setProviderForm] = useState<Partial<ProviderDTO>>({});
  const [userForm, setUserForm] = useState<Partial<UserDTO>>({});

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const userStr = localStorage.getItem("user");
      if (!userStr) {
        navigate("/supplier/login");
        return;
      }

      const userData = JSON.parse(userStr);
      const userId = userData.userId;

      // Load provider data
      const providerData = await getProviderByUserId(userId);
      if (!providerData) {
        navigate("/supplier/provider-info");
        return;
      }
      setProvider(providerData);
      setProviderForm(providerData);

      // Load user data
      const userDataFull = await getUserById(userId);
      setUser(userDataFull);
      setUserForm(userDataFull);

      setLoading(false);
    } catch (err) {
      console.error("Error loading profile:", err);
      setError(err instanceof Error ? err.message : "Đã có lỗi xảy ra");
      setLoading(false);
    }
  }, [navigate]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const refreshData = async () => {
    await loadData();
  };

  const showSuccess = (message: string) => {
    setSuccessMessage(message);
    setShowSuccessToast(true);
    setTimeout(() => setShowSuccessToast(false), 3000);
  };

  const handleProviderChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setProviderForm((prev) => ({ ...prev, [name]: value }));
    setError("");
  };

  const handleUserChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setUserForm((prev) => ({ ...prev, [name]: value }));
    setError("");
  };

  const handleEditProvider = () => {
    setIsEditingProvider(true);
    setProviderForm(provider || {});
  };

  const handleCancelEditProvider = () => {
    setIsEditingProvider(false);
    setProviderForm(provider || {});
    setError("");
  };

  const handleSaveProvider = async () => {
    try {
      if (!provider?.providerId) return;

      setLoading(true);
      const result = await updateProvider(provider.providerId, providerForm);
      if (result.success && result.data) {
        setProvider(result.data);
        setProviderForm(result.data);
        setIsEditingProvider(false);
        showSuccess("Cập nhật thông tin nhà cung cấp thành công!");
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Đã có lỗi xảy ra");
    } finally {
      setLoading(false);
    }
  };

  const handleEditUser = () => {
    setIsEditingUser(true);
    setUserForm(user || {});
  };

  const handleCancelEditUser = () => {
    setIsEditingUser(false);
    setUserForm(user || {});
    setError("");
  };

  const handleSaveUser = async () => {
    try {
      if (!user?.userId) return;

      setLoading(true);
      const result = await updateUser(user.userId, userForm);
      if (result.success && result.data) {
        setUser(result.data);
        setUserForm(result.data);
        setIsEditingUser(false);
        showSuccess("Cập nhật thông tin người dùng thành công!");

        // Update localStorage
        const userStr = localStorage.getItem("user");
        if (userStr) {
          const userData = JSON.parse(userStr);
          localStorage.setItem(
            "user",
            JSON.stringify({ ...userData, ...result.data })
          );
        }
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Đã có lỗi xảy ra");
    } finally {
      setLoading(false);
    }
  };

  const handleUploadLogo = async (file: File) => {
    try {
      if (!provider?.providerId) return;

      setLoading(true);
      const updatedProvider = await uploadProviderLogo(
        provider.providerId,
        file
      );
      setProvider(updatedProvider);
      setProviderForm(updatedProvider);
      showSuccess("Upload logo thành công!");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Upload logo thất bại");
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteLogo = async () => {
    try {
      if (!provider?.providerId) return;

      setLoading(true);
      const updatedProvider = await deleteProviderLogo(provider.providerId);
      setProvider(updatedProvider);
      setProviderForm(updatedProvider);
      showSuccess("Xóa logo thành công!");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Xóa logo thất bại");
    } finally {
      setLoading(false);
    }
  };

  const handleUploadAvatar = async (file: File) => {
    try {
      if (!user?.userId) return;

      setLoading(true);
      const updatedUser = await uploadUserAvatar(user.userId, file);
      setUser(updatedUser);
      setUserForm(updatedUser);
      showSuccess("Upload avatar thành công!");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Upload avatar thất bại");
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteAvatar = async () => {
    try {
      if (!user?.userId) return;

      setLoading(true);
      const updatedUser = await deleteUserAvatar(user.userId);
      setUser(updatedUser);
      setUserForm(updatedUser);
      showSuccess("Xóa avatar thành công!");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Xóa avatar thất bại");
    } finally {
      setLoading(false);
    }
  };

  return {
    provider,
    user,
    loading,
    error,
    successMessage,
    showSuccessToast,
    isEditingProvider,
    isEditingUser,
    showUserModal,
    providerForm,
    userForm,
    setShowUserModal,
    handleProviderChange,
    handleUserChange,
    handleEditProvider,
    handleCancelEditProvider,
    handleSaveProvider,
    handleEditUser,
    handleCancelEditUser,
    handleSaveUser,
    handleUploadLogo,
    handleDeleteLogo,
    handleUploadAvatar,
    handleDeleteAvatar,
    refreshData,
  };
};
