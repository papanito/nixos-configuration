{ config, pkgs, ... }:

{
  users.users.paperless = {
    isSystemUser = true;
    group = "paperless";
    description = "Service account for non-privileged tasks";
    # Prevents interactive login
    shell = pkgs.shadow; 
    # If the service needs a home directory for config/state
    createHome = true;
    home = "/var/lib/paperless";
  };

  # Corresponding group
  users.groups.paperless = {};
  users.users.nixos = {
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "paperless"
    ];
  };
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;
    consumptionDirIsPublic = true;
    user = "paperless";
    domain = "paperless.home";

    settings = {
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

  networking.firewall.allowedTCPPorts = [ 58080 ];

  # This ensures that every time the system boots or you run nixos-rebuild, the permissions are enforced
  systemd.tmpfiles.rules = [
    # Type | Path | Mode | User | Group | Age | Argument
    "d /var/lib/paperless 0750 paperless paperless -"
    "Z /var/lib/paperless - paperless paperless -"
  ];
}
