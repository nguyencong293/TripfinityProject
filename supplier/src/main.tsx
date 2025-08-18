import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import { ThemeProvider } from "./contexts/ThemeProvider";
import { LanguageProvider } from "./contexts/LanguageProvider";
import AppRoutes from "./routes/AppRoutes";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <ThemeProvider>
      <LanguageProvider>
        <AppRoutes />
      </LanguageProvider>
    </ThemeProvider>
  </StrictMode>
);
