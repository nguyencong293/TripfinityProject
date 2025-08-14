import { useLanguage } from "./hooks/useLanguage";
import LanguageSelector from "./components/LanguageSelector";
import ThemeToggle from "./components/ThemeToggle";

const App: React.FC = () => {
  const { t } = useLanguage();

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
        </header>
      </div>
    </div>
  );
};

export default App;
