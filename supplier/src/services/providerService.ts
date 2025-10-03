import api from "./api";
import type { ProviderDTO, CreateProviderRequest, ApiResponse } from "../types";
import axios from "axios";

const extractErrorMessage = (
  error: unknown,
  defaultMessage: string
): string => {
  if (axios.isAxiosError(error)) {
    if (error.response?.data) {
      const data = error.response.data;
      if (typeof data === "string") return data;
      if (data.message) return data.message;
    }
    if (error.message) return error.message;
  }
  if (error instanceof Error) return error.message;
  return defaultMessage;
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

export const uploadProviderLogo = async (
  providerId: number,
  file: File
): Promise<ProviderDTO> => {
  try {
    const formData = new FormData();
    formData.append("file", file);

    const resp = await api.post(`/providers/${providerId}/logo`, formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
    return resp.data as ProviderDTO;
  } catch (error) {
    const errorMessage = extractErrorMessage(error, "Upload logo thất bại");
    throw new Error(errorMessage);
  }
};

export const deleteProviderLogo = async (
  providerId: number
): Promise<ProviderDTO> => {
  try {
    const resp = await api.delete(`/providers/${providerId}/logo`);
    return resp.data as ProviderDTO;
  } catch (error) {
    const errorMessage = extractErrorMessage(error, "Xóa logo thất bại");
    throw new Error(errorMessage);
  }
};
