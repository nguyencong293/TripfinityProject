import { useState } from "react";
import { useLanguage } from "./useLanguage";
import {
  forgotPassword,
  verifyOtp,
  resetPassword,
} from "../services/supplierAuthService";

export const useForgotPassword = () => {
  const { t } = useLanguage();
  const [step, setStep] = useState<0 | 1 | 2>(0);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");

  const clearStatus = () => {
    setError(null);
    setMessage(null);
  };

  const requestOtp = async (inputEmail: string) => {
    setIsLoading(true);
    clearStatus();
    try {
      await forgotPassword(inputEmail.trim());
      setEmail(inputEmail.trim());
      setStep(1);
      // Clear any prior success once we move to next step
      setMessage(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : t("unknown_error"));
    } finally {
      setIsLoading(false);
    }
  };

  const submitOtp = async (fullOtp: string) => {
    setIsLoading(true);
    clearStatus();
    try {
      await verifyOtp(email, fullOtp);
      setOtp(fullOtp);
      setStep(2);
      setMessage(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : t("unknown_error"));
    } finally {
      setIsLoading(false);
    }
  };

  const updatePassword = async (newPassword: string, confirm: string) => {
    setIsLoading(true);
    clearStatus();
    try {
      await resetPassword(email, otp, newPassword, confirm);
      // Success: optionally show a toast externally; clear internal message
      setMessage(null);
      setStep(0);
      setEmail("");
      setOtp("");
      return true;
    } catch (e) {
      setError(e instanceof Error ? e.message : t("unknown_error"));
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  return {
    step,
    isLoading,
    error,
    message,
    email,
    requestOtp,
    submitOtp,
    updatePassword,
    clearStatus,
    setStep,
  };
};
