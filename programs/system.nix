{ config, pkgs, ... }:

{
  #linuxKernel.packages.linux_latest_libre.tuxedo-keyboard;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ace
    btrfs-progs
    coreutils
    dnsutils
    curl
    cifs-utils
    exa
    fzf
    home-manager
    yubikey-touch-detector
    parted
    gnupg
    wget
    zsh
    zoxide
    power-profiles-daemon # Makes user-selected power profiles handling available over D-Bus
    gnomeExtensions.power-profile-switcher # Automatically switch between power profiles based on power supply and percentage.
    busybox # Tiny versions of common UNIX utilities in a single small executable
    usbutils # Tools for working with USB devices, such as lsusb
    cifs-utils # Tools for managing Linux CIFS client filesystems
    nfstrace # NFS and CIFS tracing/monitoring/capturing/analyzing tool
    s3fs # Mount an S3 bucket as filesystem through FUSE
    ventoy-full # A New Bootable USB Solution
  ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # To add the zsh package to /etc/shells you must update environment.shells.
  environment.shells = with pkgs; [ zsh ];
}
