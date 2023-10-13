{ config, pkgs, ... }:

{
  #linuxKernel.packages.linux_latest_libre.tuxedo-keyboard;

  environment.systemPackages = with pkgs; [
    btrfs-progs
    busybox # Tiny versions of common UNIX utilities in a single small executable
    cifs-utils # Tools for managing Linux CIFS client filesystems
    coreutils # The GNU Core Utilities
    cryfs # Cryptographic filesystem for the cloud
    dnsutils
    home-manager
    parted
    ncdu # Disk usage analyzer with an ncurses interface
    power-profiles-daemon # Makes user-selected power profiles handling available over D-Bus
    gnomeExtensions.power-profile-switcher # Automatically switch between power profiles based on power supply and percentage.
    sshfs # FUSE-based filesystem that allows remote filesystems to be mounted over SSH
    nfstrace # NFS and CIFS tracing/monitoring/capturing/analyzing tool
    s3fs # Mount an S3 bucket as filesystem through FUSE
    usbutils # Tools for working with USB devices, such as lsusb
    vt-cli # VirusTotal Command Line Interface
    ventoy-full # A New Bootable USB Solution
    wireplumber # A modular session / policy manager for PipeWire
    bluez # Bluetooth support for Linux
    bluez-tools # Command line bluetooth manager for Bluez5
    blueman # GTK-based Bluetooth Manager
    brightnessctl # This program allows you read and control device brightness

    lynis # Security auditing tool for Linux, macOS, and UNIX-based systems
    chkrootkit # Locally checks for signs of a rootkit
    clamav # Antivirus engine designed for detecting Trojans, viruses, malware and other malicious threats
  ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  # environment.interactiveShellInit = ''
  #   alias exa=eza
  # '';

  # To add the zsh package to /etc/shells you must update environment.shells.
  environment.shells = with pkgs; [ zsh ];
}
