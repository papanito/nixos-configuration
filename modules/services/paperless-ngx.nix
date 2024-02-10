{ config, pkgs, ... }:

{
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;
    consumptionDirIsPublic = true;
    mediaDir = "/home/papanito/paperless-ngx/";
    consumptionDir = "/home/papanito/paperless-ngx/consume";
    user = "papanito";

    settings = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_TIME_ZONE = "Europe/Zurich";
      PAPERLESS_FILENAME_FORMAT = "{document_type}/{correspondent}/{created_year}/{correspondent}_{created_year}{created_month}{created_day}_{title}";
      PAPERLESS_CONSUMER_RECURSIVE =  true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      PAPERLESS_TRASH_DIR = "/home/papanito/paperless-ngx/trash";
      PAPERLESS_CONVERT_TMPDIR = "/var/tmp/paperless";
      PAPERLESS_SCRATCH_DIR = "/var/tmp/paperless-scratch";
    };
  };
  systemd.services.paperless-scheduler.after = ["var-lib-paperless.mount"];
  systemd.services.paperless-consumer.after = ["var-lib-paperless.mount"];
  systemd.services.paperless-web.after = ["var-lib-paperless.mount"];
}
