{ config, pkgs, ... }:

{
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;
    consumptionDirIsPublic = true;
    mediaDir = "/home/papanito/paperless-ngx/media/";
    consumptionDir = "/home/papanito/paperless-ngx/consume";

    extraConfig = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_TIME_ZONE = "Europe/Zurich";
      PAPERLESS_FILENAME_FORMAT = "{document_type}/{correspondent}/{created_year}/{correspondent}_{created_year}{created_month}{created_day}_{title}";
      PAPERLESS_CONSUMER_RECURSIVE =  true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
    };
  };
  systemd.services.paperless-scheduler.after = ["var-lib-paperless.mount"];
  systemd.services.paperless-consumer.after = ["var-lib-paperless.mount"];
  systemd.services.paperless-web.after = ["var-lib-paperless.mount"];
}
