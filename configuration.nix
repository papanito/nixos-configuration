# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware # Include the results of the hardware scan.

    ./modules
    ./boot.nix
    ./users.nix
  ];

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


  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  nix = {
    package = pkgs.nixFlakes;
    extraOptions= ''
      experimental-features = nix-command flakes
    '';
    # Automatic Garbage Collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
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

  console = {
    earlySetup = true;
    #font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "sg";
  };

  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  security.wrappers = {
    fusermount.source  = "${pkgs.fuse}/bin/fusermount";
  };

  environment.systemPackages = [
    pkgs.linuxKernel.packages.linux_latest_libre.tuxedo-keyboard
  ];
}
