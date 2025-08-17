import { useState } from "react";
import type { UserDTO } from "../types";
import { registerSupplier } from "../services/supplier/SupplierAccountService";
import { useLanguage } from "../hooks/useLanguage";

export const useRegister = () => {
  const { t } = useLanguage();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const handleRegister = async (userData: UserDTO) => {
    setIsLoading(true);
    setError(null);
    setSuccess(false);

    try {
      const response = await registerSupplier(userData);

      if (response && response.success) {
        setSuccess(true);
      } else {
        setError(response?.message || t("registration_failed"));
      }
    } catch (err: unknown) {
      if (err instanceof Error) {
        setError(err.message);
      } else {
        setError(t("unknown_error"));
      }
    } finally {
      setIsLoading(false);
    }
  };

  return { isLoading, error, success, handleRegister };
};
