import React, { useCallback, useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Eye, EyeOff, X, Loader2 } from "lucide-react";

import { useLanguage } from "../../hooks/useLanguage";
import { useSupplierRegister } from "../../hooks/useSupplierRegister";
import logo from "../../assets/images/logo.png";
import type { UserDTO } from "../../types/index";

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const SupplierRegisterPage: React.FC = () => {
  const { t } = useLanguage();
  const navigate = useNavigate();

  const [showPassword, setShowPassword] = useState(false);
  const [showRePassword, setShowRePassword] = useState(false);

  const [toastVisible, setToastVisible] = useState(false);

  const [form, setForm] = useState({
    name: "",
    email: "",
    password: "",
    rePassword: "",
  });

  const [formError, setFormError] = useState<string | null>(null);

  const { isLoading, error, success, handleRegister } = useSupplierRegister();

  useEffect(() => {
    document.title = t("register_account");
  }, [t]);

  useEffect(() => {
    let timeoutId: number | undefined;
    if (success) {
      setToastVisible(true);
      timeoutId = window.setTimeout(() => {
        navigate("/supplier/login", { replace: true });
      }, 1400);
    }
    return () => {
      if (timeoutId) clearTimeout(timeoutId);
    };
  }, [success, navigate]);

  const setField = useCallback(
    (key: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement>) =>
      setForm((s) => ({ ...s, [key]: e.target.value })),
    []
  );

  const validateInputs = useCallback((): string | null => {
    if (
      !form.name.trim() ||
      !form.email.trim() ||
      !form.password ||
      !form.rePassword
    ) {
      return t("please_fill_all_fields");
    }

    if (!emailRegex.test(form.email)) {
      return t("email_invalid");
    }

    if (form.password !== form.rePassword) {
      return t("password_mismatch");
    }

    if (form.password.length < 6) {
      return t("passw_invalid");
    }

    return null;
  }, [form, t]);

  const submit = useCallback(
    async (e: React.FormEvent) => {
      e.preventDefault();
      setFormError(null);

      const validationError = validateInputs();
      if (validationError) {
        setFormError(validationError);
        return;
      }

      const userData: UserDTO = {
        email: form.email.trim(),
        passwordHash: form.password,
        fullName: form.name.trim(),
        confirmPassword: form.rePassword,
      };

      try {
        await handleRegister(userData);
      } catch (err) {
        console.error("Registration failed (submit):", err);
      }
    },
    [form, validateInputs, handleRegister]
  );

  return (
    <main className="relative overflow-hidden min-h-screen w-full flex items-center justify-center px-4 py-10 sm:py-12">
      <div
        className="pointer-events-none absolute inset-0 -z-10"
        aria-hidden="true"
      >
        <div className="hidden sm:block absolute -top-40 -left-32 h-[26rem] w-[26rem] rounded-full bg-gradient-to-br from-emerald-400/25 to-teal-500/30 blur-3xl animate-float-slow" />
        <div className="hidden md:block absolute top-1/2 -translate-y-1/2 -right-40 h-[30rem] w-[30rem] rounded-full bg-gradient-to-tr from-rose-400/20 via-fuchsia-500/25 to-indigo-500/25 blur-3xl animate-float-slower" />
        <div className="absolute top-24 left-[12%] h-16 w-16 sm:h-24 sm:w-24 rounded-full bg-emerald-400/30 blur-xl animate-pulse-soft" />
        <div className="absolute bottom-32 right-[18%] h-12 w-12 sm:h-20 sm:w-20 rounded-full bg-indigo-400/25 blur-lg animate-pulse-soft-delayed" />
        <div className="absolute top-[62%] left-[30%] h-12 w-12 rounded-full bg-pink-400/30 blur-lg animate-pulse-soft" />
        <div className="sm:hidden absolute top-6 right-2 h-40 w-40 rounded-full bg-gradient-to-tr from-cyan-400/20 to-sky-500/20 blur-2xl animate-float-medium" />
      </div>

      <div className="w-full max-w-md sm:max-w-md md:max-w-lg relative">
        <div className="w-full rounded-2xl theme-bg-card/95 backdrop-blur theme-border theme-text-primary p-6 sm:p-8 shadow-xl ring-1 ring-black/5">
          <Link
            to="/supplier"
            className="theme-dibutton absolute top-4 right-4"
            aria-label={t("close") || "Close"}
          >
            <X className="h-5 w-5" aria-hidden="true" />
          </Link>
          <div className="flex justify-center mb-4">
            <div className="p-2 rounded-full border theme-border bg-white">
              <img
                src={logo}
                alt="Tripfinity"
                className="h-12 sm:h-14 w-auto"
                draggable={false}
              />
            </div>
          </div>

          <h1
            id="register-title"
            className="text-h4-mobile sm:text-h3-tablet lg:text-h2-desktop text-center font-semibold"
          >
            {t("register_account")}
          </h1>
          <p className="mt-2 text-center text-subtitle2-mobile theme-text-secondary">
            {t("login_account")}
          </p>

          <div className="mt-6 sm:mt-8 flex flex-col gap-3 sm:gap-4">
            <form
              onSubmit={submit}
              className="flex flex-col gap-3 sm:gap-4"
              noValidate
              aria-labelledby="register-title"
            >
              <label className="text-body1-mobile font-medium theme-text-secondary">
                {t("name_account")}
                <input
                  id="name_account"
                  name="name"
                  type="text"
                  required
                  value={form.name}
                  onChange={setField("name")}
                  placeholder={t("ent_name_account")}
                  autoComplete="name"
                  className="w-full mt-1 rounded-lg border theme-border bg-transparent px-3 py-3"
                  aria-invalid={!!formError && !form.name.trim()}
                />
              </label>

              <label className="text-body1-mobile font-medium theme-text-secondary">
                {t("email_account")}
                <input
                  id="email"
                  name="email"
                  type="email"
                  required
                  value={form.email}
                  onChange={setField("email")}
                  placeholder={t("ent_email_account")}
                  autoComplete="email"
                  className="w-full mt-1 rounded-lg border theme-border bg-transparent px-3 py-3"
                  aria-invalid={!!formError && !emailRegex.test(form.email)}
                />
              </label>

              <label className="text-body1-mobile font-medium theme-text-secondary">
                {t("passw_account")}
                <div className="relative mt-1">
                  <input
                    id="password"
                    name="password"
                    type={showPassword ? "text" : "password"}
                    required
                    value={form.password}
                    onChange={setField("password")}
                    placeholder={t("ent_passw_account")}
                    autoComplete="new-password"
                    className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 pr-10"
                    aria-invalid={!!formError && form.password.length < 6}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((s) => !s)}
                    className="absolute right-2 top-1/2 -translate-y-1/2"
                  >
                    {showPassword ? (
                      <EyeOff className="h-5 w-5" />
                    ) : (
                      <Eye className="h-5 w-5" />
                    )}
                  </button>
                </div>
              </label>

              <label className="text-body1-mobile font-medium theme-text-secondary">
                {t("re_passw_account")}
                <div className="relative mt-1">
                  <input
                    id="re_password"
                    name="re_password"
                    type={showRePassword ? "text" : "password"}
                    required
                    value={form.rePassword}
                    onChange={setField("rePassword")}
                    placeholder={t("ent_re_passw_account")}
                    autoComplete="new-password"
                    className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 pr-10"
                    aria-invalid={
                      !!formError && form.password !== form.rePassword
                    }
                  />
                  <button
                    type="button"
                    onClick={() => setShowRePassword((s) => !s)}
                    className="absolute right-2 top-1/2 -translate-y-1/2"
                  >
                    {showRePassword ? (
                      <EyeOff className="h-5 w-5" />
                    ) : (
                      <Eye className="h-5 w-5" />
                    )}
                  </button>
                </div>
              </label>

              {formError && (
                <div
                  className="text-red-500 text-center text-sm py-2"
                  role="alert"
                  aria-live="assertive"
                >
                  {formError}
                </div>
              )}

              {error && (
                <div
                  className="text-red-500 text-center text-sm py-2"
                  role="alert"
                  aria-live="assertive"
                >
                  {error}
                </div>
              )}

              <div
                aria-live="polite"
                className="fixed inset-x-0 top-4 flex justify-center z-50 pointer-events-none"
              >
                <div
                  className={`pointer-events-auto max-w-md w-full mx-4 transition-transform duration-300 ease-out transform ${
                    toastVisible
                      ? "translate-y-0 opacity-100"
                      : "-translate-y-6 opacity-0"
                  }`}
                  role="status"
                  aria-hidden={!toastVisible}
                >
                  <div className="border-2 border-success theme-bg-success theme-text-primary rounded-lg shadow-lg px-4 py-3">
                    {t("registration_success_redirect")}
                  </div>
                </div>
              </div>

              <button
                type="submit"
                className={`btn-primary w-full h-12 rounded-full font-semibold mt-5 flex items-center justify-center ${
                  isLoading ? "opacity-50 cursor-not-allowed" : ""
                }`}
                disabled={isLoading}
                aria-disabled={isLoading}
              >
                {isLoading ? (
                  <>
                    <Loader2 className="animate-spin h-5 w-5 mr-2" />
                    {t("register")}
                  </>
                ) : (
                  t("register")
                )}
              </button>
            </form>

            <p className="text-center text-caption-mobile mt-2 theme-text-secondary">
              {t("already_have_an_account")}{" "}
              <Link to="/supplier/login" className="link-brand">
                {t("login")}
              </Link>
            </p>
          </div>
        </div>
      </div>
    </main>
  );
};

export default SupplierRegisterPage;
