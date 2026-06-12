{ pkgs, config, ... }:
{
  sops.secrets.rclone_config = {
    sopsFile = ./secrets.yaml;
    # The user will add the actual secret to the sops file later
  };

  environment.systemPackages = [ pkgs.rclone ];

  systemd.services.rclone-sync-movies = {
    enable = false;
    description = "Sync Jellyfin movie files with rclone";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    unitConfig = {
      OnSuccess = "systemd-googlechat-notifier@%N.service";
      OnFailure = "systemd-googlechat-notifier@%N.service";
    };
    serviceConfig = {
      Type = "oneshot";
      # Using /media/Movies as a placeholder path, adjust as needed
      ExecStart = "${pkgs.rclone}/bin/rclone --config ${config.sops.secrets.rclone_config.path} sync /media b2:papanito-media-homelab --verbose";
      User = "root";
    };
  };

  systemd.timers.rclone-sync-movies = {
    enable = false;
    description = "Timer for Jellyfin movie files rclone sync";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };
}
