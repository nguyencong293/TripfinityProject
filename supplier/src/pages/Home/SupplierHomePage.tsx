import { useNavigate } from "react-router-dom";
import { useLanguage } from "../../hooks/useLanguage";
import ThemeToggle from "../../components/ThemeToggle";
import LanguageSelector from "../../components/LanguageSelector";
import { useSupplierLogin } from "../../hooks/useLogin";
import { logoutSupplier } from "../../services/supplierAuthService";

const SupplierHomePage: React.FC = () => {
  const { t } = useLanguage();
  const navigate = useNavigate();
  const { logout } = useSupplierLogin();

  const goToLogin = () => {
    navigate("/supplier/login");
  };

  document.title = t("app_title");

  return (
    <div className={`min-h-screen transition-colors duration-300`}>
      <div className="max-w-6xl mx-auto p-8 space-y-8">
        <header className="flex justify-between items-center">
          <h1 className="text-display-hero-mobile md:text-display-hero-tablet lg:text-display-hero-desktop font-bold theme-text-primary">
            {t("app_title")}
          </h1>
          <ThemeToggle />
          <LanguageSelector />
          <div className="flex gap-3">
            <button
              onClick={goToLogin}
              className="px-4 py-2 rounded-md border theme-border"
            >
              Đến trang đăng nhập
            </button>
            <button
              onClick={async () => {
                // Call both client and server logout
                logout();
                await logoutSupplier();
                navigate("/supplier/login", { replace: true });
              }}
              className="px-4 py-2 rounded-md bg-red-500 text-white"
            >
              Logout
            </button>
          </div>
        </header>
      </div>
    </div>
  );
};

export default SupplierHomePage;
