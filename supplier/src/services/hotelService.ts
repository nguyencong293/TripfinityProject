import api from "./api";
import type { HotelDTO } from "../types";

/**
 * Get all hotels by provider ID
 */
export const getHotelsByProvider = async (
  providerId: number
): Promise<HotelDTO[]> => {
  const response = await api.get<HotelDTO[]>(`/hotels/provider/${providerId}`);
  return response.data;
};

/**
 * Get hotels by provider ID and status
 */
export const getHotelsByProviderAndStatus = async (
  providerId: number,
  status: string
): Promise<HotelDTO[]> => {
  const response = await api.get<HotelDTO[]>(
    `/hotels/provider/${providerId}/status/${status}`
  );
  return response.data;
};

/**
 * Get hotel by ID
 */
export const getHotelById = async (hotelId: number): Promise<HotelDTO> => {
  const response = await api.get<HotelDTO>(`/hotels/${hotelId}`);
  return response.data;
};

/**
 * Create new hotel
 */
export const createHotel = async (
  hotelData: Partial<HotelDTO>
): Promise<HotelDTO> => {
  const response = await api.post<HotelDTO>("/hotels", hotelData);
  return response.data;
};

/**
 * Update hotel
 */
export const updateHotel = async (
  hotelId: number,
  hotelData: Partial<HotelDTO>
): Promise<HotelDTO> => {
  const response = await api.put<HotelDTO>(`/hotels/${hotelId}`, hotelData);
  return response.data;
};

/**
 * Delete hotel
 */
export const deleteHotel = async (hotelId: number): Promise<void> => {
  await api.delete(`/hotels/${hotelId}`);
};

/**
 * Upload hotel thumbnail
 */
export const uploadHotelThumbnail = async (
  hotelId: number,
  file: File
): Promise<HotelDTO> => {
  const formData = new FormData();
  formData.append("file", file);

  const response = await api.post<HotelDTO>(
    `/hotels/${hotelId}/thumbnail`,
    formData,
    {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    }
  );
  return response.data;
};

/**
 * Upload hotel images
 */
export const uploadHotelImages = async (
  hotelId: number,
  files: File[]
): Promise<HotelDTO> => {
  const formData = new FormData();
  files.forEach((file) => formData.append("files", file));

  const response = await api.post<HotelDTO>(
    `/hotels/${hotelId}/images`,
    formData,
    {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    }
  );
  return response.data;
};

/**
 * Delete hotel thumbnail
 */
export const deleteHotelThumbnail = async (
  hotelId: number
): Promise<HotelDTO> => {
  const response = await api.delete<HotelDTO>(`/hotels/${hotelId}/thumbnail`);
  return response.data;
};

/**
 * Delete hotel image
 */
export const deleteHotelImage = async (
  hotelId: number,
  imageUrl: string
): Promise<HotelDTO> => {
  const response = await api.delete<HotelDTO>(`/hotels/${hotelId}/images`, {
    params: { imageUrl },
  });
  return response.data;
};
