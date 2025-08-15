import { useLanguage } from "../../hooks/useLanguage";
import { Link } from "react-router-dom";
import logo from "../../assets/images/logo.png";
import { useEffect, useState } from "react";
import { Eye, EyeOff, X } from "lucide-react";

const ForgetAccountPage: React.FC = () => {
  const { t } = useLanguage();

  const [showPassword, setShowPassword] = useState(false);
  const [showRePassword, setShowRePassword] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [rePassword, setRePassword] = useState("");

  useEffect(() => {
    document.title = t("register_account");
  }, [t]);

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log("Submit register:", { name, email, password, rePassword });
    // TODO: call register API
  };

  const passwordsMatch = password && rePassword && password === rePassword;

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
            to="/"
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
            id="login-title"
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
              aria-labelledby="login-title"
            >
              <label className="text-body1-mobile font-medium theme-text-secondary">
                {t("name_account")}
                <input
                  id="name_account"
                  type="text"
                  required
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder={t("ent_name_account")}
                  autoComplete="name"
                  className="w-full mt-1 rounded-lg border theme-border bg-transparent px-3 py-3"
                />
              </label>

              <label className="text-body1-mobile font-medium theme-text-secondary">
                {t("email_account")}
                <input
                  id="email"
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder={t("ent_email_account")}
                  autoComplete="email"
                  className="w-full mt-1 rounded-lg border theme-border bg-transparent px-3 py-3"
                />
              </label>

              <label className="text-body1-mobile font-medium theme-text-secondary">
                {t("passw_account")}
                <div className="relative mt-1">
                  <input
                    id="password"
                    type={showPassword ? "text" : "password"}
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder={t("ent_passw_account")}
                    autoComplete="new-password"
                    className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 pr-10"
                  />
                  <button
                    type="button"
                    aria-label={
                      showPassword ? t("hide_password") : t("show_password")
                    }
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
                    type={showRePassword ? "text" : "password"}
                    required
                    value={rePassword}
                    onChange={(e) => setRePassword(e.target.value)}
                    placeholder={t("ent_re_passw_account")}
                    autoComplete="new-password"
                    className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 pr-10"
                  />
                  <button
                    type="button"
                    aria-label={
                      showRePassword ? t("hide_password") : t("show_password")
                    }
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

              <button
                type="submit"
                className="btn-primary w-full h-12 rounded-full font-semibold mt-5"
                disabled={!name || !email || !passwordsMatch}
              >
                {t("register")}
              </button>
            </form>

            <p className="text-center text-caption-mobile mt-2 theme-text-secondary">
              {t("already_have_an_account")}{" "}
              <Link to="/login" className="link-brand">
                {t("login")}
              </Link>
            </p>
          </div>
        </div>
      </div>
    </main>
  );
};

export default ForgetAccountPage;
