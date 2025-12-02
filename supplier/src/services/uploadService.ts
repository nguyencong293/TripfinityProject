import api from "./api";

/**
 * Upload single image to Cloudinary
 * Returns the image URL
 */
export const uploadSingleImage = async (file: File): Promise<string> => {
  const formData = new FormData();
  formData.append("file", file);

  const response = await api.post<{ url: string }>(
    "/upload/image",
    formData,
    {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    }
  );
  return response.data.url;
};

/**
 * Upload multiple images to Cloudinary
 * Returns array of image URLs
 */
export const uploadMultipleImages = async (files: File[]): Promise<string[]> => {
  const formData = new FormData();
  files.forEach((file) => formData.append("files", file));

  const response = await api.post<{ urls: string[] }>(
    "/upload/images",
    formData,
    {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    }
  );
  return response.data.urls;
};

/**
 * Delete image from Cloudinary by URL
 */
export const deleteImage = async (imageUrl: string): Promise<void> => {
  await api.delete("/upload/image", {
    params: { imageUrl },
  });
};

/**
 * Delete multiple images from Cloudinary by URLs
 */
export const deleteMultipleImages = async (imageUrls: string[]): Promise<void> => {
  await api.delete("/upload/images", {
    data: { imageUrls },
  });
};
