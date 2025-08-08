import { createContext } from "react";
import type { Language } from "../types/language";

export interface LanguageContextType {
  currentLanguage: string;
  currentLanguageData: Language;
  availableLanguages: Language[];
  changeLanguage: (langCode: string) => void;
  t: (key: string) => string;
}

export const LanguageContext = createContext<LanguageContextType | undefined>(
  undefined
);
