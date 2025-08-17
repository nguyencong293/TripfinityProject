import { useLanguage } from "../../hooks/useLanguage";
import { Link } from "react-router-dom";
import logo from "../../assets/images/logo.png";
import { useCallback, useEffect, useRef, useState } from "react";
import { Eye, EyeOff, X } from "lucide-react";

const OTP_LENGTH = 6;

const SupplierForgetAccountPage: React.FC = () => {
  const { t } = useLanguage();

  const [step, setStep] = useState<number>(0);

  const [email, setEmail] = useState("");
  const [otpValues, setOtpValues] = useState<string[]>(
    Array.from({ length: OTP_LENGTH }).map(() => "")
  );
  const otpInputsRef = useRef<Array<HTMLInputElement | null>>(
    Array.from({ length: OTP_LENGTH }).map(() => null)
  );

  const [newPassword, setNewPassword] = useState("");
  const [rePassword, setRePassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showRePassword, setShowRePassword] = useState(false);

  const [resendCooldown, setResendCooldown] = useState<number>(0);
  const cooldownTimerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(() => {
    document.title = t("forgot_account");
    return () => {
      if (cooldownTimerRef.current) {
        clearInterval(cooldownTimerRef.current);
        cooldownTimerRef.current = null;
      }
    };
  }, [t]);

  const startResendCooldown = useCallback((seconds = 120) => {
    setResendCooldown(seconds);
    if (cooldownTimerRef.current) {
      clearInterval(cooldownTimerRef.current);
    }
    cooldownTimerRef.current = setInterval(() => {
      setResendCooldown((prev) => {
        if (prev <= 1) {
          if (cooldownTimerRef.current) {
            clearInterval(cooldownTimerRef.current);
            cooldownTimerRef.current = null;
          }
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  }, []);

  const setOtpRef = useCallback(
    (index: number) => (el: HTMLInputElement | null) => {
      otpInputsRef.current[index] = el;
    },
    []
  );

  const focusInput = (index: number) => {
    otpInputsRef.current[index]?.focus();
  };

  const handleEmailSubmit = useCallback(
    (e?: React.FormEvent) => {
      e?.preventDefault?.();
      if (!email) return;
      startResendCooldown(120);
      setOtpValues(Array.from({ length: OTP_LENGTH }).map(() => ""));
      setTimeout(() => focusInput(0), 100);
      setStep(1);
    },
    [email, startResendCooldown]
  );

  const handleOtpChange = useCallback((index: number, value: string) => {
    const onlyDigit = value.replace(/\D/g, "").slice(0, 1);
    setOtpValues((prev) => {
      const next = [...prev];
      next[index] = onlyDigit;
      return next;
    });
    if (onlyDigit && index + 1 < OTP_LENGTH) {
      focusInput(index + 1);
    }
  }, []);

  const handleOtpKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLInputElement>, i: number) => {
      const key = e.key;
      if (key === "Backspace") {
        if (otpValues[i]) {
          setOtpValues((prev) => {
            const next = [...prev];
            next[i] = "";
            return next;
          });
        } else if (i > 0) {
          focusInput(i - 1);
          setOtpValues((prev) => {
            const next = [...prev];
            next[i - 1] = "";
            return next;
          });
        }
      } else if (key === "ArrowLeft" && i > 0) {
        focusInput(i - 1);
      } else if (key === "ArrowRight" && i + 1 < OTP_LENGTH) {
        focusInput(i + 1);
      }
    },
    [otpValues]
  );

  const handleOtpPaste = useCallback(
    (e: React.ClipboardEvent<HTMLInputElement>) => {
      e.preventDefault();
      const pasted = e.clipboardData
        .getData("text")
        .replace(/\D/g, "")
        .slice(0, OTP_LENGTH);
      if (!pasted) return;
      const chars = pasted.split("");
      setOtpValues((prev) => {
        const next = [...prev];
        for (let i = 0; i < chars.length; i++) {
          next[i] = chars[i];
        }
        return next;
      });
      const nextFocusIndex = Math.min(chars.length, OTP_LENGTH - 1);
      setTimeout(() => focusInput(nextFocusIndex), 0);
    },
    []
  );

  const handleResend = useCallback(() => {
    if (resendCooldown > 0) return;
    setOtpValues(Array.from({ length: OTP_LENGTH }).map(() => ""));
    startResendCooldown(120);
    setTimeout(() => focusInput(0), 100);
  }, [resendCooldown, startResendCooldown]);

  const handleVerifyOtp = useCallback(
    (e?: React.FormEvent) => {
      e?.preventDefault?.();
      const otp = otpValues.join("");
      if (otp.length !== OTP_LENGTH) return;
      setStep(2);
    },
    [otpValues]
  );

  const handleUpdatePassword = useCallback(
    (e?: React.FormEvent) => {
      e?.preventDefault?.();
      if (!newPassword || newPassword.length < 6) return;
      if (newPassword !== rePassword) return;
      alert(`${t("update_password")} ${t("success")}`);
      setEmail("");
      setOtpValues(Array.from({ length: OTP_LENGTH }).map(() => ""));
      setNewPassword("");
      setRePassword("");
      setStep(0);
    },
    [newPassword, rePassword, t]
  );

  const passwordsMatch =
    newPassword && rePassword && newPassword === rePassword;

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
            id="forget-title"
            className="text-h4-mobile sm:text-h3-tablet lg:text-h2-desktop text-center font-semibold"
          >
            {t("forgot_account")}
          </h1>

          <div className="mt-6 sm:mt-8 flex flex-col gap-3 sm:gap-4">
            {step === 0 && (
              <form
                onSubmit={handleEmailSubmit}
                noValidate
                aria-labelledby="forget-title"
                className="flex flex-col gap-3 sm:gap-4"
              >
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

                <button
                  type="button"
                  onClick={() => handleEmailSubmit()}
                  className="btn-primary w-full h-12 rounded-full font-semibold mt-2"
                  disabled={!email}
                >
                  {t("send_link")}
                </button>

                <p className="text-center text-caption-mobile mt-2 theme-text-secondary">
                  {t("already_have_an_account")}{" "}
                  <Link to="/supplier/login" className="link-brand">
                    {t("login")}
                  </Link>
                </p>
              </form>
            )}

            {step === 1 && (
              <div className="flex flex-col gap-3">
                <p className="text-center text-body1-mobile">
                  {t("check_number_code")}
                </p>

                <form
                  onSubmit={handleVerifyOtp}
                  className="flex flex-col items-center gap-4"
                >
                  <div className="flex gap-2 justify-center">
                    {Array.from({ length: OTP_LENGTH }).map((_, i) => (
                      <input
                        key={i}
                        ref={setOtpRef(i)}
                        inputMode="numeric"
                        pattern="\d*"
                        value={otpValues[i]}
                        onChange={(e) => handleOtpChange(i, e.target.value)}
                        onKeyDown={(e) => handleOtpKeyDown(e, i)}
                        onPaste={handleOtpPaste}
                        className="w-12 h-12 text-center rounded-lg border theme-border bg-transparent px-2 py-2 text-h5-mobile"
                        maxLength={1}
                        aria-label={`OTP ${i + 1}`}
                      />
                    ))}
                  </div>

                  <div className="text-center">
                    {resendCooldown > 0 ? (
                      <div className="text-sm theme-text-secondary">
                        {t("resend_after_seconds")} {resendCooldown}s
                      </div>
                    ) : (
                      <button
                        type="button"
                        onClick={handleResend}
                        className="text-sm link-brand"
                      >
                        {t("resend_code")}
                      </button>
                    )}
                  </div>

                  <button
                    type="button"
                    onClick={() => handleVerifyOtp()}
                    className="btn-primary w-full h-12 rounded-full font-semibold mt-2"
                    disabled={otpValues.join("").length !== OTP_LENGTH}
                  >
                    {t("authed")}
                  </button>

                  <button
                    type="button"
                    className="text-sm mt-1 theme-text-secondary underline"
                    onClick={() => {
                      setStep(0);
                      if (cooldownTimerRef.current) {
                        clearInterval(cooldownTimerRef.current);
                        cooldownTimerRef.current = null;
                        setResendCooldown(0);
                      }
                    }}
                  >
                    {t("previous")}
                  </button>
                </form>
              </div>
            )}

            {step === 2 && (
              <form
                onSubmit={handleUpdatePassword}
                noValidate
                className="flex flex-col gap-3"
              >
                <label className="text-body1-mobile font-medium theme-text-secondary">
                  {t("new_password")}
                  <div className="relative mt-1">
                    <input
                      id="new_password"
                      type={showPassword ? "text" : "password"}
                      required
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      placeholder={t("ent_new_password")}
                      autoComplete="new-password"
                      className="w-full rounded-lg border theme-border bg-transparent px-3 py-3 pr-10"
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

                {!passwordsMatch && rePassword.length > 0 && (
                  <div className="text-sm theme-text-secondary">
                    {t("password_mismatch")}
                  </div>
                )}

                <div className="flex gap-3 mt-5">
                  <button
                    type="button"
                    onClick={() => setStep(1)}
                    className="w-full h-12 rounded-full border"
                  >
                    {t("previous")}
                  </button>
                  <button
                    type="button"
                    onClick={() => handleUpdatePassword()}
                    className="btn-primary w-full h-12 rounded-full font-semibold"
                    disabled={
                      !newPassword || !passwordsMatch || newPassword.length < 6
                    }
                  >
                    {t("update")}
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      </div>
    </main>
  );
};

export default SupplierForgetAccountPage;
