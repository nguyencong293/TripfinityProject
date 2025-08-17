import React from "react";
import { NavLink, useLocation } from "react-router-dom";
interface MainLayoutProps {
  children: React.ReactNode;
}

const navItems: Array<{
  label: string;
  to: string;
  hasDropdown?: boolean;
}> = [
  { label: "Tổng Quan", to: "/overview" },
  { label: "Dịch Vụ", to: "/services", hasDropdown: true },
  { label: "Đặt chỗ", to: "/bookings", hasDropdown: true },
  { label: "Khách hàng", to: "/customers", hasDropdown: true },
  { label: "Tài chính", to: "/finance", hasDropdown: true },
];

const footerLinks: Array<{ label: string; to: string }> = [
  { label: "Giới thiệu", to: "/about" },
  { label: "Liên hệ", to: "/contact" },
  { label: "Bảo mật", to: "/privacy" },
  { label: "Cookies", to: "/cookies" },
  { label: "Trợ giúp", to: "/help" },
  { label: "Hỗ trợ", to: "/support" },
];

const MainLayout: React.FC<MainLayoutProps> = ({ children }) => {
  const location = useLocation();

  const isActiveStartsWith = (path: string) =>
    location.pathname === path || location.pathname.startsWith(path + "/");

  return (
    <div className="min-h-screen flex flex-col bg-white text-gray-900">
      {/* Skip link */}
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-2 focus:left-2 bg-black text-white px-4 py-2 rounded"
      >
        Bỏ qua nội dung điều hướng
      </a>

      {/* HEADER / TOP NAV */}
      <header className="sticky top-0 z-40 border-b border-gray-200 bg-white/90 backdrop-blur supports-[backdrop-filter]:bg-white/60">
        <div className="mx-auto max-w-[1280px] px-6">
          <div className="flex h-16 items-center justify-between gap-6">
            {/* Logo */}
            <div className="flex items-center gap-3">
              <div className="font-extrabold tracking-tight text-lg">
                TRIPFINITY
              </div>
            </div>

            {/* Primary Navigation */}
            <nav aria-label="Main navigation" className="hidden lg:block">
              <ul className="flex items-center gap-4 xl:gap-6">
                {navItems.map((item) => (
                  <li key={item.to} className="relative">
                    <NavLink
                      to={item.to}
                      className={({ isActive }) =>
                        [
                          "px-2 py-2 text-sm font-medium transition-colors relative",
                          isActiveStartsWith(item.to) || isActive
                            ? "text-gray-900"
                            : "text-gray-500 hover:text-gray-900",
                        ].join(" ")
                      }
                    >
                      {({ isActive }) => (
                        <>
                          <span>{item.label}</span>
                          {item.hasDropdown && (
                            <span
                              className="ml-1 text-xs text-gray-400"
                              aria-hidden="true"
                            >
                              ▾
                            </span>
                          )}
                          {(isActive || isActiveStartsWith(item.to)) && (
                            <span className="absolute inset-x-1 -bottom-[6px] h-0.5 rounded-full bg-gray-900" />
                          )}
                        </>
                      )}
                    </NavLink>
                  </li>
                ))}
              </ul>
            </nav>

            {/* Right actions */}
            <div className="flex items-center gap-4">
              {/* Notification button */}
              <button
                type="button"
                aria-label="Thông báo"
                className="relative rounded-full p-2 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-400"
              >
                <span className="block h-5 w-5">
                  {/* Simple bell icon */}
                  <svg
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="1.5"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    className="h-5 w-5 text-gray-700"
                  >
                    <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9" />
                    <path d="M10 21h4" />
                  </svg>
                </span>
                <span className="absolute top-1.5 right-1.5 inline-block h-2 w-2 rounded-full bg-red-500 ring-2 ring-white" />
              </button>

              {/* Avatar */}
              <button
                type="button"
                className="flex h-9 w-9 items-center justify-center rounded-full bg-gray-200 ring-2 ring-transparent hover:ring-gray-300 focus:outline-none focus:ring-gray-400"
                aria-label="Tài khoản"
              >
                <span className="text-sm font-semibold text-gray-700">A</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* MAIN (content placeholder) */}
      <main
        id="main-content"
        className="flex-1 w-full border-t border-transparent"
      >
        {children}
      </main>

      {/* FOOTER */}
      <footer className="mt-16 border-t border-gray-200 bg-white">
        <div className="mx-auto max-w-[1280px] px-6 py-12 flex flex-col gap-10 lg:flex-row lg:justify-between">
          {/* Branding + description */}
          <div className="max-w-md">
            <div className="text-lg font-extrabold tracking-tight">
              TRIPFINITY
            </div>
            <p className="mt-4 text-sm leading-relaxed text-gray-600">
              Nền tảng booking du lịch hàng đầu Việt Nam, kết nối du khách với
              các nhà cung cấp dịch vụ chất lượng cao. Trải nghiệm du lịch thông
              minh với công nghệ tiên tiến.
            </p>
            <ul className="mt-6 flex flex-wrap gap-x-4 gap-y-2 text-xs text-gray-500">
              {footerLinks.map((l) => (
                <li key={l.to}>
                  <a
                    href={l.to}
                    className="hover:text-gray-800 transition-colors"
                  >
                    {l.label}
                  </a>
                </li>
              ))}
            </ul>
            <p className="mt-8 text-xs text-gray-400">
              © 2025 Tripfinity. Bản quyền thuộc về chúng tôi.
            </p>
          </div>

          {/* App download card */}
          <div className="lg:w-72">
            <div className="rounded-xl border border-gray-200 p-5 shadow-sm">
              <h3 className="text-sm font-semibold text-gray-800 mb-4">
                Tải ứng dụng
              </h3>
              <div className="flex flex-col gap-3">
                <button
                  type="button"
                  className="flex items-center justify-center gap-2 rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 transition"
                >
                  <span></span>
                  <span>Tải trên App Store</span>
                </button>
                <button
                  type="button"
                  className="flex items-center justify-center gap-2 rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 transition"
                >
                  <span className="text-base">▶</span>
                  <span>Tải trên Google Play</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default MainLayout;
