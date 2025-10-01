import { useCallback, useEffect, useRef, useState } from "react";
import { loginSupplierWithGoogle } from "../services/supplierAuthService";
import { getProviderByUserId } from "../services/providerService";
import type { ApiResponse, LoginResponse } from "../types";

const GOOGLE_CLIENT_ID =
  (import.meta.env &&
    (import.meta.env as ImportMetaEnv).VITE_GOOGLE_CLIENT_ID) ||
  "173444476399-srrjbrmg2c0rsatfd4498t0499gmn104.apps.googleusercontent.com";

export const useGoogleLogin = () => {
  const [isReady, setIsReady] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [data, setData] = useState<LoginResponse | null>(null);
  const [needsProviderInfo, setNeedsProviderInfo] = useState(false);
  const scriptLoaded = useRef(false);

  useEffect(() => {
    if (scriptLoaded.current) return;
    const existing = document.querySelector(
      'script[src="https://accounts.google.com/gsi/client"]'
    ) as HTMLScriptElement | null;
    if (existing) {
      scriptLoaded.current = true;
      setIsReady(true);
      return;
    }
    const script = document.createElement("script");
    script.src = "https://accounts.google.com/gsi/client";
    script.async = true;
    script.defer = true;
    script.onload = () => {
      scriptLoaded.current = true;
      setIsReady(true);
    };
    script.onerror = () => {
      setError("Không tải được Google Identity Services");
    };
    document.head.appendChild(script);
    return () => {};
  }, []);

  const handleCredential = useCallback(async (credential: string) => {
    setIsLoading(true);
    setError(null);
    setNeedsProviderInfo(false);

    try {
      const resp: ApiResponse<LoginResponse> = await loginSupplierWithGoogle(
        credential
      );

      if (resp && resp.success && resp.data) {
        // Check if user has provider info
        const provider = await getProviderByUserId(resp.data.userId);

        if (!provider) {
          // User doesn't have provider info yet
          setNeedsProviderInfo(true);
        }

        setData(resp.data);
        return resp.data;
      } else {
        throw new Error(resp?.message || "Đăng nhập Google thất bại");
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : "Đăng nhập Google thất bại");
      throw e;
    } finally {
      setIsLoading(false);
    }
  }, []);

  const renderButton = useCallback(
    (
      element: HTMLElement,
      options?: google.accounts.id.GsiButtonConfiguration
    ) => {
      if (!window.google || !isReady) return;
      const g = window.google;
      g?.accounts.id.initialize({
        client_id: GOOGLE_CLIENT_ID,
        callback: (response: google.accounts.id.CredentialResponse) => {
          if (response?.credential) handleCredential(response.credential);
        },
        ux_mode: "popup",
        auto_select: false,
      });
      g?.accounts.id.renderButton(element, {
        theme: "outline",
        size: "large",
        shape: "pill",
        text: "continue_with",
        logo_alignment: "left",
        width: element.clientWidth || 320,
        ...options,
      });
    },
    [isReady, handleCredential]
  );

  // One Tap optional
  const promptOneTap = useCallback(() => {
    if (!window.google || !isReady) return;
    const g = window.google;
    g?.accounts.id.initialize({
      client_id: GOOGLE_CLIENT_ID,
      callback: (response: google.accounts.id.CredentialResponse) => {
        if (response?.credential) handleCredential(response.credential);
      },
      ux_mode: "popup",
      auto_select: false,
    });
    g?.accounts.id.prompt();
  }, [isReady, handleCredential]);

  return {
    isReady,
    isLoading,
    error,
    data,
    needsProviderInfo,
    renderButton,
    promptOneTap,
  };
};

export default useGoogleLogin;
