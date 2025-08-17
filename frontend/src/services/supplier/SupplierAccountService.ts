import api from "../api";
import type { UserDTO, ApiResponse } from "../../types/index";
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
        errorMessage =
          (error.response.data && error.response.data.message) ||
          "Đăng ký thất bại";
      } else if (error.request) {
        errorMessage = "Không kết nối được với máy chủ";
      }
    } else if (error instanceof Error) {
      errorMessage = error.message;
    }
    throw new Error(errorMessage);
  }
};
