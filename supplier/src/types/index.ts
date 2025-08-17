export interface UserDTO {
  userId?: number;
  email: string;
  passwordHash?: string;
  confirmPassword?: string;
  fullName: string;
  phoneNumber?: string;
  avatarUrl?: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}
