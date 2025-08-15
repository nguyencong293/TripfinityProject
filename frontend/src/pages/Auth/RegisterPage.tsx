import { useLanguage } from "../../hooks/useLanguage";
import logo from "../../assets/images/logo.png";
import { useCallback, useEffect, useRef } from "react";
import { Mail, X } from "lucide-react";
import googleLogo from "../../assets/images/7123025_logo_google_g_icon.png";

const LoginPage: React.FC = () => {
  const { t } = useLanguage();

  const closeBtnRef = useRef<HTMLButtonElement | null>(null);
  const firstActionRef = useRef<HTMLButtonElement | null>(null);
  const dialogRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    document.title = t("login");
  }, [t]);

  const close = useCallback(() => {
    window.history.back();
  }, []);

  useEffect(() => {
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev;
    };
  }, []);

  useEffect(() => {
    (firstActionRef.current || closeBtnRef.current)?.focus();
  }, []);

  useEffect(() => {
    const handleKey = (e: KeyboardEvent) => {
      if (e.key !== "Tab") return;
      const container = dialogRef.current;
      if (!container) return;
      const focusables = Array.from(
        container.querySelectorAll<HTMLElement>(
          'button, a[href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
        )
      ).filter(
        (el) => !el.hasAttribute("disabled") && !el.getAttribute("aria-hidden")
      );
      if (!focusables.length) {
        e.preventDefault();
        return;
      }
      const first = focusables[0];
      const last = focusables[focusables.length - 1];
      if (e.shiftKey) {
        if (document.activeElement === first) {
          e.preventDefault();
          last.focus();
        }
      } else {
        if (document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
    };
    document.addEventListener("keydown", handleKey);
    return () => document.removeEventListener("keydown", handleKey);
  }, []);

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center px-4"
      aria-labelledby="login-title"
      role="dialog"
      aria-modal="true"
    >
      <div className="overlay" aria-hidden="true" />

      <div
        ref={dialogRef}
        className="
          relative w-full max-w-md rounded-2xl
          theme-bg-card theme-border theme-text-primary
          p-8 shadow-xl animate-in fade-in zoom-in duration-200
        "
      >
        <button
          ref={closeBtnRef}
          onClick={close}
          aria-label={t("close")}
          className="
            absolute right-3 top-3 inline-flex h-8 w-8 items-center justify-center
            rounded-full theme-text-secondary hover:theme-text-primary
            hover:theme-bg-secondary
            focus:outline-none focus:ring-2 focus:ring-light-focus dark:focus:ring-dark-focus focus:ring-offset-2
            transition
          "
        >
          <X className="h-4 w-4" strokeWidth={2} />
        </button>

        <div className="flex flex-col items-center gap-6">
          <div className="p-2 rounded-full border theme-border bg-white">
            <img
              src={logo}
              alt="Tripfinity"
              className="h-15 w-auto"
              draggable={false}
            />
          </div>

          <div className="text-center space-y-2">
            <h1
              id="login-title"
              className="text-h3-mobile sm:text-h3-tablet lg:text-h2-desktop theme-text-primary"
            >
              {t("login")}
            </h1>
            <p className="text-subtitle2-mobile sm:text-subtitle2-tablet lg:text-subtitle2-desktop theme-text-secondary">
              {t("login_account")}
            </p>
          </div>

          <div className="flex w-full flex-col gap-4">
            <button
              ref={firstActionRef}
              type="button"
              className="
                btn-outline btn-text-responsive w-full
                flex items-center justify-center gap-3
              "
              onClick={() => console.log("Google login")}
            >
              <img className="h-5 w-5" src={googleLogo} alt="Google" />
              <span>{t("login_with_google")}</span>
            </button>

            <button
              type="button"
              className="
                btn-outline btn-text-responsive w-full
                flex items-center justify-center gap-3
              "
              onClick={() => console.log("Email flow")}
            >
              <Mail
                className="h-5 w-5 icon-primary"
                strokeWidth={2}
                aria-hidden="true"
              />
              <span>{t("login_with_email")}</span>
            </button>
          </div>

          <p
            className="
              mt-2 text-center
              text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop
              theme-text-secondary leading-4
            "
          >
            {t("dont_have_an_account")}
            <a href="#" className="link-brand">
              {" "}
              {t("register_account")}
            </a>
          </p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
