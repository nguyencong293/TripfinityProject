// Minimal Google Identity Services types
// Ref: https://developers.google.com/identity/gsi/web/reference/js-reference

declare namespace google {
  namespace accounts {
    namespace id {
      interface CredentialResponse {
        credential: string;
        select_by?: string;
        clientId?: string;
      }

      type PromptMomentNotification = unknown;

      type GsiButtonConfiguration = {
        type?: "standard" | "icon";
        theme?: "outline" | "filled_blue" | "filled_black";
        size?: "large" | "medium" | "small";
        text?: "signin_with" | "signup_with" | "continue_with" | "signin";
        shape?: "rectangular" | "pill" | "circle" | "square";
        logo_alignment?: "left" | "center";
        width?: number | string;
        locale?: string;
      };

      interface IdConfiguration {
        client_id: string;
        callback: (response: CredentialResponse) => void;
        ux_mode?: "popup" | "redirect";
        auto_select?: boolean;
      }

      function initialize(config: IdConfiguration): void;
      function prompt(
        momentListener?: (res: PromptMomentNotification) => void
      ): void;
      function renderButton(
        parent: HTMLElement,
        options?: GsiButtonConfiguration
      ): void;
    }
  }
}

interface Window {
  google?: typeof google;
}
