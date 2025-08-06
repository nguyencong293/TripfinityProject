import { useContext } from "react";
import { ThemeContext } from "../contexts/ThemeContext";
import type { ThemeContextType } from "../contexts/ThemeContext";

export const useTheme = (): ThemeContextType => {
  return useContext(ThemeContext);
};
