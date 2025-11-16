import type React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import App from "../App";
import SupplierLoginPage from "../pages/Auth/SupplierLoginPage";
import SupplierRegisterPage from "../pages/Auth/SupplierRegisterPage";
import SupplierForgetAccountPage from "../pages/Auth/SupplierForgetAccountPage";
import SupplierHomePage from "../pages/Home/SupplierHomePage";
import ListingsPage from "../pages/Service/ListingsPage";
import DashboardTourPage from "../pages/Service/Tour/DashboardTourPage";
import DashboardHotelPage from "../pages/Service/Hotel/DashboardHotelPage";
import DashboardRestaurantPage from "../pages/Service/Restaurant/DashboardRestaurantPage";
import DashboardAttractionPage from "../pages/Service/Attraction/DashboardAttractionPage";
import HotelCreatePage from "../pages/Service/Hotel/HotelCreatePage";
import HotelEditPage from "../pages/Service/Hotel/HotelEditPage";
import ProviderInfoPage from "../pages/Auth/ProviderInfoPage";
import ProtectedRoute from "./ProtectedRoute";
import PublicRoute from "./PublicRoute";
import ProfileProviderPage from "../pages/ProfileProviderPage";
import HotelViewPage from "../pages/Service/Hotel/HotelViewPage";
import ServerErrorPage from "../pages/ServerErrorPage";
import ListHotelPage from "../pages/Service/Hotel/ListHotelPage";
import ListBookingPage from "../pages/Service/Hotel/ListBookingPage";

const AppRoutes: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        {/* Server Error Page - không cần authentication */}
        <Route path="/supplier/server-error" element={<ServerErrorPage />} />

        {/* Public routes - chỉ cho phép truy cập khi chưa đăng nhập */}
        <Route element={<PublicRoute />}>
          <Route path="/supplier/login" element={<SupplierLoginPage />} />
          <Route path="/supplier/register" element={<SupplierRegisterPage />} />
          <Route
            path="/supplier/forget-account"
            element={<SupplierForgetAccountPage />}
          />
        </Route>

        {/* Provider Info Page - đặc biệt, cần đăng nhập nhưng chưa có provider */}
        <Route path="/supplier/provider-info" element={<ProviderInfoPage />} />

        {/* Protected routes - requires provider info */}
        <Route element={<ProtectedRoute />}>
          <Route path="/supplier" element={<App />}>
            <Route index element={<SupplierHomePage />} />
            <Route path="profile" element={<ProfileProviderPage />} />
            <Route path="listings" element={<ListingsPage />} />
            <Route path="service/tour" element={<DashboardTourPage />} />
            <Route path="service/hotel" element={<DashboardHotelPage />} />
            <Route path="service/hotel/list" element={<ListHotelPage />} />
            <Route path="service/hotel/bookings" element={<ListBookingPage />} />
            <Route path="service/hotel/create" element={<HotelCreatePage />} />
            <Route
              path="service/hotel/:hotelId/edit"
              element={<HotelEditPage />}
            />
            <Route
              path="service/hotel/:hotelId/view"
              element={<HotelViewPage />}
            />
            <Route
              path="service/attraction"
              element={<DashboardAttractionPage />}
            />
            <Route
              path="service/restaurant"
              element={<DashboardRestaurantPage />}
            />
          </Route>
        </Route>

        {/* Catch-all route - redirect mọi đường dẫn không hợp lệ về trang chủ */}
        <Route path="*" element={<Navigate to="/supplier" replace />} />
      </Routes>
    </BrowserRouter>
  );
};

export default AppRoutes;
