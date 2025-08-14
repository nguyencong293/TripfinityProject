export interface Language {
  code: string;
  name: string;
  flag: string;
}

export interface Translation {
  app_title: string;
  welcome: string;
  app_description: string;
  language: string;
  language_name: string;
  current_language: string;
  switch_language_instruction: string;
  [key: string]: string;
}
