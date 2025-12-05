import axios from "axios";

const API_BASE_URL = "http://localhost:8080/api";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
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
