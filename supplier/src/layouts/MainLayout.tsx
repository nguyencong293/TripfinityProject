import React, { useState, useEffect, useRef } from "react";
import type { ReactNode } from "react";
import { Link, useNavigate } from "react-router-dom";
import {
  Bell,
  User,
  LogOut,
  Settings,
  HelpCircle,
  ChevronDown,
  Menu,
  Globe,
  ChevronLeft,
  ChevronRight,
  Sun,
  Moon,
  Languages,
  BarChart3,
  Plus,
  MessageSquare,
  LifeBuoy,
  MapPin,
  Utensils,
  Building2,
  Route,
} from "lucide-react";
import type { LoginResponse } from "../types";
import { logoutSupplier } from "../services/supplierAuthService";
import { useTheme } from "../hooks/useTheme";
import { useLanguage } from "../hooks/useLanguage";

// Navigation menu items with badges
const sidebarMenuItems = [
  {
    icon: BarChart3,
    label: "dashboard",
    to: "/supplier",
    badge: null,
  },
  {
    icon: Route,
    label: "tour",
    to: "/supplier/service/tour",
    badge: null,
  },
  {
    icon: Building2,
    label: "hotel",
    to: "/supplier/service/hotel",
    badge: null,
  },
  {
    icon: Utensils,
    label: "restaurant",
    to: "/supplier/service/restaurant",
    badge: null,
  },
  {
    icon: MapPin,
    label: "attraction",
    to: "/supplier/service/attraction",
    badge: null,
  },
  {
    icon: MessageSquare,
    label: "messages_inbox",
    to: "/supplier/messages",
    badge: "unreadMessages",
  },
  {
    icon: Settings,
    label: "settings",
    to: "/supplier/settings",
    badge: null,
  },
  {
    icon: LifeBuoy,
    label: "support_tickets",
    to: "/supplier/support",
    badge: "openTickets",
  },
];

// Mock badge data - this would come from your state management/API
const mockBadgeData = {
  totalPublishedListings: 24,
  pendingBookings: 5,
  unreadMessages: 3,
  newReviews: 2,
  openTickets: 1,
};

