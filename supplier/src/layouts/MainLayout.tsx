import React, { useState, useEffect } from "react";
import type { ReactNode } from "react";
import { useNavigate } from "react-router-dom";
import {
  Bell,
  User,
  LogOut,
  Settings,
  HelpCircle,
  ChevronDown,
  Menu,
  Globe,
  Smartphone,
  Monitor,
} from "lucide-react";
import type { LoginResponse } from "../types";
import { logoutSupplier } from "../services/supplierAuthService";

const sidebarMenuItems = [
  { icon: Globe, label: "Trang chủ", to: "/supplier" },
  { icon: Settings, label: "Cài đặt", to: "/supplier/settings" },
];

const SidebarMenuItem = ({
  icon: Icon,
  label,
  to,
  active,
}: {
  icon: React.ElementType;
  label: string;
  to: string;
  active?: boolean;
}) => (
  <a
    href={to}
    className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-all duration-200 ${
      active
        ? "theme-bg-primary theme-text-button font-medium"
        : "hover:theme-bg-secondary theme-text-secondary hover:theme-text-primary"
    }`}
  >
    <Icon className="w-5 h-5" />
    <span className="flex-1">{label}</span>
  </a>
);

interface MainLayoutProps {
  children: ReactNode;
}

const MainLayout: React.FC<MainLayoutProps> = ({ children }) => {
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);

  // Authentication state
  const [authUser, setAuthUser] = useState<LoginResponse | null>(() => {
    try {
      const stored = localStorage.getItem("user");
      const token = localStorage.getItem("token");
      if (stored && token) {
        return JSON.parse(stored) as LoginResponse;
      }
      return null;
    } catch {
      localStorage.removeItem("user");
      localStorage.removeItem("token");
      return null;
    }
  });

  // Listen for storage changes (for multi-tab sync)
  useEffect(() => {
    const handleStorageChange = () => {
      try {
        const stored = localStorage.getItem("user");
        const token = localStorage.getItem("token");
        if (stored && token) {
          setAuthUser(JSON.parse(stored) as LoginResponse);
        } else {
          setAuthUser(null);
        }
      } catch {
        localStorage.removeItem("user");
        localStorage.removeItem("token");
        setAuthUser(null);
      }
    };

    window.addEventListener("storage", handleStorageChange);
    return () => window.removeEventListener("storage", handleStorageChange);
  }, []);

  // Close user menu if not authenticated
  useEffect(() => {
    if (!authUser) {
      setUserMenuOpen(false);
    }
  }, [authUser]);

  // Redirect to login if not authenticated
  useEffect(() => {
    const token = localStorage.getItem("token");
    if (!authUser || !token) {
      navigate("/supplier/login", { replace: true });
    }
  }, [authUser, navigate]);

  // Handle logout
  const handleLogout = async () => {
    try {
      await logoutSupplier();
    } catch (error) {
      console.error("Logout error:", error);
    } finally {
      // Clear local state and storage
      localStorage.removeItem("token");
      localStorage.removeItem("user");
      setAuthUser(null);
      setUserMenuOpen(false);
      navigate("/supplier/login", { replace: true });
    }
  };

  // Don't render layout if not authenticated
  if (!authUser) {
    return null;
  }

  return (
    <div className="theme-bg-background min-h-screen flex">
      {/* Sidebar */}
      <div
        className={`fixed inset-y-0 left-0 z-50 w-64 theme-bg-card border-r theme-border transform transition-transform duration-300 lg:translate-x-0 lg:static lg:inset-0 ${
          sidebarOpen ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        <div className="flex flex-col h-full">
          {/* Logo */}
          <div className="flex items-center gap-3 p-6 border-b theme-border">
            <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl flex items-center justify-center">
              <Globe className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold theme-text-primary">
                TRIPFINITY
              </h1>
              <p className="text-xs theme-text-secondary">Supplier Dashboard</p>
            </div>
          </div>
          {/* Navigation */}
          <nav className="flex-1 p-4 space-y-2">
            {sidebarMenuItems.map((item, index) => (
              <SidebarMenuItem
                key={index}
                icon={item.icon}
                label={item.label}
                to={item.to}
                active={window.location.pathname === item.to}
              />
            ))}
          </nav>
          {/* User Profile */}
          <div className="p-4 border-t theme-border">
            <div className="flex items-center gap-3 p-3 theme-bg-secondary rounded-xl">
              <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-teal-600 rounded-full flex items-center justify-center text-white font-semibold">
                {authUser.name?.[0]?.toUpperCase() ||
                  authUser.email?.[0]?.toUpperCase() ||
                  "U"}
              </div>
              <div className="flex-1 min-w-0">
                <p className="theme-text-primary font-medium truncate">
                  {authUser.name || "Người dùng"}
                </p>
                <p className="theme-text-secondary text-sm truncate">
                  {authUser.email}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top Header */}
        <header className="theme-bg-card border-b theme-border sticky top-0 z-40">
          <div className="flex items-center justify-between p-4">
            <div className="flex items-center gap-4">
              <button
                onClick={() => setSidebarOpen(!sidebarOpen)}
                className="lg:hidden btn-outline p-2"
              >
                <Menu className="w-5 h-5" />
              </button>
            </div>
            <div className="flex items-center gap-4">
              {/* Notifications & User Menu */}
              <div className="flex items-center gap-2">
                <button className="relative btn-outline p-3">
                  <Bell className="w-5 h-5" />
                  <span className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 text-white text-xs rounded-full flex items-center justify-center">
                    3
                  </span>
                </button>
                <div className="relative">
                  <button
                    onClick={() => setUserMenuOpen(!userMenuOpen)}
                    className="flex items-center gap-3 p-2 rounded-xl hover:theme-bg-secondary transition-colors"
                  >
                    <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white font-semibold text-sm">
                      {authUser.name?.[0]?.toUpperCase() ||
                        authUser.email?.[0]?.toUpperCase() ||
                        "U"}
                    </div>
                    <ChevronDown className="w-4 h-4 theme-text-secondary" />
                  </button>
                  {userMenuOpen && (
                    <div className="absolute right-0 top-full mt-2 w-64 theme-bg-card border theme-border rounded-2xl shadow-lg py-2 z-50">
                      <div className="px-4 py-3 border-b theme-border">
                        <p className="theme-text-primary font-medium">
                          {authUser.name || "Người dùng"}
                        </p>
                        <p className="theme-text-secondary text-sm">
                          {authUser.email}
                        </p>
                      </div>
                      <div className="py-2">
                        <button className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-primary">
                          <User className="w-4 h-4" />
                          Thông tin tài khoản
                        </button>
                        <button className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-primary">
                          <Settings className="w-4 h-4" />
                          Cài đặt
                        </button>
                        <button className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-primary">
                          <HelpCircle className="w-4 h-4" />
                          Hỗ trợ
                        </button>
                        <hr className="my-2 theme-border" />
                        <button
                          onClick={handleLogout}
                          className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-error"
                        >
                          <LogOut className="w-4 h-4" />
                          Đăng xuất
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </header>
        {/* Main Content */}
        <main className="flex-1 p-6 overflow-auto">{children}</main>
        {/* Footer */}
        <footer className="theme-bg-card border-t theme-border p-6">
          <div className="max-w-7xl mx-auto">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mb-8">
              <div>
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
                    <Globe className="w-5 h-5 text-white" />
                  </div>
                  <h3 className="text-lg font-bold theme-text-primary">
                    TRIPFINITY
                  </h3>
                </div>
                <p className="theme-text-secondary text-sm leading-relaxed mb-4">
                  Nền tảng booking du lịch hàng đầu Việt Nam cùng với những sản
                  phẩm khuyến mại về các chương trình cộng với dịch vụ uy tín
                  hàng cao. Tại nghiệp du lịch thính như là điểm tốt.
                </p>
              </div>
              <div>
                <h4 className="font-semibold theme-text-primary mb-4">
                  Dịch vụ
                </h4>
                <div className="space-y-2 text-sm theme-text-secondary">
                  <div>Đặt phòng</div>
                  <div>Đặt vé máy bay</div>
                  <div>Thuê xe</div>
                  <div>Tour du lịch</div>
                  <div>Khám phá</div>
                </div>
              </div>
              <div>
                <h4 className="font-semibold theme-text-primary mb-4">
                  Hỗ trợ
                </h4>
                <div className="space-y-2 text-sm theme-text-secondary">
                  <div>Liên hệ</div>
                  <div>Câu hỏi thường gặp</div>
                  <div>Chính sách</div>
                  <div>Điều khoản sử dụng</div>
                </div>
              </div>
              <div>
                <h4 className="font-semibold theme-text-primary mb-4">
                  Tải ứng dụng
                </h4>
                <div className="space-y-3">
                  <button className="flex items-center gap-3 p-3 theme-bg-secondary rounded-xl w-full hover:shadow-md transition-all">
                    <Smartphone className="w-5 h-5 theme-text-brand" />
                    <div className="text-left">
                      <div className="text-xs theme-text-secondary">Tải từ</div>
                      <div className="text-sm font-medium theme-text-primary">
                        App Store
                      </div>
                    </div>
                  </button>
                  <button className="flex items-center gap-3 p-3 theme-bg-secondary rounded-xl w-full hover:shadow-md transition-all">
                    <Monitor className="w-5 h-5 theme-text-brand" />
                    <div className="text-left">
                      <div className="text-xs theme-text-secondary">Tải từ</div>
                      <div className="text-sm font-medium theme-text-primary">
                        Google Play
                      </div>
                    </div>
                  </button>
                </div>
              </div>
            </div>
            <div className="pt-6 border-t theme-border flex flex-col md:flex-row items-center justify-between gap-4">
              <p className="theme-text-secondary text-sm">
                © 2025 Tripfinity. Bản quyền thuộc về chúng tôi.
              </p>
              <div className="flex items-center gap-6 text-sm theme-text-secondary">
                <span>Chính sách</span>
                <span>Điều khoản</span>
                <span>Cookie</span>
                <span>Bảo mật</span>
              </div>
            </div>
          </div>
        </footer>
      </div>
      {/* Mobile Sidebar Overlay */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-40 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}
    </div>
  );
};

export default MainLayout;
