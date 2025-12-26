export interface Language {
  code: string;
  name: string;
  flag: string;
}

// Flexible translation type to support both flat and nested structures
export type TranslationValue = string | { [key: string]: TranslationValue };

export interface Translation {
  app_name: string;
  light: string;
  dark: string;
  system: string;
  onboarding_1: string;
  onboarding_2: string;
  onboarding_3: string;
  onboarding_4: string;
  skip: string;
  next: string;
  previous: string;
  login: string;
  page_not_found: string;
  back_to_home: string;
  register_account: string;
  name_account: string;
  ent_name_account: string;
  email_account: string;
  ent_email_account: string;
  passw_account: string;
  ent_passw_account: string;
  re_passw_account: string;
  ent_re_passw_account: string;
  register: string;
  already_have_an_account: string;
  login_account: string;
  forg_account_txt: string;
  dont_have_an_account: string;
  forgot_account: string;
  send_link: string;
  check_number_code: string;
  authed: string;
  update_password: string;
  new_password: string;
  ent_new_password: string;
  update: string;
  email_required: string;
  email_invalid: string;
  name_required: string;
  passw_invalid: string;
  confirm_required: string;
  password_mismatch: string;
  login_with_google: string;
  press_back_again_to_exit: string;
  resend_after_seconds: string;
  resend_code: string;
  close: string;
  login_with_email: string;
  please_fill_all_fields: string;
  registration_success_redirect: string;

  [key: string]: TranslationValue;
}
