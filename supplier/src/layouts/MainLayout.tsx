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
  ChevronLeft,
  ChevronRight,
  Sun,
  Moon,
  Languages,
} from "lucide-react";
import type { LoginResponse } from "../types";
import { logoutSupplier } from "../services/supplierAuthService";
import { useTheme } from "../hooks/useTheme";
import { useLanguage } from "../hooks/useLanguage";

const sidebarMenuItems = [
  { icon: Globe, label: "Trang chủ", to: "/supplier" },
  { icon: Settings, label: "Cài đặt", to: "/supplier/settings" },
];

const SidebarMenuItem = ({
  icon: Icon,
  label,
  to,
  active,
  collapsed,
}: {
  icon: React.ElementType;
  label: string;
  to: string;
  active?: boolean;
  collapsed?: boolean;
}) => (
  <a
    href={to}
    className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-all duration-200 ${
      active
        ? "theme-bg-primary theme-text-button font-semibold"
        : "hover:theme-bg-secondary theme-text-secondary hover:theme-text-primary"
    } ${collapsed ? "justify-center" : ""}`}
    title={collapsed ? label : undefined}
  >
    <Icon className="w-5 h-5 flex-shrink-0" />
    {!collapsed && <span className="flex-1">{label}</span>}
  </a>
);

interface MainLayoutProps {
  children: ReactNode;
}

const MainLayout: React.FC<MainLayoutProps> = ({ children }) => {
  const navigate = useNavigate();
  const { dark, toggleTheme } = useTheme();
  const { currentLanguageData, availableLanguages, changeLanguage } =
    useLanguage();

  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(() => {
    const saved = localStorage.getItem("sidebarCollapsed");
    return saved === "true";
  });
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [languageMenuOpen, setLanguageMenuOpen] = useState(false);

  // Save sidebar collapsed state to localStorage
  useEffect(() => {
    localStorage.setItem("sidebarCollapsed", sidebarCollapsed.toString());
  }, [sidebarCollapsed]);

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

  // Close menus if not authenticated
  useEffect(() => {
    if (!authUser) {
      setUserMenuOpen(false);
      setLanguageMenuOpen(false);
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
      setLanguageMenuOpen(false);
      navigate("/supplier/login", { replace: true });
    }
  };

  // Toggle sidebar collapse
  const toggleSidebarCollapse = () => {
    setSidebarCollapsed(!sidebarCollapsed);
  };

  // Handle language change
  const handleLanguageChange = (langCode: string) => {
    changeLanguage(langCode);
    setLanguageMenuOpen(false);
  };

  // Don't render layout if not authenticated
  if (!authUser) {
    return null;
  }

  const sidebarWidth = sidebarCollapsed ? "w-16" : "w-64";

  return (
    <div className="theme-bg-background min-h-screen flex">
      {/* Sidebar */}
      <div
        className={`fixed inset-y-0 left-0 z-50 ${sidebarWidth} border-r theme-border transform transition-all duration-300 lg:translate-x-0 lg:static lg:inset-0 ${
          sidebarOpen ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        <div className="flex flex-col h-full">
          {/* Logo & Collapse Button */}
          <div
            className={`flex items-center gap-3 p-5 border-b theme-border ${
              sidebarCollapsed ? "justify-center" : ""
            }`}
          >
            {/* Logo */}
            <div className="flex items-center gap-3 flex-1 min-w-0">
              <div className="w-10 h-10 flex items-center justify-center overflow-hidden">
                <div
                  className={`${
                    sidebarCollapsed ? "w-8 h-8" : "w-10 h-10"
                  }  bg-light-background rounded-lg flex items-center justify-center shadow-sm border border-gray-100 p-1`}
                >
                  <img
                    src="/logo.png"
                    alt="Tripfinity"
                    className={`${
                      sidebarCollapsed ? "w-6 h-6" : "w-8 h-8"
                    } object-contain`}
                    onError={(e) => {
                      // Fallback to Globe icon if image fails to load
                      e.currentTarget.style.display = "none";
                      e.currentTarget.parentElement?.classList.add("hidden");
                      e.currentTarget.parentElement?.nextElementSibling?.classList.remove(
                        "hidden"
                      );
                    }}
                  />
                </div>
                <div className="w-6 h-6 theme-bg-secondary rounded-lg items-center justify-center hidden">
                  <Globe className="w-4 h-4 theme-text-secondary" />
                </div>
              </div>
              {!sidebarCollapsed && (
                <div className="min-w-0 flex-1">
                  <h1 className="text-xl font-bold theme-text-primary truncate">
                    Tripfinity
                  </h1>
                </div>
              )}
            </div>

            {/* Collapse Button - Hidden on mobile */}
            <button
              onClick={toggleSidebarCollapse}
              className="hidden lg:flex w-8 h-8 items-center justify-center rounded-lg hover:theme-bg-secondary transition-colors theme-text-secondary "
              title={sidebarCollapsed ? "Mở rộng sidebar" : "Thu gọn sidebar"}
            >
              {sidebarCollapsed ? (
                <ChevronRight className="w-5 h-5" />
              ) : (
                <ChevronLeft className="w-5 h-5" />
              )}
            </button>
          </div>

          {/* Navigation */}
          <nav
            className={`flex-1 p-4 space-y-2 ${sidebarCollapsed ? "px-2" : ""}`}
          >
            {sidebarMenuItems.map((item, index) => (
              <SidebarMenuItem
                key={index}
                icon={item.icon}
                label={item.label}
                to={item.to}
                active={window.location.pathname === item.to}
                collapsed={sidebarCollapsed}
              />
            ))}
          </nav>

          {/* User Profile */}
          <div
            className={`p-4 border-t theme-border ${
              sidebarCollapsed ? "px-2" : ""
            }`}
          >
            {sidebarCollapsed ? (
              <div className="flex items-center justify-center">
                <div
                  className="w-10 h-10 theme-bg-primary rounded-full flex items-center justify-center theme-text-button font-semibold cursor-pointer"
                  title={`${authUser.name || "Người dùng"} (${authUser.email})`}
                >
                  {authUser.name?.[0]?.toUpperCase() ||
                    authUser.email?.[0]?.toUpperCase() ||
                    "U"}
                </div>
              </div>
            ) : (
              <div className="flex items-center gap-3 p-3 theme-bg-secondary rounded-xl">
                <div className="w-10 h-10 theme-bg-primary rounded-full flex items-center justify-center theme-text-button font-semibold">
                  {authUser.name?.[0]?.toUpperCase() ||
                    authUser.email?.[0]?.toUpperCase() ||
                    "U"}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="theme-text-primary font-semibold truncate">
                    {authUser.name || "Người dùng"}
                  </p>
                  <p className="theme-text-secondary text-sm truncate">
                    {authUser.email}
                  </p>
                </div>
              </div>
            )}
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
            <div className="flex items-center gap-2">
              {/* Theme Toggle Button - YouTube Style */}
              <button
                onClick={toggleTheme}
                className="relative p-2 rounded-full hover:theme-bg-secondary transition-colors theme-text-secondary hover:theme-text-primary focus-ring-primary"
                title={
                  dark ? "Chuyển sang chế độ sáng" : "Chuyển sang chế độ tối"
                }
              >
                {dark ? (
                  <Sun className="w-5 h-5" />
                ) : (
                  <Moon className="w-5 h-5" />
                )}
              </button>

              {/* Language Toggle Button - YouTube Style */}
              <div className="relative">
                <button
                  onClick={() => setLanguageMenuOpen(!languageMenuOpen)}
                  className="flex items-center gap-2 p-2 rounded-full hover:theme-bg-secondary transition-colors theme-text-secondary hover:theme-text-primary focus-ring-primary"
                  title="Chuyển đổi ngôn ngữ"
                >
                  <Languages className="w-5 h-5" />
                  <span className="text-sm font-medium hidden sm:block">
                    {currentLanguageData.flag}
                  </span>
                </button>
                {languageMenuOpen && (
                  <div className="absolute right-0 top-full mt-2 min-w-48 theme-bg-card border theme-border rounded-2xl shadow-lg py-2 z-50">
                    <div className="px-4 py-2">
                      <p className="theme-text-secondary text-sm font-medium">
                        Chọn ngôn ngữ
                      </p>
                    </div>
                    <div className="border-t theme-border pt-2">
                      {availableLanguages.map((language) => (
                        <button
                          key={language.code}
                          onClick={() => handleLanguageChange(language.code)}
                          className={`w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary transition-colors text-left ${
                            currentLanguageData.code === language.code
                              ? "theme-text-primary font-medium"
                              : "theme-text-secondary"
                          }`}
                        >
                          <span className="text-lg">{language.flag}</span>
                          <span className="flex-1 truncate">
                            {language.name}
                          </span>
                          {currentLanguageData.code === language.code && (
                            <div className="w-2 h-2 theme-bg-primary rounded-full"></div>
                          )}
                        </button>
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {/* Notifications */}
              <button className="relative p-2 rounded-full hover:theme-bg-secondary transition-colors theme-text-secondary hover:theme-text-primary focus-ring-primary">
                <Bell className="w-5 h-5" />
                <span className="absolute -top-1 -right-1 w-5 h-5 theme-bg-error theme-text-button text-xs rounded-full flex items-center justify-center">
                  3
                </span>
              </button>

              {/* User Menu */}
              <div className="relative">
                <button
                  onClick={() => setUserMenuOpen(!userMenuOpen)}
                  className="flex items-center gap-3 p-2 rounded-xl hover:theme-bg-secondary transition-colors focus-ring-primary"
                >
                  <div className="w-8 h-8 theme-bg-primary rounded-full flex items-center justify-center theme-text-button font-semibold text-sm">
                    {authUser.name?.[0]?.toUpperCase() ||
                      authUser.email?.[0]?.toUpperCase() ||
                      "U"}
                  </div>
                  <ChevronDown className="w-4 h-4 theme-text-secondary" />
                </button>
                {userMenuOpen && (
                  <div className="absolute right-0 top-full mt-2 min-w-64 max-w-80 theme-bg-card border theme-border rounded-2xl shadow-lg py-2 z-50">
                    <div className="px-4 py-3 border-b theme-border">
                      <p className="theme-text-primary font-semibold truncate">
                        {authUser.name || "Người dùng"}
                      </p>
                      <p className="theme-text-secondary text-sm break-all">
                        {authUser.email}
                      </p>
                    </div>
                    <div className="py-2">
                      <button className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-primary transition-colors text-left">
                        <User className="w-4 h-4 flex-shrink-0" />
                        <span className="truncate">Thông tin tài khoản</span>
                      </button>
                      <button className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-primary transition-colors text-left">
                        <Settings className="w-4 h-4 flex-shrink-0" />
                        <span className="truncate">Cài đặt</span>
                      </button>
                      <button className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-primary transition-colors text-left">
                        <HelpCircle className="w-4 h-4 flex-shrink-0" />
                        <span className="truncate">Hỗ trợ</span>
                      </button>
                      <hr className="my-2 theme-border" />
                      <button
                        onClick={handleLogout}
                        className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-error transition-colors text-left"
                      >
                        <LogOut className="w-4 h-4 flex-shrink-0" />
                        <span className="truncate">Đăng xuất</span>
                      </button>
                    </div>
                  </div>
                )}
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
                  <div className="w-8 h-8 theme-bg-primary rounded-lg flex items-center justify-center">
                    <Globe className="w-5 h-5 theme-text-button" />
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
                  <button className="flex items-center gap-3 p-3 theme-bg-secondary rounded-xl w-full hover:opacity-80 transition-all">
                    <Smartphone className="w-5 h-5 theme-text-brand" />
                    <div className="text-left">
                      <div className="text-xs theme-text-secondary">Tải từ</div>
                      <div className="text-sm font-semibold theme-text-primary">
                        App Store
                      </div>
                    </div>
                  </button>
                  <button className="flex items-center gap-3 p-3 theme-bg-secondary rounded-xl w-full hover:opacity-80 transition-all">
                    <Monitor className="w-5 h-5 theme-text-brand" />
                    <div className="text-left">
                      <div className="text-xs theme-text-secondary">Tải từ</div>
                      <div className="text-sm font-semibold theme-text-primary">
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
          className="overlay lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Close dropdowns when clicking outside */}
      {(userMenuOpen || languageMenuOpen) && (
        <div
          className="fixed inset-0 z-30"
          onClick={() => {
            setUserMenuOpen(false);
            setLanguageMenuOpen(false);
          }}
        />
      )}
    </div>
  );
};

export default MainLayout;
