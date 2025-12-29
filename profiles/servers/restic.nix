{ config, pkgs, name, ... }:
{
  environment.systemPackages = with pkgs; [
    restic
    autorestic
  ];

   sops = {
    secrets.restic_password = {
      sopsFile = ./secrets.yaml;
    };
    secrets.B2_ACCOUNT_ID = {
      sopsFile = ./secrets.yaml;
    };
    secrets.B2_ACCOUNT_KEY = {
      sopsFile = ./secrets.yaml;
    };
    templates."restic.env".content = ''
      B2_ACCOUNT_ID=${config.sops.placeholder.B2_ACCOUNT_ID}
      B2_ACCOUNT_KEY=${config.sops.placeholder.B2_ACCOUNT_KEY}
    '';
  };

  # Inject the dependency into the generated service
  systemd.services."restic-backups-b2" = {
    unitConfig = {
      OnSuccess = "systemd-googlechat-notifier@%N.service";
      OnFailure = "systemd-googlechat-notifier@%N.service";
    };
  };

  services.restic.backups = {
    b2 = {
      initialize = true;
      #
      #user = "restic";
      #
      passwordFile = "${config.sops.secrets.restic_password.path}";
      # what to backup.
      paths = [
        "/var/lib"
      ];
      # the name of your repository.
      repository = "b2:papanito-private-backup:/${name}";
      timerConfig = {
        # backup every 1d
        OnCalendar = "daily";
        Persistent = true; 
        OnSuccess = "systemd-googlechat-notifier@%N.service";
        OnFailure = "systemd-googlechat-notifier@%N.service";
      };

      # defined in modules/sops.nix
      environmentFile = "${config.sops.templates."restic.env".path}";

      exclude = [
        "nixos"
        "systemd"
        "*log"
        "Network*"
      ];

      # keep 7 daily, 5 weekly, and 10 annual backups
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 6"
        "--keep-yearly 10"
      ];
    };
  };
}
