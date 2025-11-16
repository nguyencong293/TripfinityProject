import { useEffect } from "react";
import { useLocation } from "react-router-dom";

/**
 * Component tự động cuộn lên đầu trang mỗi khi route thay đổi
 * Sử dụng trong BrowserRouter để áp dụng cho toàn bộ ứng dụng
 */
const ScrollToTop: React.FC = () => {
  const { pathname } = useLocation();

  useEffect(() => {
    // Cuộn lên đầu trang (0, 0) với behavior smooth hoặc instant
    window.scrollTo({
      top: 0,
      left: 0,
      behavior: "instant", // Dùng "smooth" nếu muốn cuộn mượt
    });
  }, [pathname]);

  return null; // Component này không render gì
};

export default ScrollToTop;
