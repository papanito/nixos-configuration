{ config, pkgs, name, ... }:
{
  environment.systemPackages = with pkgs; [
    restic
    autorestic
  ];

  # If you want to back up your system without running restic as root, you can create a user and security wrapper to give restic the capability to read anything on the filesystem as if it were running as root. The following will create the wrapper at /run/wrappers/bin/restic
  
   sops = {
    secrets.restic_password = {
      sopsFile = ../secrets.yaml;
    };
    secrets.B2_ACCOUNT_ID = {
      sopsFile = ../secrets.yaml;
    };
    secrets.B2_ACCOUNT_KEY = {
      sopsFile = ../secrets.yaml;
    };
    templates."restic.env".content = ''
      B2_ACCOUNT_ID=${config.sops.placeholder.B2_ACCOUNT_ID}
      B2_ACCOUNT_KEY=${config.sops.placeholder.B2_ACCOUNT_KEY}
    '';
  };

  # users.users.restic = {
  #   isNormalUser = true;
  # };

  # security.wrappers.restic = {
  #   source = "${pkgs.restic.out}/bin/restic";
  #   owner = "papanito";
  #   group = "users";
  #   permissions = "u=rwx,g=,o=";
  #   #capabilities = "cap_dac_read_search=+ep";
  # };
  # Inject the dependency into the generated service
  systemd.services."restic-backups-b2" = {
    unitConfig = {
      OnSuccess = "systemd-googlechat-notifier@%N.service";
      OnFailure = "systemd-googlechat-notifier@%N.service";
    };
  };
  services.restic.backups = {
    b2 = {
      initialize = false;
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
        "*/.android*"
        "*/.Android*"
        "*/.ansible/collections"
        "*/.Apache*"
        "*/.BurpSuite"
        "*/.cache"
        "*/.local/share"
        "*/.cargo"
        "*/.chrome"
        "*/.dartServer"
        "*/.donet"
        "*/.dotnet"
        "*/.eclipse"
        "*/.gem"
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
        "*/Videos/Children"
        "*/Videos/Movies"
        "*/Videos/Music"
        "*/Virtualbox"
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
      repository = "/home/backup/backup/${name}";
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
}
