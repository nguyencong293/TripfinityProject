import { Navigate, Outlet } from "react-router-dom";

const PublicRoute: React.FC = () => {
  const token = localStorage.getItem("token");
  const userStr = localStorage.getItem("user");

  // Nếu đã đăng nhập (có token và user), redirect về trang chủ
  if (token && userStr) {
    return <Navigate to="/supplier" replace />;
  }

  // Nếu chưa đăng nhập, cho phép truy cập
  return <Outlet />;
};

export default PublicRoute;
