{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    restic
    autorestic
  ];

  services.restic.backups = {
    b2 = {
      initialize = false;
      #
      #user = "restic";
      #
      passwordFile = "${config.sops.secrets.restic_password.path}";
      # what to backup.
      paths = [
        "/var/lib/paperless/"
        "/var/lib/redis-paperless/"
      ];
      # the name of your repository.
      repository = "b2:papanito-private-backup:/{config.networking.hostName}";
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
      ];

      # keep 7 daily, 5 weekly, and 10 annual backups
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 6"
        "--keep-yearly 10"
      ];
    };
    local = {
      initialize = true;
      #
      #user = "restic";
      #
      passwordFile = "${config.sops.secrets.restic_password.path}";
      # what to backup.
      paths = [
        "/home/papanito"
        "/var/lib/paperless/"
        "/var/lib/redis-paperless/"
      ];
      # the name of your repository.
      repository = "/home/backup/backup/clawfinger";
      timerConfig = {
        # backup every 1d
        OnCalendar = "daily";
        Persistent = true; 
      };

      exclude = [
        "**/cs"
        "*/.android*"
        "*/.Android*"
        "*/.ansible/collections"
        "*/.Apache*"
        "*/.BurpSuite"
        "*/.cache"
        "*/.cargo"
        "*/.chrome"
        "*/.dartServer"
        "*/.donet"
        "*/.dotnet"
        "*/.eclipse"
        "*/.gem"
        "*/.local"
        "*/.m2/repository"
        "*/.mozilla"
        "*/.nuget"
        "*/.nvm"
        "*/.steam"
        "*/.thumbnails"
        "*/.vscode*/extensions"
        "*/.wine"
        "*/*.iso"
        "*/*.log"
        "*/*cache"
        "*/*Cache"
        "*/*thumbs"
        "*/bin/*"
        "*/*cache*"
        "*/*Cache*"
        "*/Downloads"
        "*/Dropbox"
        "*/Games"
        "*/gnome-shell"
        "*/go"
        "*/google-chrome*"
        "*/gPodder"
        "*/Insync"
        "*/Music"
        "*/node_modules"
        "*/Public"
        "*/share"
        "*/snap"
        "**/tmp"
        "*/Trash"
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
  # Instead of doing this, you may alternatively hijack the
  # `awsS3Credentials` argument to pass along these environment
  # vars.
  #
  # If you specified a user above, you need to change it to:
  # systemd.services.user.restic-backups-myaccount = { ... }
  #
  # systemd.services.restic-backups-b2 = {
  #   # environment = {
  #   #   B2_ACCOUNT_ID = "my_account_id_abc123";
  #   #   B2_ACCOUNT_KEY = "my_account_key_def456";
  #   # };
  # };
}
