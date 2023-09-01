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
  #   owner = "restic";
  #   group = "users";
  #   permissions = "u=rwx,g=,o=";
  #   capabilities = "cap_dac_read_search=+ep";
  # };

  age.secrets = {
    restic_b2_credentials = {
      file = ../secrets/restic_b2_credentials.age;
    };
    restic_password = {
      file = ../secrets/restic_password.age;
    };
  };

  services.restic.backups.b2 = {
    initialize = false;
    # since this uses an `agenix` secret that's only readable to the
    # root user, we need to run this script as root. If your
    # environment is configured differently, you may be able to do:
    #
    #user = "restic";
    #
    passwordFile = config.age.secrets.restic_password.path;
    # what to backup.
    paths = ["/home/papanito"];
    # the name of your repository.
    repository = "b2:papanito-private-backup:/clawfinger";
    timerConfig = {
      # backup every 1d
      OnUnitActiveSec = "1d";
    };

    environmentFile = config.age.secrets.restic_b2_credentials.path;

    exclude = [
      "**/tmp"
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

  # Instead of doing this, you may alternatively hijack the
  # `awsS3Credentials` argument to pass along these environment
  # vars.
  #
  # If you specified a user above, you need to change it to:
  # systemd.services.user.restic-backups-myaccount = { ... }
  #
  systemd.services.restic-backups-b2 = {

    # environment = {
    #   B2_ACCOUNT_ID = "my_account_id_abc123";
    #   B2_ACCOUNT_KEY = "my_account_key_def456";
    # };
  };

}
