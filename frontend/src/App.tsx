import { useState, useEffect } from "react";

function App() {
  const [dark, setDark] = useState(() => {
    const savedTheme = localStorage.getItem("theme");
    return savedTheme === "dark";
  });

  // useEffect để áp dụng theme khi component mount
  useEffect(() => {
    // Áp dụng class dark cho document.documentElement
    document.documentElement.classList.toggle("dark", dark);
    // Lưu vào localStorage
    localStorage.setItem("theme", dark ? "dark" : "light");
  }, [dark]);

  const toggleTheme = () => {
    setDark(!dark);
  };

  return (
    <div
      className={`min-h-screen transition-colors duration-300 ${
        dark ? "dark" : ""
      }`}
    >
      <div className="max-w-6xl mx-auto p-8 space-y-8">
        {/* Header with theme toggle */}
        <header className="flex justify-between items-center">
          <h1 className="text-display-hero-mobile md:text-display-hero-tablet lg:text-display-hero-desktop font-bold theme-text-primary">
            Design System
          </h1>
          <button
            onClick={toggleTheme}
            className="btn-primary text-button-mobile md:text-button-tablet lg:text-button-desktop"
          >
            {dark ? "Light Mode" : "Dark Mode"}
          </button>
        </header>

        {/* Typography Section */}
        <section className="card">
          <h2 className="text-h2-mobile md:text-h2-tablet lg:text-h2-desktop theme-text-primary mb-6">
            Typography System
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div className="space-y-4">
              <h3 className="text-h3-mobile md:text-h3-tablet lg:text-h3-desktop font-bold theme-text-primary">
                Headers
              </h3>
              <div className="space-y-2">
                <p className="text-h1-mobile md:text-h1-tablet lg:text-h1-desktop font-bold theme-text-primary">
                  H1 Title
                </p>
                <p className="text-h2-mobile md:text-h2-tablet lg:text-h2-desktop font-bold theme-text-primary">
                  H2 Title
                </p>
                <p className="text-h3-mobile md:text-h3-tablet lg:text-h3-desktop font-bold theme-text-primary">
                  H3 Title
                </p>
                <p className="text-h4-mobile md:text-h4-tablet lg:text-h4-desktop font-bold theme-text-primary">
                  H4 Title
                </p>
                <p className="text-h5-desktop md:text-h5-tablet lg:text-h5-desktop font-bold theme-text-primary">
                  H5 Title
                </p>
              </div>
            </div>

            <div className="space-y-4">
              <h3 className="text-h3-mobile md:text-h3-tablet lg:text-h3-desktop font-bold theme-text-primary">
                Body Text
              </h3>
              <div className="space-y-2">
                <p className="text-subtitle1-mobile md:text-subtitle1-tablet lg:text-subtitle1-desktop font-medium theme-text-primary">
                  Subtitle 1 - Medium weight
                </p>
                <p className="text-subtitle2-mobile md:text-subtitle2-tablet lg:text-subtitle2-desktop font-medium theme-text-secondary">
                  Subtitle 2 - Secondary color
                </p>
                <p className="text-body1-mobile md:text-body1-tablet lg:text-body1-desktop theme-text-primary">
                  Body 1 - Main body text for paragraphs
                </p>
                <p className="text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary">
                  Body 2 - Secondary body text
                </p>
                <p className="text-caption-mobile md:text-caption-tablet lg:text-caption-desktop theme-text-disabled">
                  Caption - Small descriptive text
                </p>
              </div>
            </div>

            <div className="space-y-4">
              <h3 className="text-h3-mobile md:text-h3-tablet lg:text-h3-desktop font-bold theme-text-primary">
                Special Text
              </h3>
              <div className="space-y-2">
                <p className="text-overline-mobile md:text-overline-tablet lg:text-overline-desktop uppercase tracking-wider theme-text-secondary">
                  Overline Text
                </p>
                <p className="text-button-mobile md:text-button-tablet lg:text-button-desktop font-bold uppercase theme-text-primary">
                  Button Text
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Color Palette Section */}
        <section className="card">
          <h2 className="text-h2-mobile md:text-h2-tablet lg:text-h2-desktop font-bold theme-text-primary mb-6">
            Color Palette
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div>
              <h3 className="text-h4-mobile md:text-h4-tablet lg:text-h4-desktop font-bold theme-text-primary mb-4">
                Primary Colors
              </h3>
              <div className="space-y-3">
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 rounded-lg theme-bg-primary"></div>
                  <div>
                    <p className="text-body1-mobile md:text-body1-tablet lg:text-body1-desktop font-medium theme-text-primary">
                      Primary
                    </p>
                    <p className="text-caption-mobile md:text-caption-tablet lg:text-caption-desktop theme-text-disabled">
                      Brand color
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 rounded-lg theme-bg-secondary"></div>
                  <div>
                    <p className="text-body1-mobile md:text-body1-tablet lg:text-body1-desktop font-medium theme-text-primary">
                      Secondary
                    </p>
                    <p className="text-caption-mobile md:text-caption-tablet lg:text-caption-desktop theme-text-disabled">
                      Support color
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <div>
              <h3 className="text-h4-mobile md:text-h4-tablet lg:text-h4-desktop font-bold theme-text-primary mb-4">
                Status Colors
              </h3>
              <div className="space-y-3">
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 rounded-lg bg-light-success dark:bg-dark-success"></div>
                  <div>
                    <p className="text-body1-mobile md:text-body1-tablet lg:text-body1-desktop font-medium theme-text-primary">
                      Success
                    </p>
                    <p className="text-caption-mobile md:text-caption-tablet lg:text-caption-desktop theme-text-disabled">
                      Positive actions
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 rounded-lg bg-light-warning dark:bg-dark-warning"></div>
                  <div>
                    <p className="text-body1-mobile md:text-body1-tablet lg:text-body1-desktop font-medium theme-text-primary">
                      Warning
                    </p>
                    <p className="text-caption-mobile md:text-caption-tablet lg:text-caption-desktop theme-text-disabled">
                      Attention needed
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 rounded-lg bg-light-error dark:bg-dark-error"></div>
                  <div>
                    <p className="text-body1-mobile md:text-body1-tablet lg:text-body1-desktop font-medium theme-text-primary">
                      Error
                    </p>
                    <p className="text-caption-mobile md:text-caption-tablet lg:text-caption-desktop theme-text-disabled">
                      Critical issues
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Component Examples */}
        <section className="card">
          <h2 className="text-h2-mobile md:text-h2-tablet lg:text-h2-desktop font-bold theme-text-primary mb-6">
            Component Examples
          </h2>

          <div className="space-y-6">
            {/* Buttons */}
            <div>
              <h3 className="text-h4-mobile md:text-h4-tablet lg:text-h4-desktop font-bold theme-text-primary mb-4">
                Buttons
              </h3>
              <div className="flex flex-wrap gap-4">
                <button className="btn-primary text-button-mobile md:text-button-tablet lg:text-button-desktop">
                  Primary Button
                </button>
                <button className="btn-secondary text-button-mobile md:text-button-tablet lg:text-button-desktop">
                  Secondary Button
                </button>
              </div>
            </div>

            {/* Cards */}
            <div>
              <h3 className="text-h4-mobile md:text-h4-tablet lg:text-h4-desktop font-bold theme-text-primary mb-4">
                Cards
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <div className="card">
                  <h4 className="text-h5-mobile md:text-h5-tablet lg:text-h5-desktop font-bold theme-text-primary mb-2">
                    Card Title
                  </h4>
                  <p className="text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary">
                    This is a sample card with the custom theme colors and
                    typography.
                  </p>
                </div>
                <div className="card">
                  <h4 className="text-h5-mobile md:text-h5-tablet lg:text-h5-desktop font-bold theme-text-primary mb-2">
                    Another Card
                  </h4>
                  <p className="text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary">
                    Cards automatically adapt to light and dark themes.
                  </p>
                </div>
                <div className="card">
                  <h4 className="text-h5-mobile md:text-h5-tablet lg:text-h5-desktop font-bold theme-text-primary mb-2">
                    Third Card
                  </h4>
                  <p className="text-body2-mobile md:text-body2-tablet lg:text-body2-desktop theme-text-secondary">
                    Responsive typography scales across devices.
                  </p>
                </div>
              </div>
            </div>

            {/* Alerts */}
            <div>
              <h3 className="text-h4-mobile md:text-h4-tablet lg:text-h4-desktop font-bold theme-text-primary mb-4">
                Alerts
              </h3>
              <div className="space-y-4">
                <div className="alert-success">
                  <p className="text-body1-mobile md:text-body1-tablet lg:text-body1-desktop font-medium">
                    Success: Operation completed successfully!
                  </p>
                </div>
                <div className="alert-warning">
                  <p className="text-body1-mobile md:text-body1-tablet lg:text-body1-desktop font-medium">
                    Warning: Please review your input.
                  </p>
                </div>
                <div className="alert-error">
                  <p className="text-body1-mobile md:text-body1-tablet lg:text-body1-desktop font-medium">
                    Error: Something went wrong!
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}

export default App;
