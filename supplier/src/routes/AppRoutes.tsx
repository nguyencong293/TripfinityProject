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
import RestaurantCreatePage from "../pages/Service/Restaurant/RestaurantCreatePage";
import RestaurantEditPage from "../pages/Service/Restaurant/RestaurantEditPage";
import ListRestaurantPage from "../pages/Service/Restaurant/ListRestaurantPage";
import RestaurantViewPage from "../pages/Service/Restaurant/RestaurantViewPage";
import DashboardAttractionPage from "../pages/Service/Attraction/DashboardAttractionPage";
import AttractionCreatePage from "../pages/Service/Attraction/AttractionCreatePage";
import AttractionEditPage from "../pages/Service/Attraction/AttractionEditPage";
import ListAttractionPage from "../pages/Service/Attraction/ListAttractionPage";
import AttractionViewPage from "../pages/Service/Attraction/AttractionViewPage";
import HotelCreatePage from "../pages/Service/Hotel/HotelCreatePage";
import HotelEditPage from "../pages/Service/Hotel/HotelEditPage";
import TourCreatePage from "../pages/Service/Tour/TourCreatePage";
import TourEditPage from "../pages/Service/Tour/TourEditPage";
import TourListPage from "../pages/Service/Tour/TourListPage";
import TourViewPage from "../pages/Service/Tour/TourViewPage";
import ProviderInfoPage from "../pages/Auth/ProviderInfoPage";
import ProtectedRoute from "./ProtectedRoute";
import PublicRoute from "./PublicRoute";
import ProfileProviderPage from "../pages/ProfileProviderPage";
import HotelViewPage from "../pages/Service/Hotel/HotelViewPage";
import ServerErrorPage from "../pages/ServerErrorPage";
import ListHotelPage from "../pages/Service/Hotel/ListHotelPage";
import ListBookingPage from "../pages/Service/Hotel/ListBookingPage";
import HotelBookingViewPage from "../pages/Service/Hotel/HotelBookingViewPage";
import AllReviewsPage from "../pages/Service/Hotel/AllReviewsPage";
import RecentReviewsPage from "../pages/Service/Hotel/RecentReviewsPage";
import ReviewDetailPage from "../pages/Service/Hotel/ReviewDetailPage";
import RestaurantAllReviewsPage from "../pages/Service/Restaurant/AllReviewsPage";
import RestaurantRecentReviewsPage from "../pages/Service/Restaurant/RecentReviewsPage";
import RestaurantReviewDetailPage from "../pages/Service/Restaurant/ReviewDetailPage";
import ListRestaurantBookingPage from "../pages/Service/Restaurant/ListRestaurantBookingPage";
import RestaurantBookingViewPage from "../pages/Service/Restaurant/RestaurantBookingViewPage";
import ListTourBookingPage from "../pages/Service/Tour/ListTourBookingPage";
import TourBookingViewPage from "../pages/Service/Tour/TourBookingViewPage";
import ListAttractionBookingPage from "../pages/Service/Attraction/ListAttractionBookingPage";
import AttractionBookingViewPage from "../pages/Service/Attraction/AttractionBookingViewPage";
import NotificationListPage from "../pages/NotificationListPage";
import ScrollToTop from "../components/ScrollToTop";

const AppRoutes: React.FC = () => {
  return (
    <BrowserRouter>
      <ScrollToTop />
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
            <Route path="notifications" element={<NotificationListPage />} />
            <Route path="listings" element={<ListingsPage />} />
            <Route path="service/tour" element={<DashboardTourPage />} />
            <Route path="service/tour/list" element={<TourListPage />} />
            <Route path="service/tour/bookings" element={<ListTourBookingPage />} />
            <Route path="service/tour/bookings/:bookingId" element={<TourBookingViewPage />} />
            <Route path="service/tour/create" element={<TourCreatePage />} />
            <Route
              path="service/tour/:tourId/edit"
              element={<TourEditPage />}
            />
            <Route
              path="service/tour/:tourId/view"
              element={<TourViewPage />}
            />
            <Route path="service/hotel" element={<DashboardHotelPage />} />
            <Route path="service/hotel/list" element={<ListHotelPage />} />
            <Route path="service/hotel/all-reviews" element={<AllReviewsPage />} />
            <Route path="service/hotel/recent-reviews" element={<RecentReviewsPage />} />
            <Route path="service/hotel/reviews/:reviewId" element={<ReviewDetailPage />} />
            <Route path="service/hotel/bookings" element={<ListBookingPage />} />
            <Route path="service/hotel/bookings/:bookingId" element={<HotelBookingViewPage />} />
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
              path="service/attraction/list"
              element={<ListAttractionPage />}
            />
            <Route
              path="service/attraction/create"
              element={<AttractionCreatePage />}
            />
            <Route
              path="service/attraction/:attractionId/edit"
              element={<AttractionEditPage />}
            />
            <Route
              path="service/attraction/:attractionId/view"
              element={<AttractionViewPage />}
            />
            <Route
              path="service/attraction/bookings"
              element={<ListAttractionBookingPage />}
            />
            <Route
              path="service/attraction/bookings/:bookingId"
              element={<AttractionBookingViewPage />}
            />
            <Route
              path="service/restaurant"
              element={<DashboardRestaurantPage />}
            />
            <Route
              path="service/restaurant/list"
              element={<ListRestaurantPage />}
            />
            <Route
              path="service/restaurant/create"
              element={<RestaurantCreatePage />}
            />
            <Route
              path="service/restaurant/:restaurantId/edit"
              element={<RestaurantEditPage />}
            />
            <Route
              path="service/restaurant/:restaurantId/view"
              element={<RestaurantViewPage />}
            />
            <Route
              path="service/restaurant/all-reviews"
              element={<RestaurantAllReviewsPage />}
            />
            <Route
              path="service/restaurant/recent-reviews"
              element={<RestaurantRecentReviewsPage />}
            />
            <Route
              path="service/restaurant/reviews/:reviewId"
              element={<RestaurantReviewDetailPage />}
            />
            <Route
              path="service/restaurant/bookings"
              element={<ListRestaurantBookingPage />}
            />
            <Route
              path="service/restaurant/bookings/:bookingId"
              element={<RestaurantBookingViewPage />}
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
