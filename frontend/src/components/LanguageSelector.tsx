import React from "react";
import { useLanguage } from "../hooks/useLanguage";

const LanguageSelector: React.FC = () => {
  const { currentLanguageData, availableLanguages, changeLanguage } =
    useLanguage();

  return (
    <div className="flex items-center">
      <select
        value={currentLanguageData.code}
        onChange={(e) => changeLanguage(e.target.value)}
        className="bg-white border border-gray-300 rounded-lg px-3 py-2 text-gray-900 focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-300 cursor-pointer shadow-sm"
      >
        {availableLanguages.map((language) => (
          <option
            key={language.code}
            value={language.code}
            className="bg-white text-gray-900"
          >
            {language.flag} {language.name}
          </option>
        ))}
      </select>
    </div>
  );
};

export default LanguageSelector;
