import { createContext } from "react";

export interface ThemeContextType {
  dark: boolean;
  toggleTheme: () => void;
}

export const ThemeContext = createContext<ThemeContextType>({
  dark: false,
  toggleTheme: () => {},
});
