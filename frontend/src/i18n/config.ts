import type { Language, Translation } from "../types/language";

// Import JSON files
import enTranslations from "./locales/en.json";
import viTranslations from "./locales/vi.json";
import koTranslations from "./locales/ko.json";

export const languages: Language[] = [
  { code: "en", name: "English", flag: "🇺🇸" },
  { code: "vi", name: "Tiếng Việt", flag: "🇻🇳" },
  { code: "ko", name: "한국어", flag: "🇰🇷" },
];

// Load translations from JSON files
const translations: Record<string, Translation> = {
  en: enTranslations,
  vi: viTranslations,
  ko: koTranslations,
};

export const getTranslation = (langCode: string, key: string): string => {
  return translations[langCode]?.[key] || translations["vi"][key] || key;
};

export const getCurrentLanguage = (langCode: string): Language => {
  return languages.find((lang) => lang.code === langCode) || languages[1];
};
