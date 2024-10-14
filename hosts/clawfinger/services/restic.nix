{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    restic
    autorestic
  ];

  # If you want to back up your system without running restic as root, you can create a user and security wrapper to give restic the capability to read anything on the filesystem as if it were running as root. The following will create the wrapper at /run/wrappers/bin/restic

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

  services.restic.backups = {
    b2 = {
      initialize = false;
      #
      #user = "restic";
      #
      passwordFile = "${config.sops.secrets.restic_password.path}";
      # what to backup.
      paths = ["/home/papanito"];
      # the name of your repository.
      repository = "b2:papanito-private-backup:/clawfinger";
      timerConfig = {
        # backup every 1d
        OnCalendar = "daily";
        Persistent = true; 
        OnSuccess = "systemd-desktop-notifier@%N.service,systemd-googlechat-notifier@%N.service";
        OnFailure = "systemd-desktop-notifier@%N.service,systemd-googlechat-notifier@%N.service";
      };

      # defined in modules/sops.nix
      environmentFile = "${config.sops.templates."restic.env".path}";

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
      paths = ["/home/papanito"];
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
