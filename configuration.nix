# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    ./common
    ./modules
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable"; # Did you read the comment?

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
      options = "--delete-older-than 250d";
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

  services.envfs.enable = true;

  nixpkgs.config = {
    permittedInsecurePackages = [
      "electron"
    ];
    allowUnfree = true;
  };

  environment.etc = {
    # Creates /etc/forwarding-rules.txt
    "forwarding-rules.txt" = {
      text = ''
        ##################################
        #        Forwarding rules        #
        ##################################

        ## This is used to route specific domain names to specific servers.
        ## The general format is:
        ## <domain> <server address>[:port] [, <server address>[:port]...]
        ## IPv6 addresses can be specified by enclosing the address in square brackets.

        ## In order to enable this feature, the "forwarding_rules" property needs to
        ## be set to this file name inside the main configuration file.

        ## Blocking IPv6 may prevent local devices from being discovered.
        ## If this happens, set `block_ipv6` to `false` in the main config file.

        ## Forward *.lan, *.local, *.home, *.home.arpa, *.internal and *.localdomain to 10.0.0.10
        lan              10.0.0.10
        local            10.0.0.10
        home             10.0.0.10
        home.arpa        10.0.0.10
        internal         10.0.0.10
        localdomain      10.0.0.10
        192.in-addr.arpa 10.0.0.10

        ## Forward queries for example.com and *.example.com to 9.9.9.9 and 8.8.8.8
        # example.com      9.9.9.9,8.8.8.8

        ## Forward queries to a resolver using IPv6
        # ipv6.example.com [2001:DB8::42]:53

        ## Forward queries for .onion names to a local Tor client
        ## Tor must be configured with the following in the torrc file:
        ## DNSPort 9053
        ## AutomapHostsOnResolve 1

        onion            127.0.0.1:9053
      '';

      # The UNIX file mode bits
      mode = "0444";
    };
  };
}
