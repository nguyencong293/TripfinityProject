import React from "react";
import { useTheme } from "../hooks/useTheme";
import { useLanguage } from "../hooks/useLanguage";

// A reusable theme toggle button component, matching style with LanguageSelector
const ThemeToggle: React.FC = () => {
  const { dark, toggleTheme } = useTheme();
  const { t } = useLanguage();

  return (
    <button
      onClick={toggleTheme}
      className="btn-primary text-button-mobile md:text-button-tablet lg:text-button-desktop"
      aria-label={dark ? t("light") : t("dark")}
      type="button"
    >
      {dark ? t("light") : t("dark")}
    </button>
  );
};

export default ThemeToggle;
