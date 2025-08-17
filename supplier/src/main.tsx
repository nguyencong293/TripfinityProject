import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import { ThemeProvider } from "./services/ThemeProvider.tsx";
import { LanguageProvider } from "./services/LanguageProvider.tsx";
import AppRoutes from "./routes/AppRoutes.tsx";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <ThemeProvider>
      <LanguageProvider>
        <AppRoutes />
      </LanguageProvider>
    </ThemeProvider>
  </StrictMode>
);
