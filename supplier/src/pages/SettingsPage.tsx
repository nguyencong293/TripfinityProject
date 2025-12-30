import React from "react";
import { Sun, Moon, Globe } from "lucide-react";
import { useTheme } from "../hooks/useTheme";
import { useLanguage } from "../hooks/useLanguage";

const SettingsPage: React.FC = () => {
  const { dark, toggleTheme } = useTheme();
  const { currentLanguage, availableLanguages, changeLanguage, t } = useLanguage();

  return (
    <div className="max-w-4xl mx-auto px-6 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold theme-text-primary mb-2">
          {t("settings_title")}
        </h1>
        <p className="theme-text-secondary">
          {t("settings_description")}
        </p>
      </div>

      {/* Settings Cards */}
      <div className="space-y-4">
        {/* Theme Setting */}
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-full theme-bg-secondary flex items-center justify-center">
                {dark ? (
                  <Moon className="w-6 h-6 theme-text-primary" />
                ) : (
                  <Sun className="w-6 h-6 theme-text-primary" />
                )}
              </div>
              <div>
                <h3 className="text-lg font-semibold theme-text-primary mb-1">
                  {t("settings_theme_title")}
                </h3>
                <p className="text-sm theme-text-secondary">
                  {t("settings_theme_description")}
                </p>
              </div>
            </div>
            <button
              onClick={toggleTheme}
              className={`relative inline-flex h-8 w-14 items-center rounded-full transition-colors ${
                dark ? "theme-bg-primary" : "bg-gray-300"
              }`}
            >
              <span
                className={`inline-block h-6 w-6 transform rounded-full bg-white shadow-md transition-transform ${
                  dark ? "translate-x-7" : "translate-x-1"
                }`}
              />
            </button>
          </div>
          <div className="mt-4 flex items-center gap-2 text-sm theme-text-secondary">
            <span className={!dark ? "font-semibold theme-text-primary" : ""}>
              {t("settings_theme_light")}
            </span>
            <span>|</span>
            <span className={dark ? "font-semibold theme-text-primary" : ""}>
              {t("settings_theme_dark")}
            </span>
          </div>
        </div>

        {/* Language Setting */}
        <div className="theme-bg-card border theme-border rounded-xl p-6">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-12 h-12 rounded-full theme-bg-secondary flex items-center justify-center">
              <Globe className="w-6 h-6 theme-text-primary" />
            </div>
            <div>
              <h3 className="text-lg font-semibold theme-text-primary mb-1">
                {t("settings_language_title")}
              </h3>
              <p className="text-sm theme-text-secondary">
                {t("settings_language_description")}
              </p>
            </div>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {availableLanguages.map((lang) => (
              <button
                key={lang.code}
                onClick={() => changeLanguage(lang.code)}
                className={`flex items-center gap-3 p-4 rounded-lg border-2 transition-all ${
                  currentLanguage === lang.code
                    ? "border-green-500 theme-bg-secondary"
                    : "theme-border theme-bg-card hover:theme-bg-secondary"
                }`}
              >
                <span className="text-2xl">{lang.flag}</span>
                <div className="text-left flex-1">
                  <div className="font-semibold theme-text-primary">
                    {lang.name}
                  </div>
                </div>
                {currentLanguage === lang.code && (
                  <div className="w-5 h-5 rounded-full bg-green-500 flex items-center justify-center">
                    <svg
                      className="w-3 h-3 text-white"
                      fill="none"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                )}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Info Footer */}
      <div className="mt-8 p-4 rounded-lg theme-bg-secondary">
        <p className="text-sm theme-text-secondary text-center">
          {t("settings_footer_info")}
        </p>
      </div>
    </div>
  );
};

export default SettingsPage;
