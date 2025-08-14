import type React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import App from "../App";
import LoginPage from "../pages/Auth/LoginPage";

const AppRoutes: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<App />}>
          <Route index element={<App />} />
        </Route>

        <Route path="/login" element={<LoginPage />} />
      </Routes>
    </BrowserRouter>
  );
};

export default AppRoutes;
