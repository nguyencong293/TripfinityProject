import api from "./api";
import type { ProviderDTO, CreateProviderRequest, ApiResponse } from "../types";
import axios from "axios";

const extractErrorMessage = (error: unknown, fallback: string): string => {
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

export const getProviderByUserId = async (
  userId: number
): Promise<ProviderDTO | null> => {
  try {
    const resp = await api.get(`/providers/user/${userId}`);
    const providers = resp.data as ProviderDTO[];
    return providers.length > 0 ? providers[0] : null;
  } catch (error) {
    if (axios.isAxiosError(error) && error.response?.status === 404) {
      return null;
    }
    throw new Error(
      extractErrorMessage(error, "Không thể lấy thông tin nhà cung cấp")
    );
  }
};

export const getProviderById = async (
  providerId: number
): Promise<ProviderDTO> => {
  try {
    const resp = await api.get(`/providers/${providerId}`);
    return resp.data as ProviderDTO;
  } catch (error) {
    throw new Error(
      extractErrorMessage(error, "Không tìm thấy thông tin nhà cung cấp")
    );
  }
};

export const createProvider = async (
  data: CreateProviderRequest
): Promise<ApiResponse<ProviderDTO>> => {
  try {
    const resp = await api.post("/providers", data);
    return {
      success: true,
      data: resp.data as ProviderDTO,
    };
  } catch (error) {
    const errorMessage = extractErrorMessage(
      error,
      "Tạo hồ sơ nhà cung cấp thất bại"
    );
    throw new Error(errorMessage);
  }
};

export const updateProvider = async (
  providerId: number,
  data: Partial<CreateProviderRequest>
): Promise<ApiResponse<ProviderDTO>> => {
  try {
    const resp = await api.put(`/providers/${providerId}`, data);
    return {
      success: true,
      data: resp.data as ProviderDTO,
    };
  } catch (error) {
    const errorMessage = extractErrorMessage(
      error,
      "Cập nhật hồ sơ nhà cung cấp thất bại"
    );
    throw new Error(errorMessage);
  }
};
