{ config, pkgs, ... }:

{
  #linuxKernel.packages.linux_latest_libre.tuxedo-keyboard;

  environment.systemPackages = with pkgs; [
    ace
    btrfs-progs
    busybox # Tiny versions of common UNIX utilities in a single small executable
    cifs-utils # Tools for managing Linux CIFS client filesystems
    coreutils
    cryfs # Cryptographic filesystem for the cloud
    curl
    dnsutils
    exa # a modern replacement for ls
    # eza # replacement for exa which is unmaintained
    fzf
    home-manager
    parted
    gnupg
    power-profiles-daemon # Makes user-selected power profiles handling available over D-Bus
    gnomeExtensions.power-profile-switcher # Automatically switch between power profiles based on power supply and percentage.
    sshfs # FUSE-based filesystem that allows remote filesystems to be mounted over SSH
    nfstrace # NFS and CIFS tracing/monitoring/capturing/analyzing tool
    s3fs # Mount an S3 bucket as filesystem through FUSE
    usbutils # Tools for working with USB devices, such as lsusb
    ventoy-full # A New Bootable USB Solution
    wget
    yubikey-touch-detector
    zsh
    zoxide
  ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.interactiveShellInit = ''
    alias ls=exa
  '';

  # To add the zsh package to /etc/shells you must update environment.shells.
  environment.shells = with pkgs; [ zsh ];
}
