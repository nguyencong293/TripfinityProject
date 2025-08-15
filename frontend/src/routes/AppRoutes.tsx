import type React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import App from "../App";
import LoginPage from "../pages/Auth/tourist/LoginPage";
import RegisterPage from "../pages/Auth/tourist/RegisterPage";
import ForgetAccountPage from "../pages/Auth/tourist/ForgetAccountPage";
import SupplierLoginPage from "../pages/Auth/supplier/SupplierLoginPage";
import SupplierRegisterPage from "../pages/Auth/supplier/SupplierRegisterPage";
import SupplierMain from "../pages/Home/supplier/SupplierMain";
import SupplierForgetAccountPage from "../pages/Auth/supplier/SupplierForgetAccountPage";

const AppRoutes: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        {/* tourist routes */}
        <Route path="/" element={<App />}>
          <Route index element={<App />} />
        </Route>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/forget-account" element={<ForgetAccountPage />} />

        {/* supplier routes */}
        <Route path="/supplier" element={<SupplierMain />}>
          <Route index element={<SupplierMain />} />
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
