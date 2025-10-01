import type React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
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

const AppRoutes: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        {/* Public routes */}
        <Route path="/supplier/login" element={<SupplierLoginPage />} />
        <Route path="/supplier/register" element={<SupplierRegisterPage />} />
        <Route path="/supplier/provider-info" element={<ProviderInfoPage />} />
        <Route
          path="/supplier/forget-account"
          element={<SupplierForgetAccountPage />}
        />

        {/* Protected routes - requires provider info */}
        <Route element={<ProtectedRoute />}>
          <Route path="/supplier" element={<App />}>
            <Route index element={<SupplierHomePage />} />
            <Route path="listings" element={<ListingsPage />} />
            <Route path="service/tour" element={<DashboardTourPage />} />
            <Route path="service/hotel" element={<DashboardHotelPage />} />
            <Route path="service/hotel/create" element={<HotelCreatePage />} />
            <Route path="service/hotel/edit" element={<HotelEditPage />} />
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
      </Routes>
    </BrowserRouter>
  );
};

export default AppRoutes;
