import { useLanguage } from "../../hooks/useLanguage";
import { useNavigate } from "react-router-dom";
import logo from "../../assets/images/logo.png";
import { useCallback, useEffect, useRef, useState } from "react";
import { Mail, X, Eye, EyeOff } from "lucide-react";
import googleLogo from "../../assets/images/7123025_logo_google_g_icon.png";

const LoginPage: React.FC = () => {
  const { t } = useLanguage();

  const closeBtnRef = useRef<HTMLButtonElement | null>(null);
  const firstActionRef = useRef<HTMLButtonElement | null>(null);
  const dialogRef = useRef<HTMLDivElement | null>(null);

  const emailInputRef = useRef<HTMLInputElement | null>(null);
  const passwordInputRef = useRef<HTMLInputElement | null>(null);
  const submitBtnRef = useRef<HTMLButtonElement | null>(null);

  const [showEmailForm, setShowEmailForm] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const navigate = useNavigate();

  useEffect(() => {
    document.title = t("login");
  }, [t]);

  const close = useCallback(() => {
    navigate("/");
  }, [navigate]);

  useEffect(() => {
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev;
    };
  }, []);

  useEffect(() => {
    if (showEmailForm) {
      emailInputRef.current?.focus();
    } else {
      (firstActionRef.current || closeBtnRef.current)?.focus();
    }
  }, [showEmailForm]);

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

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log("Submit email login:", { email, password });
  };

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

          <div className="w-full space-y-2 text-center">
            <h1
              id="login-title"
              className="text-h3-mobile sm:text-h3-tablet lg:text-h2-desktop theme-text-primary"
            >
              {t("login")}
            </h1>
            <p className="text-subtitle2-mobile sm:text-subtitle2-tablet lg:text-subtitle2-desktop theme-text-secondary">
              {showEmailForm ? t("login_account") : t("login_account")}
            </p>
          </div>

          {!showEmailForm && (
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
                onClick={() => setShowEmailForm(true)}
              >
                <Mail
                  className="h-5 w-5 icon-primary"
                  strokeWidth={2}
                  aria-hidden="true"
                />
                <span>{t("login_with_email")}</span>
              </button>
            </div>
          )}

          {showEmailForm && (
            <form
              onSubmit={submit}
              className="flex w-full flex-col gap-5 animate-in fade-in duration-150"
              noValidate
            >
              <div className="flex flex-col gap-4">
                <div className="flex flex-col gap-1">
                  <label
                    htmlFor="email"
                    className="text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop font-medium theme-text-secondary"
                  >
                    {t("email_account")}
                  </label>
                  <input
                    ref={emailInputRef}
                    id="email"
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder={t("ent_email_account")}
                    className="
                      w-full rounded-lg border theme-border bg-transparent px-3 py-4
                      focus:outline-none focus:ring-2 focus:ring-light-focus dark:focus:ring-dark-focus
                      text-body2-mobile sm:text-body2-tablet lg:text-body2-desktop
                    "
                  />
                </div>

                <div className="flex flex-col gap-1">
                  <label
                    htmlFor="password"
                    className="text-caption-mobile sm:text-caption-tablet lg:text-caption-desktop font-medium theme-text-secondary"
                  >
                    {t("passw_account")}
                  </label>
                  <div className="relative">
                    <input
                      ref={passwordInputRef}
                      id="password"
                      type={showPassword ? "text" : "password"}
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder={t("ent_passw_account")}
                      className="
                        w-full rounded-lg border theme-border bg-transparent px-3 py-4 pr-10
                        focus:outline-none focus:ring-2 focus:ring-light-focus dark:focus:ring-dark-focus
                        text-body2-mobile sm:text-body2-tablet lg:text-body2-desktop
                      "
                    />
                    <button
                      type="button"
                      aria-label={
                        showPassword ? t("hide_password") : t("show_password")
                      }
                      onClick={() => setShowPassword((s) => !s)}
                      className="absolute inset-y-0 right-2 inline-flex items-center justify-center rounded-md px-2 theme-text-secondary hover:theme-text-primary focus:outline-none"
                    >
                      {showPassword ? (
                        <EyeOff className="h-5 w-5" />
                      ) : (
                        <Eye className="h-5 w-5" />
                      )}
                    </button>
                  </div>
                  <div className="mt-1 flex justify-end">
                    <button
                      type="button"
                      className="text-xs font-medium link-brand"
                      onClick={() => console.log("Forgot password")}
                    >
                      {t("forg_account_txt")}
                    </button>
                  </div>
                </div>
              </div>

              <button
                ref={submitBtnRef}
                type="submit"
                className="btn-primary w-full h-12 rounded-full font-semibold btn-text-responsive mt-2"
              >
                {t("login")}
              </button>
            </form>
          )}
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
