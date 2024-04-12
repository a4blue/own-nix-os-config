{config, ...}: {
  sops.secrets.paperless_admin_mail = {};
  sops.secrets.paperless_admin_password = {};
  sops.secrets.paperless_secret_key = {};
  services.paperless = {
    enable = true;
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_URL = "https://homelab.armadillo-snake.ts.net";
      PAPERLESS_FORCE_SCRIPT_NAME = "/paperless";
      PAPERLESS_STATIC_URL = "/paperless/static/";
      PAPERLESS_ADMIN_USER = "a4blue";
      #PAPERLESS_ADMIN_MAIL = builtins.readFile config.sops.secrets.paperless_admin_mail.path;
      #PAPERLESS_ADMIN_PASSWORD = builtins.readFile config.sops.secrets.paperless_admin_password.path;
      #PAPERLESS_SECRET_KEY = builtins.readFile config.sops.secrets.paperless_secret_key.path;
    };
  };

  environment.persistence."/persistent" = {
    directories = [
      "/var/lib/paperless"
    ];
  };
}
