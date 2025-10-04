import { useEffect, useState, useCallback } from "react";
import { Navigate, Outlet, useNavigate } from "react-router-dom";
import { getProviderByUserId } from "../services/providerService";
import { Loader2 } from "lucide-react";
import axios from "axios";

const ProtectedRoute: React.FC = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [hasProvider, setHasProvider] = useState(false);
  const [networkError, setNetworkError] = useState(false);

  const checkProvider = useCallback(async () => {
    try {
      const userStr = localStorage.getItem("user");
      const token = localStorage.getItem("token");

      if (!userStr || !token) {
        setLoading(false);
        return;
      }

      const user = JSON.parse(userStr);
      const provider = await getProviderByUserId(user.userId);

      setHasProvider(!!provider);
      setNetworkError(false);
    } catch (error) {
      console.error("Error checking provider:", error);

      // Check if it's a network error
      if (axios.isAxiosError(error) && !error.response) {
        setNetworkError(true);
        navigate("/supplier/server-error", { replace: true });
        return;
      }

      setHasProvider(false);
    } finally {
      setLoading(false);
    }
  }, [navigate]); // Add navigate to dependencies

  useEffect(() => {
    checkProvider();
  }, [checkProvider]); // Add checkProvider to dependencies

  if (networkError) {
    return null; // Will navigate to error page
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="animate-spin h-12 w-12 text-emerald-600" />
      </div>
    );
  }

  const token = localStorage.getItem("token");
  const userStr = localStorage.getItem("user");

  if (!token || !userStr) {
    return <Navigate to="/supplier/login" replace />;
  }

  if (!hasProvider) {
    return <Navigate to="/supplier/provider-info" replace />;
  }

  return <Outlet />;
};

export default ProtectedRoute;
