import axios from "axios";

// ============================================================
// 🔧 API CONFIGURATION
// ============================================================
// Cập nhật URL ngrok Backend tại đây (lấy từ dashboard http://127.0.0.1:4040)
// Supplier gọi Backend API qua ngrok để hoạt động khi chạy qua internet
// ============================================================
const NGROK_BACKEND_URL = "https://unprotrusively-nonreportable-kingston.ngrok-free.dev";

// Sử dụng ngrok URL
const API_BASE_URL = `${NGROK_BACKEND_URL}/api`;

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
    // Header này để bypass trang cảnh báo của ngrok free
    "ngrok-skip-browser-warning": "true",
  },
  timeout: 60000, // 60 seconds (1 minute) - cho upload nhiều ảnh
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers = config.headers || {};
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    // Network error or server not responding
    if (!error.response) {
      // Server is down or network error
      const currentPath = window.location.pathname;
      if (currentPath !== "/supplier/server-error") {
        window.location.href = "/supplier/server-error";
      }
      return Promise.reject(error);
    }

    // Handle 401 Unauthorized
    if (error.response?.status === 401) {
      const currentPath = window.location.pathname;
      if (
        currentPath !== "/supplier/login" &&
        currentPath !== "/supplier/server-error"
      ) {
        localStorage.removeItem("token");
        localStorage.removeItem("user");
        window.location.href = "/supplier/login";
      }
    }

    return Promise.reject(error);
  }
);

export default api;
