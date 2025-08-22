import api from "./api";
import type {
  UserDTO,
  ApiResponse,
  LoginRequest,
  LoginResponse,
  RawLoginResponse,
} from "../types";
import axios from "axios";

export const registerSupplier = async (
  userData: UserDTO
): Promise<ApiResponse<UserDTO>> => {
  try {
    const resp = await api.post("/users/provider", userData);
    const respData = resp.data;
    if (respData && typeof respData.success === "boolean") {
      return respData as ApiResponse<UserDTO>;
    }
    return {
      success: true,
      data: respData as UserDTO,
      message: undefined,
    };
  } catch (error) {
    let errorMessage = "Lỗi không xác định. Vui lòng thử lại sau";
    if (axios.isAxiosError(error)) {
      if (error.response) {
        const respData = error.response.data as { message?: string } | string;
        if (typeof respData === "string") errorMessage = respData;
        else errorMessage = respData.message || "Đăng ký thất bại";
      } else if (error.request) {
        errorMessage = "Không kết nối được với máy chủ";
      }
    } else if (error instanceof Error) {
      errorMessage = error.message;
    }
    throw new Error(errorMessage);
  }
};

export const loginSupplier = async (
  credentials: LoginRequest
): Promise<ApiResponse<LoginResponse>> => {
  try {
    const resp = await api.post("/auth/provider/login", credentials);
    const respData: RawLoginResponse = resp.data as RawLoginResponse;
    let loginData: LoginResponse | null = null;
    if (respData) {
      const tokenValue = respData.token || respData.jwt;
      if (tokenValue) {
        loginData = {
          token: tokenValue,
          type: respData.type || "Bearer",
          userId: respData.userId,
          name: respData.name || respData.fullName || "",
          email: respData.email,
        };
      }
    }
    if (!loginData) {
      throw new Error("Phản hồi đăng nhập không hợp lệ");
    }
    localStorage.setItem("token", loginData.token);
    localStorage.setItem("user", JSON.stringify(loginData));
    return { success: true, data: loginData };
  } catch (error) {
    let errorMessage = "Lỗi không xác định. Vui lòng thử lại sau";
    if (axios.isAxiosError(error)) {
      if (error.response) {
        const data = error.response.data as Partial<RawLoginResponse> | string;
        if (typeof data === "string") errorMessage = data;
        else errorMessage = data?.message || "Đăng nhập thất bại";
      } else if (error.request) {
        errorMessage = "Không kết nối được với máy chủ";
      }
    } else if (error instanceof Error) {
      errorMessage = error.message;
    }
    throw new Error(errorMessage);
  }
};

export const logoutSupplier = async (): Promise<void> => {
  try {
    await api.post("/auth/logout");
  } catch {
    // ignore
  } finally {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    document.cookie.split(";").forEach((cookie) => {
      const eqPos = cookie.indexOf("=");
      const name = eqPos > -1 ? cookie.slice(0, eqPos) : cookie;
      document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/`;
    });
  }
};

// ================= Password Recovery Flow =================

const extractErrorMessage = (error: unknown, fallback: string) => {
  let errorMessage = fallback;
  if (axios.isAxiosError(error)) {
    if (error.response) {
      const respData = error.response.data as { message?: string } | string;
      if (typeof respData === "string") errorMessage = respData;
      else errorMessage = respData.message || fallback;
    } else if (error.request) {
      errorMessage = "Không kết nối được với máy chủ";
    }
  } else if (error instanceof Error) {
    errorMessage = error.message;
  }
  return errorMessage;
};

export const forgotPassword = async (email: string): Promise<string> => {
  try {
    const resp = await api.post("/users/forgot-password", { email });
    return (resp.data as { message?: string } | string)?.valueOf() as string;
  } catch (error) {
    throw new Error(
      extractErrorMessage(error, "Gửi yêu cầu đặt lại mật khẩu thất bại")
    );
  }
};

export const verifyOtp = async (
  email: string,
  otp: string
): Promise<string> => {
  try {
    const resp = await api.post("/users/verify-otp", { email, otp });
    return (resp.data as { message?: string } | string)?.valueOf() as string;
  } catch (error) {
    throw new Error(extractErrorMessage(error, "Xác minh OTP thất bại"));
  }
};

export const resetPassword = async (
  email: string,
  otp: string,
  newPassword: string,
  newConfirmPassword: string
): Promise<string> => {
  try {
    const resp = await api.post("/users/reset-password", {
      email,
      otp,
      newPassword,
      newConfirmPassword,
    });
    return (resp.data as { message?: string } | string)?.valueOf() as string;
  } catch (error) {
    throw new Error(
      extractErrorMessage(error, "Cập nhật mật khẩu thất bại, vui lòng thử lại")
    );
  }
};
