import { Outlet } from "react-router-dom";
import MainLayout from "./layouts/MainLayout";
import type React from "react";

const App: React.FC = () => {
  return (
    <MainLayout>
      <Outlet />
    </MainLayout>
  );
};

export default App;
