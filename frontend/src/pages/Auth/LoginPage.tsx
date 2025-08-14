import { useLanguage } from "../../hooks/useLanguage";

const LoginPage: React.FC = () => {
  const { t } = useLanguage();
  document.title = t("login");
  return (
    <div>
      <h1>Login Page</h1>
    </div>
  );
};

export default LoginPage;
