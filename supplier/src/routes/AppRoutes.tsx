import type React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import App from "../App";
import SupplierLoginPage from "../pages/Auth/SupplierLoginPage";
import SupplierRegisterPage from "../pages/Auth/SupplierRegisterPage";
import SupplierForgetAccountPage from "../pages/Auth/SupplierForgetAccountPage";
import SupplierHomePage from "../pages/Home/SupplierHomePage";
import ListingsPage from "../pages/Service/ListingsPage";

const AppRoutes: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        {/* supplier routes */}
        <Route path="/supplier" element={<App />}>
          <Route index element={<SupplierHomePage />} />
          <Route path="listings" element={<ListingsPage />} />
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
