import { useTheme } from "./hooks/useTheme";
import { useLanguage } from "./hooks/useLanguage";
import LanguageSelector from "./components/LanguageSelector";

const App: React.FC = () => {
  const { dark, toggleTheme } = useTheme();
  const { t } = useLanguage();

  return (
    <div
      className={`min-h-screen transition-colors duration-300 ${
        dark ? "dark" : ""
      }`}
    >
      <div className="max-w-6xl mx-auto p-8 space-y-8">
        <header className="flex justify-between items-center">
          <h1 className="text-display-hero-mobile md:text-display-hero-tablet lg:text-display-hero-desktop font-bold theme-text-primary">
            {t("app_title")}
          </h1>
          <button
            onClick={toggleTheme}
            className="btn-primary text-button-mobile md:text-button-tablet lg:text-button-desktop"
          >
            {dark ? "Light Mode" : "Dark Mode"}
          </button>
          <LanguageSelector />
        </header>
      </div>
    </div>
  );
};

export default App;
