{ lib, config, pkgs, ... }:
{
  imports = [
    ./networking
    #./services

    ./cloud.nix
    ./container.nix
    ./development.nix
    ./fonts.nix
    ./kde.nix
    ./gnome.nix
    ./multimedia.nix
    ./office.nix
    ./pam.nix
    ./printing.nix
    ./system.nix
    ./sops.nix
    ./sudo.nix
    ./tmpfs.nix
    ./virt.nix
    ./wine.nix
  ];

  environment.systemPackages = with pkgs; [
    ### Shell and Terminal tools and apps ###
    age # Modern encryption tool with small explicit keys
    bat # A cat(1) clone with syntax highlighting and Git integration
    btop # A monitor of resources
    bats # Bash Automated Testing System
    curl # A command line tool for transferring files with URL syntax
    direnv # A shell extension that manages your environment
    nix-direnv # A fast, persistent use_nix implementation for direnv
    eza # replacement for exa which is unmaintained
    fzf # A command-line fuzzy finder written in Go
    fd # A simple, fast and user-friendly alternative to find
    feh # A light-weight image viewer
    fq # jq for binary formats
    glow # Render markdown on the CLI, with pizzazz
    helix
    jq # A lightweight and flexible command-line JSON processor
    gnupg # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
    gtop # graphic top
    gum # a tool for glamorous shell scripts
    guake # Drop-down terminal for GNOME
    imgcat
    lsix # ls for images
    lsof # Tool to list open files
    melt # Backup and restore Ed25519 SSH keys with seed words
    mods # AI on the command line
    navi # An interactive cheatsheet tool for the command-line and application launchers
    miller # Like awk, sed, cut, join, and sort for data formats such as CSV, TSV, JSON, JSON Lines, and positionally-indexed
    nq # Unix command line queue utility
    pueue # A daemon for managing long running shell commands
    ranger # File manager with minimalistic curses interface
    sad # CLI tool to search and replace
    tomb
    pinentry-tty # GnuPG’s interface to passphrase input
    timg # Terminal image and video viewer
    steghide #Open source steganography program
    terminator # Terminal emulator with support for tiling and tabs
    timg # Terminal image and video viewer
    thefuck # Magnificent app which corrects your previous console command
    w3m # A text-mode web browser
    watchman # Watches files and takes action when they change
    wget
    unzip
    xclip # Tool to access the X clipboard from a console application
    xdg-ninja
    xz # A general-purpose data compression software, successor of LZMA
    yq # Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML documents
    zellij # A terminal workspace with batteries included
    zsh # zsh shell
    zoxide # A fast cd command that learns your habits

    ### System ###
    btrfs-progs
    bluez # Bluetooth support for Linux
    bluez-tools # Command line bluetooth manager for Bluez5
    blueman # GTK-based Bluetooth Manager
    brightnessctl # This program allows you read and control device brightness
    cifs-utils # Tools for managing Linux CIFS client filesystems
    coreutils # The GNU Core Utilities
    cryfs # Cryptographic filesystem for the cloud
    dnsutils
    file # A program that shows the type of files
    home-manager
    paper-age # Easy and secure paper backups of secrets
    parted
    psmisc # A set of small useful utilities that use the proc filesystem (such as fuser, killall and pstree)
    ncdu # Disk usage analyzer with an ncurses interface
    power-profiles-daemon # Makes user-selected power profiles handling available over D-Bus
    gnomeExtensions.power-profile-switcher # Automatically switch between power profiles based on power supply and percentage.
    sshfs # FUSE-based filesystem that allows remote filesystems to be mounted over SSH
    ssh-tools # Collection of various tools using ssh
    nfstrace # NFS and CIFS tracing/monitoring/capturing/analyzing tool
    s3fs # Mount an S3 bucket as filesystem through FUSE
    usbutils # Tools for working with USB devices, such as lsusb
    ventoy-full # A New Bootable USB Solution
    wireplumber # A modular session / policy manager for PipeWire
    polkit # A toolkit for defining and handling the policy that allows unprivileged processes to speak to privileged processes
    # yubikey-touch-detector

    ### Security ###
    chkrootkit # Locally checks for signs of a rootkit
    clamav # Antivirus engine designed for detecting Trojans, viruses, malware and other malicious threats
    lynis # Security auditing tool for Linux, macOS, and UNIX-based systems
    vt-cli # VirusTotal Command Line Interface
    vuls #Agent-less vulnerability scanner
  ];
}
