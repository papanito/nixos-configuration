{ config, pkgs, ... }:
let
   my-python-packages = ps: with ps; [
    pandas
    requests
    pip
    django
  ];
in

{
  imports = [
    ./networking
    ./services

    ./container.nix
    ./fonts.nix
    ./gnome.nix
    ./journald.nix
    ./pam.nix
    ./pentesting.nix
    ./printing.nix
    ./system.nix
    # ./tuxedo.nix
    ./virt.nix
  ];

  environment.systemPackages = with pkgs; [
    emacs
    helix
    irssi
    mutt
    rpi-imager
    pdftk # Command-line tool for working with PDFs
    solo2-cli
    speechd # Common interface to speech synthesis
    wl-clipboard
    vim
    libreoffice-fresh # Comprehensive, professional-quality productivity suite, a variant of openoffice.o
    slides # Terminal based presentation tool
    ssh-tools # Collection of various tools using ssh
    topgrade # Upgrade all the things
    wiki-tui # A simple and easy to use Wikipedia Text User Inter
    bitwarden
    bitwarden-cli
    chromium
    firefox
    gimp-with-plugins
    nextcloud-client
    onlyoffice-bin
    evince
    tor-browser-bundle-bin
    signal-desktop
    rpi-imager
    timeline #  Display and navigate information on a timeline

    ### cloud ###
    azure-cli
    insync
    google-cloud-sdk
    hcloud # A command-line interface for Hetzner Cloud, a provider for cloud virtual private servers1
    python311Packages.hcloud # Library for the Hetzner Cloud API

    ### Development ###
    ansible
    ansible-lint
    anytype # P2P note-taking tool
    obsidian # A powerful knowledge base that works on top of a local folder of plain text Markdown files
    gh # github cli
    act # Run your GitHub Actions locally
    actionlint # Static checker for GitHub Actions workflow files
    bump # CLI tool to draft a GitHub Release for the next semantic version
    doppler # The official CLI for interacting with your Doppler Enclave secrets and configuration
    glab # gitlab cli
    git
    git-crypt
    go
    openjdk19
    maven
    buildkit # Concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit
    buildkit-nix #Nix frontend for BuildKit
    buildkite-cli # A command line interface for Buildkite
    buildah # A tool which facilitates building OCI images
    wrangler_1 # A CLI tool designed for folks who are interested in using Cloudflare Workers
    cargo # Downloads your Rust project's dependencies and builds your project
    nodejs
    jq 
    yq # Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML documents
    hurl #Command line tool that performs HTTP requests defined in a simple plain text format.
    python3
    (pkgs.python3.withPackages my-python-packages)
    navi # An interactive cheatsheet tool for the command-line and application launchers
    terraform
    terragrunt # A thin wrapper for Terraform that supports locking for Terraform state and enforces best practices
    terraform-docs # A utility to generate documentation from Terraform modules in various output formats
    vscode # Open source source code editor developed by Microsoft for Windows, Linux and macOS 
    vscodium # Open source source code editor developed by Microsoft for Windows, Linux and macOS (VS Code without MS branding/telemetry/licensing) 
    lazygit # Simple terminal UI for git commands
    shellcheck # Shell script analysis tool
    nodePackages.zx # A tool for writing better scripts.
    nodePackages.snyk # snyk library and cli utility
    insomnia # The most intuitive cross-platform REST API Client
    just # A handy way to save and run project-specific commands

    ### Multimedia ###
    ghostscript
    mpv # General-purpose media player, fork of MPlayer and mplayer2
    ncspot # Cross-platform ncurses Spotify client written in Rust, inspired by ncmpc and the likes
    spotify
    spotify-tui # Spotify for the terminal written in Rust
    spotify-tray # Adds a tray icon to the Spotify Linux client application.
    yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    ytmdl # YouTube Music Downloader
    youtube-dl # Command-line tool to download videos from YouTube.com and other sites
    youtube-tui # An aesthetically pleasing YouTube TUI written in Rust
    ffmpeg-full
    gst_all_1.gstreamer # Open source multimedia framework
    peertube # A free software to take back control of your videos
    streamlink # CLI for extracting streams from various websites to video player of your choosing
    vlc # Cross-platform media player and streaming server
    rhythmbox # A music playing application for GNOME
    tesseract # OCR engine
    gnome-frog # Intuitive text extraction tool (OCR) for GNOME desktop

    ### Shell ###
    age # Modern encryption tool with small explicit keys
    alacritty #A cross-platform, GPU-accelerated terminal emulator
    agebox # Age based repository file encryption gitops tool
    bat # A cat(1) clone with syntax highlighting and Git integration
    btop # A monitor of resources
    bats # Bash Automated Testing System
    curl # A command line tool for transferring files with URL syntax
    exa # Replacement for 'ls' written in Rust
    # eza # replacement for exa which is unmaintained
    fzf # A command-line fuzzy finder written in Go
    fd # A simple, fast and user-friendly alternative to find
    feh # A light-weight image viewer
    fq # jq for binary formats
    gnupg # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
    gtop # graphic top
    gum # a tool for glamorous shell scripts
    guake # Drop-down terminal for GNOME
    # tilix # Tiling terminal emulator following the Gnome Human Interface Guidelines
    python311Packages.pillow # The friendly PIL fork (Python Imaging Library)
    w3m # A text-mode web browser
    lsix # ls for images
    melt # Backup and restore Ed25519 SSH keys with seed words
    mods # AI on the command line
    neofetch # A fast, highly customizable system info script
    glow # Render markdown on the CLI, with pizzazz
    miller # Like awk, sed, cut, join, and sort for data formats such as CSV, TSV, JSON, JSON Lines, and positionally-indexed
    direnv # A shell extension that manages your environment
    nix-direnv # A fast, persistent use_nix implementation for direnv
    nq # Unix command line queue utility
    pueue # A daemon for managing long running shell commands
    ranger # File manager with minimalistic curses interface
    thefuck # Magnificent app which corrects your previous console command
    contour # Modern C++ Terminal Emulator
    wezterm # GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust
    wget
    xdg-ninja
    yubikey-touch-detector
    zellij # A terminal workspace with batteries included
    zsh
    zoxide # A fast cd command that learns your habits

    ### System ###
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
}
