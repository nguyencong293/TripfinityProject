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

const AppRoutes: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        {/* supplier routes */}
        <Route path="/supplier" element={<App />}>
          <Route index element={<SupplierHomePage />} />
          <Route path="listings" element={<ListingsPage />} />
          <Route path="service/tour" element={<DashboardTourPage />} />
          <Route path="service/hotel" element={<DashboardHotelPage />} />
          <Route
            path="service/attraction"
            element={<DashboardAttractionPage />}
          />
          <Route
            path="service/restaurant"
            element={<DashboardRestaurantPage />}
          />
        </Route>
        <Route path="/supplier/login" element={<SupplierLoginPage />} />
        <Route path="/supplier/register" element={<SupplierRegisterPage />} />
        <Route
          path="/supplier/forget-account"
          element={<SupplierForgetAccountPage />}
        />
      </Routes>
    </BrowserRouter>
  );
};

export default AppRoutes;
