{ config, pkgs, version, ... }:
{
  services.journald.extraConfig = ''
    SystemMaxUse=2G
  '';
  
  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "de_CH.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_LANG = "en_US.UTF-8";
    LC_ADDRESS = "de_CH.utf8";
    LC_IDENTIFICATION = "de_CH.utf8";
    LC_MEASUREMENT = "de_CH.utf8";
    LC_MONETARY = "de_CH.utf8";
    LC_NAME = "de_CH.utf8";
    LC_NUMERIC = "de_CH.utf8";
    LC_PAPER = "de_CH.utf8";
    LC_TELEPHONE = "de_CH.utf8";
    LC_TIME = "de_CH.utf8";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = version; # Did you read the comment?

  nix = {
    #package = pkgs.nixFlakes;
    #package = pkgs.nixVersions.git;
    extraOptions= ''
      experimental-features = nix-command flakes
    '';
    # Automatic Garbage Collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    setting = {
      # Tells Nix this machine can natively run these architectures (via binfmt)
      extra-platforms = [ "aarch64-linux" "armv7l-linux" ];
      
      # Crucial: Allow the daemon to download substitutes for these platforms
      builders-use-substitutes = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # https://discourse.nixos.org/t/best-practices-for-auto-upgrades-of-flake-enabled-nixos-systems/31255
  system.autoUpgrade = {
    enable = true;
    #flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
}
