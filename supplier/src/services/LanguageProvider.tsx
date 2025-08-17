import React, { useState, useCallback } from "react";
import type { ReactNode } from "react";
import {
  LanguageContext,
  type LanguageContextType,
} from "../contexts/LanguageContext";
import { languages, getTranslation } from "../i18n/config";

interface LanguageProviderProps {
  children: ReactNode;
}

export const LanguageProvider: React.FC<LanguageProviderProps> = ({
  children,
}) => {
  const [currentLanguage, setCurrentLanguage] = useState<string>(() => {
    const stored = localStorage.getItem("language");
    return stored || "vi";
  });

  const changeLanguage = useCallback((langCode: string) => {
    setCurrentLanguage(langCode);
    localStorage.setItem("language", langCode);
  }, []);

  const t = useCallback(
    (key: string) => {
      return getTranslation(currentLanguage, key);
    },
    [currentLanguage]
  );

  const currentLanguageData =
    languages.find((lang) => lang.code === currentLanguage) || languages[0];

  const value: LanguageContextType = {
    currentLanguage,
    currentLanguageData,
    availableLanguages: languages,
    changeLanguage,
    t,
  };

  return (
    <LanguageContext.Provider value={value}>
      {children}
    </LanguageContext.Provider>
  );
};
