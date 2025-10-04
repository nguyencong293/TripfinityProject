import { useEffect, useState, useCallback } from "react";
import { WifiOff, RefreshCw, Server } from "lucide-react";
import axios from "axios";

const ServerErrorPage: React.FC = () => {
  const [retrying, setRetrying] = useState(false);
  const [countdown, setCountdown] = useState(10);
  const [autoRetry, setAutoRetry] = useState(true);

  const checkServerStatus = useCallback(async (): Promise<boolean> => {
    try {
      // Tăng timeout lên 10 giây vì server cần thời gian khởi động
      const healthCheck = axios.create({
        timeout: 10000,
      });

      // Thử nhiều endpoint để đảm bảo
      try {
        await healthCheck.get("http://localhost:8080/actuator/health");
        console.log("✅ Health endpoint OK");
        return true;
      } catch {
        console.log("Health endpoint failed, trying alternative...");
        // Nếu actuator fail, thử endpoint khác
        try {
          await healthCheck.get("http://localhost:8080/api/auth/me");
          console.log("✅ Auth endpoint OK");
          return true;
        } catch {
          console.log("All endpoints failed");
          return false;
        }
      }
    } catch (error) {
      console.log("Health check failed:", error);
      return false;
    }
  }, []);

  const handleRetry = useCallback(async () => {
    console.log("Starting retry...");
    setRetrying(true);
    const isOnline = await checkServerStatus();

    console.log("Server online status:", isOnline);

    if (isOnline) {
      // Server đã hoạt động lại
      const token = localStorage.getItem("token");
      const userStr = localStorage.getItem("user");

      console.log("Has token:", !!token);
      console.log("Has user:", !!userStr);

      // Dùng window.location.href để reload toàn bộ app
      if (token && userStr) {
        console.log("Redirecting to /supplier");
        window.location.href = "/supplier";
      } else {
        console.log("Redirecting to /supplier/login");
        window.location.href = "/supplier/login";
      }
    } else {
      console.log("Server still offline, resetting countdown");
      setRetrying(false);
      setCountdown(10); // Reset countdown
    }
  }, [checkServerStatus]);

  // Auto retry countdown
  useEffect(() => {
    if (!autoRetry || retrying) return;

    if (countdown <= 0) {
      handleRetry();
      return;
    }

    const timer = setTimeout(() => {
      setCountdown(countdown - 1);
    }, 1000);

    return () => clearTimeout(timer);
  }, [countdown, autoRetry, retrying, handleRetry]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 flex items-center justify-center p-4">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-xl p-8">
        <div className="text-center">
          {/* Icon */}
          <div className="inline-flex items-center justify-center w-20 h-20 bg-red-100 rounded-full mb-6">
            <WifiOff className="w-10 h-10 text-red-600" />
          </div>

          {/* Title */}
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            Không thể kết nối
          </h1>

          {/* Description */}
          <p className="text-gray-600 mb-6">
            Không thể kết nối đến máy chủ. Vui lòng kiểm tra:
          </p>

          {/* Checklist */}
          <div className="text-left bg-gray-50 rounded-lg p-4 mb-6">
            <div className="space-y-2 text-sm text-gray-700">
              <div className="flex items-start">
                <Server className="w-4 h-4 mt-0.5 mr-2 flex-shrink-0" />
                <span>Máy chủ Server</span>
              </div>
              <div className="flex items-start">
                <WifiOff className="w-4 h-4 mt-0.5 mr-2 flex-shrink-0" />
                <span>Kết nối mạng của bạn</span>
              </div>
            </div>
          </div>

          {/* Auto retry status */}
          <div className="mb-6">
            {autoRetry && !retrying && (
              <p className="text-sm text-gray-600">
                Tự động thử lại sau{" "}
                <span className="font-semibold text-emerald-600">
                  {countdown}
                </span>{" "}
                giây...
              </p>
            )}
            {retrying && (
              <p className="text-sm text-gray-600 flex items-center justify-center">
                <RefreshCw className="w-4 h-4 mr-2 animate-spin" />
                Đang kiểm tra kết nối...
              </p>
            )}
          </div>

          {/* Action buttons */}
          <div className="space-y-3">
            <button
              onClick={handleRetry}
              disabled={retrying}
              className="w-full bg-emerald-600 hover:bg-emerald-700 disabled:bg-gray-400 
                         text-white font-medium py-3 px-4 rounded-lg transition-colors
                         flex items-center justify-center"
            >
              <RefreshCw
                className={`w-5 h-5 mr-2 ${retrying ? "animate-spin" : ""}`}
              />
              {retrying ? "Đang thử lại..." : "Thử lại ngay"}
            </button>

            <button
              onClick={() => setAutoRetry(!autoRetry)}
              className="w-full bg-white hover:bg-gray-50 text-gray-700 font-medium 
                         py-3 px-4 rounded-lg border border-gray-300 transition-colors"
            >
              {autoRetry ? "Tắt tự động thử lại" : "Bật tự động thử lại"}
            </button>
          </div>

          {/* Additional info */}
          <div className="mt-6 pt-6 border-t border-gray-200">
            <p className="text-xs text-gray-500">
              Nếu vấn đề vẫn tiếp tục, vui lòng liên hệ quản trị viên
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ServerErrorPage;
