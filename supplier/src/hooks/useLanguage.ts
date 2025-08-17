import { useContext } from "react";
import { LanguageContext } from "../contexts/LanguageContext";

export const useLanguage = () => {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error("useLanguage phải được sử dụng trong LanguageProvider");
  }
  return context;
};
