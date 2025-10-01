import { useEffect, useState } from "react";
import { Navigate, Outlet } from "react-router-dom";
import { getProviderByUserId } from "../services/providerService";
import { Loader2 } from "lucide-react";

const ProtectedRoute: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [hasProvider, setHasProvider] = useState(false);

  useEffect(() => {
    checkProvider();
  }, []);

  const checkProvider = async () => {
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
    } catch (error) {
      console.error("Error checking provider:", error);
      setHasProvider(false);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="animate-spin h-12 w-12 text-emerald-600" />
      </div>
    );
  }

  if (!hasProvider) {
    return <Navigate to="/supplier/provider-info" replace />;
  }

  return <Outlet />;
};

export default ProtectedRoute;
