export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface UserDTO {
  userId?: number;
  email: string;
  passwordHash?: string;
  confirmPassword?: string;
  fullName: string;
  phoneNumber?: string;
  avatarUrl?: string;
}
export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  type?: string;
  userId: number;
  name: string;
  email: string;
}

export interface RawLoginResponse {
  token?: string;
  jwt?: string;
  type?: string;
  userId: number;
  name?: string;
  fullName?: string;
  email: string;
  message?: string;
  [key: string]: unknown;
}

export interface ForgotPasswordRequest {
  email: string;
}

export interface VerifyOtpRequest {
  email: string;
  otp: string;
}

export interface ResetPasswordRequest {
  email: string;
  otp: string;
  newPassword: string;
  newConfirmPassword: string;
}