const SidebarMenuItem = ({
  icon: Icon,
  label,
  to,
  active,
  collapsed,
  badge,
  badgeCount,
  isDropdown,
  dropdownItems,
  onDropdownToggle,
  dropdownOpen,
  t,
}: {
  icon: React.ElementType;
  label: string;
  to: string;
  active?: boolean;
  collapsed?: boolean;
  badge?: string | null;
  badgeCount?: number;
  isDropdown?: boolean;
  dropdownItems?: { labelKey: string; icon: React.ElementType; to: string }[];
  onDropdownToggle?: () => void;
  dropdownOpen?: boolean;
  t: (key: string) => string;
}) => {
  const handleClick = (e: React.MouseEvent) => {
    if (isDropdown) {
      e.preventDefault();
      onDropdownToggle?.();
    }
  };

  return (
    <div>
      <a
        href={to}
        onClick={handleClick}
        className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-all duration-200 ${
          active
            ? "theme-bg-primary theme-text-button font-semibold"
            : "hover:theme-bg-secondary theme-text-secondary hover:theme-text-primary"
        } ${collapsed ? "justify-center" : ""}`}
        title={collapsed ? t(label) : undefined}
      >
        <Icon className="w-5 h-5 flex-shrink-0" />
        {!collapsed && (
          <>
            <span className="flex-1 text-body1-mobile md:text-body1-tablet lg:text-body1-desktop">
              {t(label)}
            </span>
            {/* Badge */}
            {badge && badgeCount && badgeCount > 0 && (
              <span className="bg-red-500 text-white text-caption-mobile md:text-caption-tablet lg:text-caption-desktop rounded-full px-2 py-1 min-w-[20px] text-center">
                {badgeCount > 99 ? "99+" : badgeCount}
              </span>
            )}
            {/* Dropdown arrow */}
            {isDropdown && (
              <ChevronDown
                className={`w-4 h-4 transition-transform ${
                  dropdownOpen ? "rotate-180" : ""
                }`}
              />
            )}
          </>
        )}
      </a>

      {/* Dropdown items */}
      {isDropdown && dropdownOpen && !collapsed && dropdownItems && (
        <div className="mt-1 ml-8 space-y-1">
          {dropdownItems.map((item, index) => {
            const ItemIcon = item.icon;
            return (
              <a
                key={index}
                href={item.to}
                className="flex items-center gap-3 px-4 py-2 text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary hover:theme-text-primary hover:theme-bg-secondary rounded-lg transition-colors"
              >
                <ItemIcon className="w-4 h-4 flex-shrink-0" />
                <span>{t(item.labelKey)}</span>
              </a>
            );
          })}
        </div>
      )}
    </div>
  );
};

interface MainLayoutProps {
  children: ReactNode;
}

const MainLayout: React.FC<MainLayoutProps> = ({ children }) => {
  const navigate = useNavigate();
  const { dark, toggleTheme } = useTheme();
  const { currentLanguageData, availableLanguages, changeLanguage, t } =
    useLanguage();

  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [unreadCount, setUnreadCount] = useState<number>(0);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(() => {
    const saved = localStorage.getItem("sidebarCollapsed");
    return saved === "true";
  });
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [languageMenuOpen, setLanguageMenuOpen] = useState(false);
  const [openDropdowns, setOpenDropdowns] = useState<Set<number>>(new Set());
  const [quickCreateOpen, setQuickCreateOpen] = useState(false);
  const [notificationMenuOpen, setNotificationMenuOpen] = useState(false);
  const [notifications, setNotifications] = useState<Array<{
    notification_id: number;
    title: string;
    content: string;
    sent_at: string;
    is_read: boolean;
  }>>([]);
  const notificationRef = useRef<HTMLDivElement>(null);

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

  // Fetch unread notification count and recent notifications
  useEffect(() => {
    const fetchNotifications = async () => {
      if (!authUser?.userId) return;

      try {
        // Fetch unread count
        const countResponse = await fetch(
          `http://localhost:8080/api/notifications/user/${authUser.userId}/unread/count`
        );
        if (countResponse.ok) {
          const countData = await countResponse.json();
          setUnreadCount(countData.count || 0);
        }

        // Fetch recent notifications for popup
        const notifResponse = await fetch(
          `http://localhost:8080/api/notifications/user/${authUser.userId}/recent?limit=5`
        );
        if (notifResponse.ok) {
          const notifData = await notifResponse.json();
          setNotifications(notifData);
        }
      } catch (error) {
        console.error("Failed to fetch notifications:", error);
      }
    };

    fetchNotifications();
    // Refresh every 30 seconds
    const interval = setInterval(fetchNotifications, 30000);
    return () => clearInterval(interval);
  }, [authUser]);

  // Close notification popup when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        notificationRef.current &&
        !notificationRef.current.contains(event.target as Node)
      ) {
        setNotificationMenuOpen(false);
      }
    };

    if (notificationMenuOpen) {
      document.addEventListener("mousedown", handleClickOutside);
    }

    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [notificationMenuOpen]);

  // Close menus if not authenticated
  useEffect(() => {
    if (!authUser) {
      setUserMenuOpen(false);
      setLanguageMenuOpen(false);
      setQuickCreateOpen(false);
      setNotificationMenuOpen(false);
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
      setQuickCreateOpen(false);
      setNotificationMenuOpen(false);
      navigate("/supplier/login", { replace: true });
    }
  };

  // Toggle sidebar collapse
  const toggleSidebarCollapse = () => {
    setSidebarCollapsed(!sidebarCollapsed);
    // Close all dropdowns when collapsing
    if (!sidebarCollapsed) {
      setOpenDropdowns(new Set());
    }
  };

  // Handle language change
  const handleLanguageChange = (langCode: string) => {
    changeLanguage(langCode);
    setLanguageMenuOpen(false);
  };

  // Handle dropdown toggle
  const handleDropdownToggle = (index: number) => {
    const newOpenDropdowns = new Set(openDropdowns);
    if (newOpenDropdowns.has(index)) {
      newOpenDropdowns.delete(index);
    } else {
      newOpenDropdowns.add(index);
    }
    setOpenDropdowns(newOpenDropdowns);
  };

  // Format notification time
  const formatNotificationTime = (dateString: string): string => {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMins / 60);
    const diffDays = Math.floor(diffHours / 24);

    if (diffMins < 1) return t("just_now") || "Vừa xong";
    if (diffMins < 60) return `${diffMins} ${t("minutes_ago_suffix") || "phút trước"}`;
    if (diffHours < 24) return `${diffHours} ${t("hours_ago_suffix") || "giờ trước"}`;
    return `${diffDays} ${t("days_ago_suffix") || "ngày trước"}`;
  };

  // Handle quick create
  const handleQuickCreate = () => {
    // Check user permissions here
    setQuickCreateOpen(!quickCreateOpen);
  };

  // Don't render layout if not authenticated
  if (!authUser) {
    return null;
  }

  const sidebarWidth = sidebarCollapsed ? "w-16" : "w-64";
  const currentPath = window.location.pathname;

  return (
    <div className="theme-bg-background min-h-screen flex">
      {/* Sidebar */}
      <div
        className={`fixed inset-y-0 left-0 z-50 ${sidebarWidth} border-r theme-border transform transition-all duration-300 lg:translate-x-0 lg:static lg:inset-0 ${
          sidebarOpen ? "translate-x-0" : "-translate-x-full"
        } theme-bg-background`}
      >
        <div className="flex flex-col h-full">
          {/* Logo & Collapse Button */}
          <div
            className={`flex items-center gap-3 p-3.5 border-b theme-border relative ${
              sidebarCollapsed ? "justify-center" : ""
            }`}
          >
            {/* Logo */}
            <Link 
              to="/supplier" 
              className="flex items-center gap-3 cursor-pointer hover:opacity-80 transition-opacity flex-1 min-w-0"
            >
              <div className="w-10 h-10 flex items-center justify-center overflow-hidden flex-shrink-0">
                <div
                  className={`${
                    sidebarCollapsed ? "w-8 h-8" : "w-10 h-10"
                  } bg-light-background rounded-lg flex items-center justify-center shadow-sm border border-gray-100 p-1`}
                >
                  <img
                    src="/logo.png"
                    alt="Tripfinity"
                    className={`${
                      sidebarCollapsed ? "w-6 h-6" : "w-8 h-8"
                    } object-contain`}
                    onError={(e) => {
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
                  <h1 className="text-h4-mobile md:text-h4-tablet lg:text-h4-desktop font-bold theme-text-primary truncate">
                    Tripfinity
                  </h1>
                  <p className="text-caption-mobile md:text-caption-tablet lg:text-caption-desktop theme-text-secondary truncate">
                    {t("provider_console")}
                  </p>
                </div>
              )}
            </Link>

            {/* Collapse Button - Hidden on mobile, positioned absolutely when collapsed */}
            <button
              onClick={toggleSidebarCollapse}
              className={`hidden lg:flex w-8 h-8 items-center justify-center rounded-lg hover:theme-bg-secondary transition-colors theme-text-secondary ${
                sidebarCollapsed ? "absolute right-1 top-1/2 -translate-y-1/2 z-10" : ""
              }`}
              title={
                sidebarCollapsed ? t("expand_sidebar") : t("collapse_sidebar")
              }
            >
              {sidebarCollapsed ? (
                <ChevronRight className="w-5 h-5" />
              ) : (
                <ChevronLeft className="w-5 h-5" />
              )}
            </button>
          </div>

          {/* Quick Create Button - Always Visible */}
          <div
            className={`p-4 border-b theme-border ${
              sidebarCollapsed ? "px-2" : ""
            }`}
          >
            <div className="relative">
              <button
                onClick={handleQuickCreate}
                className={`w-full btn-primary flex items-center gap-2 px-4 py-3 text-button-mobile md:text-button-tablet lg:text-button-desktop ${
                  sidebarCollapsed ? "justify-center" : ""
                }`}
                title={sidebarCollapsed ? t("quick_create") : undefined}
              >
                <Plus className="w-5 h-5" />
                {!sidebarCollapsed && <span>{t("quick_create")}</span>}
                {!sidebarCollapsed && (
                  <ChevronDown className="w-4 h-4 ml-auto" />
                )}
              </button>

              {/* Quick Create Dropdown */}
              {quickCreateOpen && !sidebarCollapsed && (
                <div className="absolute top-full left-0 right-0 mt-2 theme-bg-card border theme-border rounded-xl shadow-lg py-2 z-50">
                  <a
                    href="/provider/:id/create/tour"
                    className="flex items-center gap-3 px-4 py-2 text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary hover:theme-text-primary hover:theme-bg-secondary"
                  >
                    <Route className="w-4 h-4 flex-shrink-0" />
                    <span>
                      {t("create")} {t("tour")}
                    </span>
                  </a>
                  <a
                    href="/provider/:id/create/hotel"
                    className="flex items-center gap-3 px-4 py-2 text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary hover:theme-text-primary hover:theme-bg-secondary"
                  >
                    <Building2 className="w-4 h-4 flex-shrink-0" />
                    <span>
                      {t("create")} {t("hotel")}
                    </span>
                  </a>
                  <a
                    href="/provider/:id/create/restaurant"
                    className="flex items-center gap-3 px-4 py-2 text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary hover:theme-text-primary hover:theme-bg-secondary"
                  >
                    <Utensils className="w-4 h-4 flex-shrink-0" />
                    <span>
                      {t("create")} {t("restaurant")}
                    </span>
                  </a>
                  <a
                    href="/provider/:id/create/attraction"
                    className="flex items-center gap-3 px-4 py-2 text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary hover:theme-text-primary hover:theme-bg-secondary"
                  >
                    <MapPin className="w-4 h-4 flex-shrink-0" />
                    <span>
                      {t("create")} {t("attraction")}
                    </span>
                  </a>
                  <hr className="my-2 theme-border" />
                  <a
                    href="/provider/:id/create/bulk-import"
                    className="flex items-center gap-3 px-4 py-2 text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary hover:theme-text-primary hover:theme-bg-secondary"
                  >
                    <Plus className="w-4 h-4 flex-shrink-0" />
                    <span>{t("bulk_import")}</span>
                  </a>
                </div>
              )}
            </div>
          </div>

          {/* Navigation */}
          <nav
            className={`flex-1 overflow-y-auto p-4 space-y-1 ${
              sidebarCollapsed ? "px-2" : ""
            }`}
          >
            {sidebarMenuItems.map((item, index) => {
              // Logic kiểm tra active chính xác hơn
              let isActive = false;

              if (item.to === "/supplier") {
                // Dashboard chỉ active khi path chính xác là /supplier
                isActive = currentPath === "/supplier";
              } else if (item.to === "#") {
                // Dropdown: kiểm tra xem có dropdown item nào active không
                isActive =
                  item.dropdownItems?.some(
                    (dropdownItem) =>
                      currentPath === dropdownItem.to ||
                      currentPath.startsWith(dropdownItem.to + "/")
                  ) || false;
              } else {
                // Các menu item khác: exact match hoặc startsWith + "/"
                isActive =
                  currentPath === item.to ||
                  currentPath.startsWith(item.to + "/");
              }

              return (
                <SidebarMenuItem
                  key={index}
                  icon={item.icon}
                  label={item.label}
                  to={item.to}
                  active={isActive}
                  collapsed={sidebarCollapsed}
                  badge={item.badge}
                  badgeCount={
                    item.badge
                      ? mockBadgeData[item.badge as keyof typeof mockBadgeData]
                      : undefined
                  }
                  isDropdown={item.isDropdown}
                  dropdownItems={item.dropdownItems}
                  onDropdownToggle={() => handleDropdownToggle(index)}
                  dropdownOpen={openDropdowns.has(index)}
                  t={t}
                />
              );
            })}
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
                  className="w-10 h-10 theme-bg-primary rounded-full flex items-center justify-center theme-text-button text-subtitle2-mobile md:text-subtitle2-tablet lg:text-subtitle2-desktop font-semibold cursor-pointer"
                  title={`${authUser.name || t("user")} (${authUser.email})`}
                >
                  {authUser.name?.[0]?.toUpperCase() ||
                    authUser.email?.[0]?.toUpperCase() ||
                    "U"}
                </div>
              </div>
            ) : (
              <div className="flex items-center gap-3 p-3 theme-bg-secondary rounded-xl">
                <div className="w-10 h-10 theme-bg-primary rounded-full flex items-center justify-center theme-text-button text-subtitle2-mobile md:text-subtitle2-tablet lg:text-subtitle2-desktop font-semibold">
                  {authUser.name?.[0]?.toUpperCase() ||
                    authUser.email?.[0]?.toUpperCase() ||
                    "U"}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="theme-text-primary text-subtitle1-mobile md:text-subtitle1-tablet lg:text-subtitle1-desktop font-semibold truncate">
                    {authUser.name || t("user")}
                  </p>
                  <p className="theme-text-secondary text-body2-mobile md:text-body2-tablet lg:text-body2-desktop truncate">
                    {authUser.email}
                  </p>
                </div>
              </div>
            )}
          </div>

          {/* Logout / Switch View */}
          <div
            className={`p-4 border-t theme-border ${
              sidebarCollapsed ? "px-2" : ""
            }`}
          >
            <div className="space-y-2">
              <button
                onClick={() => navigate("/supplier")}
                className={`w-full flex items-center gap-3 px-4 py-2 rounded-lg hover:theme-bg-secondary theme-text-secondary hover:theme-text-primary transition-colors ${
                  sidebarCollapsed ? "justify-center" : ""
                }`}
                title={sidebarCollapsed ? t("switch_view") : undefined}
              >
                <Globe className="w-4 h-4" />
                {!sidebarCollapsed && (
                  <span className="text-body2-mobile md:text-body2-tablet lg:text-body2-desktop">
                    {t("switch_view")}
                  </span>
                )}
              </button>
              <button
                onClick={handleLogout}
                className={`w-full flex items-center gap-3 px-4 py-2 rounded-lg hover:theme-bg-secondary theme-text-error transition-colors ${
                  sidebarCollapsed ? "justify-center" : ""
                }`}
                title={sidebarCollapsed ? t("logout") : undefined}
              >
                <LogOut className="w-4 h-4" />
                {!sidebarCollapsed && (
                  <span className="text-body2-mobile md:text-body2-tablet lg:text-body2-desktop">
                    {t("logout")}
                  </span>
                )}
              </button>
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
            <div className="flex items-center gap-2">
              {/* Theme Toggle Button */}
              <button
                onClick={toggleTheme}
                className="relative p-2 rounded-full hover:theme-bg-secondary transition-colors theme-text-secondary hover:theme-text-primary focus-ring-primary"
                title={dark ? t("switch_to_light") : t("switch_to_dark")}
              >
                {dark ? (
                  <Sun className="w-5 h-5" />
                ) : (
                  <Moon className="w-5 h-5" />
                )}
              </button>

              {/* Language Toggle Button */}
              <div className="relative">
                <button
                  onClick={() => setLanguageMenuOpen(!languageMenuOpen)}
                  className="flex items-center gap-2 p-2 rounded-full hover:theme-bg-secondary transition-colors theme-text-secondary hover:theme-text-primary focus-ring-primary"
                  title={t("switch_language")}
                >
                  <Languages className="w-5 h-5" />
                  <span className="text-body2-mobile md:text-body2-tablet lg:text-body2-desktop font-medium hidden sm:block">
                    {currentLanguageData.flag}
                  </span>
                </button>
                {languageMenuOpen && (
                  <div className="absolute right-0 top-full mt-2 min-w-48 theme-bg-card border theme-border rounded-2xl shadow-lg py-2 z-50">
                    <div className="px-4 py-2">
                      <p className="theme-text-secondary text-body2-mobile md:text-body2-tablet lg:text-body2-desktop font-medium">
                        {t("select_language")}
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
                          <span className="text-subtitle1-mobile md:text-subtitle1-tablet lg:text-subtitle1-desktop">
                            {language.flag}
                          </span>
                          <span className="flex-1 truncate text-body1-mobile md:text-body1-tablet lg:text-body1-desktop">
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
              <div className="relative" ref={notificationRef}>
                <button
                  onClick={() => setNotificationMenuOpen(!notificationMenuOpen)}
                  className="relative p-2 rounded-full hover:theme-bg-secondary transition-colors theme-text-secondary hover:theme-text-primary focus-ring-primary"
                >
                  <Bell className="w-5 h-5" />
                  {unreadCount > 0 && (
                    <span className="absolute -top-1 -right-1 w-5 h-5 theme-bg-error theme-text-error text-caption-mobile md:text-caption-tablet lg:text-caption-desktop rounded-full flex items-center justify-center">
                      {unreadCount > 99 ? "99+" : unreadCount}
                    </span>
                  )}
                </button>
                {notificationMenuOpen && (
                  <div className="absolute right-0 top-full mt-2 w-96 theme-bg-card border theme-border rounded-2xl shadow-lg z-50 overflow-hidden">
                    {/* Header */}
                    <div className="px-4 py-3 border-b theme-border flex items-center justify-between">
                      <h3 className="text-lg font-semibold theme-text-primary">
                        {t("notifications") || "Thông báo"}
                      </h3>
                      {unreadCount > 0 && (
                        <span className="px-2 py-0.5 text-xs font-medium theme-bg-primary theme-text-button rounded-full">
                          {unreadCount}
                        </span>
                      )}
                    </div>
                    {/* Notification List */}
                    <div className="max-h-96 overflow-y-auto">
                      {notifications.length === 0 ? (
                        <div className="px-4 py-8 text-center">
                          <Bell className="w-12 h-12 theme-text-tertiary mx-auto mb-2" />
                          <p className="theme-text-secondary text-sm">
                            {t("no_notifications") || "Không có thông báo mới"}
                          </p>
                        </div>
                      ) : (
                        notifications.map((notif) => (
                          <button
                            key={notif.notification_id}
                            onClick={() => {
                              if (!notif.is_read) {
                                fetch(
                                  `http://localhost:8080/api/notifications/${notif.notification_id}/read`,
                                  { method: "PATCH" }
                                );
                              }
                              setNotificationMenuOpen(false);
                              navigate("/supplier/notifications");
                            }}
                            className={`w-full px-4 py-3 text-left hover:theme-bg-secondary transition-colors border-b theme-border last:border-b-0 ${
                              !notif.is_read ? "bg-blue-50/50 dark:bg-blue-900/10" : ""
                            }`}
                          >
                            <div className="flex items-start gap-3">
                              <div className="flex-1 min-w-0">
                                <div className="flex items-center gap-2 mb-1">
                                  <h4 className="text-sm font-semibold theme-text-primary truncate">
                                    {notif.title}
                                  </h4>
                                  {!notif.is_read && (
                                    <span className="flex-shrink-0 w-2 h-2 bg-red-500 rounded-full"></span>
                                  )}
                                </div>
                                <p className="text-sm theme-text-secondary line-clamp-2">
                                  {notif.content}
                                </p>
                                <p className="text-xs theme-text-tertiary mt-1">
                                  {formatNotificationTime(notif.sent_at)}
                                </p>
                              </div>
                            </div>
                          </button>
                        ))
                      )}
                    </div>
                    {/* Footer */}
                    {notifications.length > 0 && (
                      <div className="px-4 py-3 border-t theme-border">
                        <button
                          onClick={() => {
                            setNotificationMenuOpen(false);
                            navigate("/supplier/notifications");
                          }}
                          className="w-full text-center text-sm font-medium link-brand hover:underline"
                        >
                          {t("view_all_notifications") || "Xem tất cả thông báo"}
                        </button>
                      </div>
                    )}
                  </div>
                )}
              </div>

              {/* User Menu */}
              <div className="relative">
                <button
                  onClick={() => setUserMenuOpen(!userMenuOpen)}
                  className="flex items-center gap-3 p-2 rounded-xl hover:theme-bg-secondary transition-colors focus-ring-primary"
                >
                  <div className="w-8 h-8 theme-bg-primary rounded-full flex items-center justify-center theme-text-button text-body2-mobile md:text-body2-tablet lg:text-body2-desktop font-semibold">
                    {authUser.name?.[0]?.toUpperCase() ||
                      authUser.email?.[0]?.toUpperCase() ||
                      "U"}
                  </div>
                  <ChevronDown className="w-4 h-4 theme-text-secondary" />
                </button>
                {userMenuOpen && (
                  <div className="absolute right-0 top-full mt-2 min-w-64 max-w-80 theme-bg-card border theme-border rounded-2xl shadow-lg py-2 z-50">
                    <div className="px-4 py-3 border-b theme-border">
                      <p className="theme-text-primary text-subtitle1-mobile md:text-subtitle1-tablet lg:text-subtitle1-desktop font-semibold truncate">
                        {authUser.name || t("user")}
                      </p>
                      <p className="theme-text-secondary text-body2-mobile md:text-body2-tablet lg:text-body2-desktop break-all">
                        {authUser.email}
                      </p>
                    </div>
                    <div className="py-2">
                      <Link
                        className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-primary transition-colors text-left"
                        to={"/supplier/profile"}
                      >
                        <User className="w-4 h-4 flex-shrink-0" />
                        <span className="truncate text-body1-mobile md:text-body1-tablet lg:text-body1-desktop">
                          {t("account_info")}
                        </span>
                      </Link>
                      <button className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-primary transition-colors text-left">
                        <Settings className="w-4 h-4 flex-shrink-0" />
                        <span className="truncate text-body1-mobile md:text-body1-tablet lg:text-body1-desktop">
                          {t("settings")}
                        </span>
                      </button>
                      <button className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-primary transition-colors text-left">
                        <HelpCircle className="w-4 h-4 flex-shrink-0" />
                        <span className="truncate text-body1-mobile md:text-body1-tablet lg:text-body1-desktop">
                          {t("support")}
                        </span>
                      </button>
                      <hr className="my-2 theme-border" />
                      <button
                        onClick={handleLogout}
                        className="w-full flex items-center gap-3 px-4 py-2 hover:theme-bg-secondary theme-text-error transition-colors text-left"
                      >
                        <LogOut className="w-4 h-4 flex-shrink-0" />
                        <span className="truncate text-body1-mobile md:text-body1-tablet lg:text-body1-desktop">
                          {t("logout")}
                        </span>
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
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8 mb-8">
              <div className="lg:col-span-2">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-10 h-10 bg-light-card rounded-lg flex items-center justify-center shadow-sm border border-gray-100 p-1">
                    <img
                      src="/logo.png"
                      alt="Tripfinity"
                      className="w-8 h-8 object-contain"
                      onError={(e) => {
                        e.currentTarget.style.display = "none";
                        e.currentTarget.parentElement?.classList.add("hidden");
                        e.currentTarget.parentElement?.nextElementSibling?.classList.remove(
                          "hidden"
                        );
                      }}
                    />
                  </div>
                  <h1 className="text-h4-mobile md:text-h4-tablet lg:text-h4-desktop font-bold theme-text-primary truncate">
                    Tripfinity {t("provider_console")}
                  </h1>
                </div>
                <p className="theme-text-secondary text-body1-mobile md:text-body1-tablet lg:text-body1-desktop leading-relaxed mb-4">
                  {t("footer_description")}
                </p>
              </div>
              <div>
                <h4 className="text-subtitle1-mobile md:text-subtitle1-tablet lg:text-subtitle1-desktop font-semibold theme-text-primary mb-4">
                  {t("quick_links")}
                </h4>
                <div className="space-y-2 text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary">
                  <div>{t("dashboard")}</div>
                  <div>{t("create_service")}</div>
                  <div>{t("manage_bookings")}</div>
                  <div>{t("view_analytics")}</div>
                </div>
              </div>
              <div>
                <h4 className="text-subtitle1-mobile md:text-subtitle1-tablet lg:text-subtitle1-desktop font-semibold theme-text-primary mb-4">
                  {t("support")}
                </h4>
                <div className="space-y-2 text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary">
                  <div>{t("help_center")}</div>
                  <div>{t("documentation")}</div>
                  <div>{t("api_reference")}</div>
                  <div>{t("contact_support")}</div>
                </div>
              </div>
              <div>
                <h4 className="text-subtitle1-mobile md:text-subtitle1-tablet lg:text-subtitle1-desktop font-semibold theme-text-primary mb-4">
                  {t("resources")}
                </h4>
                <div className="space-y-2 text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary">
                  <div>{t("best_practices")}</div>
                  <div>{t("integration_guide")}</div>
                  <div>{t("system_status")}</div>
                  <div>{t("changelog")}</div>
                </div>
              </div>
            </div>
            <div className="pt-6 border-t theme-border flex flex-col md:flex-row items-center justify-between gap-4">
              <p className="theme-text-secondary text-body2-mobile md:text-body2-tablet lg:text-body2-desktop">
                © 2025 Tripfinity {t("provider_console")}.{" "}
                {t("all_rights_reserved")}.
              </p>
              <div className="flex items-center gap-6 text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary">
                <span>{t("privacy_policy")}</span>
                <span>{t("terms_of_service")}</span>
                <span>{t("api_terms")}</span>
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
      {(userMenuOpen || languageMenuOpen || quickCreateOpen) && (
        <div
          className="fixed inset-0 z-30"
          onClick={() => {
            setUserMenuOpen(false);
            setLanguageMenuOpen(false);
            setQuickCreateOpen(false);
          }}
        />
      )}
    </div>
  );
};

export default MainLayout;
