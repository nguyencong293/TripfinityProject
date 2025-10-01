import { useState } from "react";
import { useLanguage } from "./useLanguage";
import type { LoginRequest, LoginResponse, ApiResponse } from "../types";
import { loginSupplier } from "../services/supplierAuthService";
import { getProviderByUserId } from "../services/providerService";

export const useSupplierLogin = () => {
  const { t } = useLanguage();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [data, setData] = useState<LoginResponse | null>(null);
  const [needsProviderInfo, setNeedsProviderInfo] = useState(false);

  const handleLogin = async (credentials: LoginRequest) => {
    setIsLoading(true);
    setError(null);
    setData(null);
    setNeedsProviderInfo(false);

    try {
      const response: ApiResponse<LoginResponse> = await loginSupplier(
        credentials
      );

      if (response && response.success && response.data) {
        // Check if user has provider info
        const provider = await getProviderByUserId(response.data.userId);

        if (!provider) {
          // User doesn't have provider info yet
          setNeedsProviderInfo(true);
        }

        setData(response.data);
      } else {
        setError(response?.message || t("login_failed"));
      }
    } catch (err: unknown) {
      if (err instanceof Error) setError(err.message);
      else setError(t("unknown_error"));
    } finally {
      setIsLoading(false);
    }
  };

  return {
    isLoading,
    error,
    data,
    needsProviderInfo,
    handleLogin,
  };
};
