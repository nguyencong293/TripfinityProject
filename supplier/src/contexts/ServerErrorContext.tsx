import {
  createContext,
  useState,
  useCallback,
  useEffect,
  type ReactNode,
} from "react";
import { useNavigate, useLocation } from "react-router-dom";

interface ServerStatusContextType {
  isServerAvailable: boolean;
  checkServerStatus: () => Promise<boolean>;
  setServerUnavailable: () => void;
}

const ServerStatusContext = createContext<ServerStatusContextType | undefined>(
  undefined
);

interface ServerStatusProviderProps {
  children: ReactNode;
}

export const ServerStatusProvider: React.FC<ServerStatusProviderProps> = ({
  children,
}) => {
  const [isServerAvailable, setIsServerAvailable] = useState(true);
  const navigate = useNavigate();
  const location = useLocation();

  const checkServerStatus = useCallback(async (): Promise<boolean> => {
    // Implement your server check logic here
    return true;
  }, []);

  const setServerUnavailable = useCallback(() => {
    if (location.pathname !== "/supplier/server-error") {
      setIsServerAvailable(false);
      navigate("/supplier/server-error", { replace: true });
    }
  }, [navigate, location.pathname]);

  useEffect(() => {
    if (isServerAvailable && location.pathname === "/supplier/server-error") {
      // Server is back online, redirect appropriately
      const token = localStorage.getItem("token");
      if (token) {
        navigate("/supplier", { replace: true });
      } else {
        navigate("/supplier/login", { replace: true });
      }
    }
  }, [isServerAvailable, location.pathname, navigate]);

  return (
    <ServerStatusContext.Provider
      value={{ isServerAvailable, checkServerStatus, setServerUnavailable }}
    >
      {children}
    </ServerStatusContext.Provider>
  );
};

export default ServerStatusContext;
