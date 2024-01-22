{ lib, config, pkgs, ... }:
let
   my-python-packages = ps: with ps; [
    pandas
    requests
    pip # The PyPA recommended tool for installing Python packages
    django
    pillow # The friendly PIL fork (Python Imaging Library)
    jupyter # A high-level dynamically-typed programming language
    notebook # Web-based notebook environment for interactive computing
  ];
in

{
  imports = [
    ./networking
    ./services

    ./cloud.nix
    ./container.nix
    ./fonts.nix
    ./gnome.nix
    ./multimedia.nix
    ./pam.nix
    ./printing.nix
    ./system.nix
    ./tuxedo.nix
    ./virt.nix
    ./wine.nix
  ];

  environment.systemPackages = with pkgs; [
    emacs
    helix
    irssi
    mutt
    bitwarden
    bitwarden-cli
    chromium
    evince
    firefox
    google-chrome
    logseq # A local-first, non-linear, outliner notebook for organizing and sharing your personal knowledge base
    libreoffice-fresh # Comprehensive, professional-quality productivity suite, a variant of openoffice
    mkcert # A simple tool for making locally-trusted development certificates
    nextcloud-client
    onlyoffice-bin
    pdftk # Command-line tool for working with PDFs
    pdfchain # A graphical user interface for the PDF Toolkit (PDFtk)
    pdfarranger # Merge or split pdf documents and rotate, crop and rearrange their pages using an interactive and intuitive graphical interface
    rpi-imager
    signal-desktop
    slides # Terminal based presentation tool
    speechd # Common interface to speech synthesis
    tor-browser-bundle-bin
    topgrade # Upgrade all the things
    timeline #  Display and navigate information on a timeline
    thunderbird # A full-featured e-mail client
    vim
    watchman # Watches files and takes action when they change
    wl-clipboard
    wiki-tui # A simple and easy to use Wikipedia Text User Inter
    #xgixy # Nginx configuration static analyzer

    ### cloud ###
    
    ### Development ###
    act # Run your GitHub Actions locally
    actionlint # Static checker for GitHub Actions workflow files
    bump # CLI tool to draft a GitHub Release for the next semantic version
    ansible
    ansible-lint
    # anytype # P2P note-taking tool
    buildkit # Concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit
    buildkit-nix #Nix frontend for BuildKit
    buildkite-cli # A command line interface for Buildkite
    buildah # A tool which facilitates building OCI images
    cargo # Downloads your Rust project's dependencies and builds your project
    doppler # The official CLI for interacting with your Doppler Enclave secrets and configuration
    findutils # GNU Find Utilities, the basic directory searching utilities of the GNU operating system
    gh # github cli
    glab # gitlab cli
    git # git
    git-crypt
    git-filter-repo # Quickly rewrite git repository history
    gitleaks # Scan git repos (or files) for secrets
    lazygit # Simple terminal UI for git commands
    go
    hurl #Command line tool that performs HTTP requests defined in a simple plain text format.
    insomnia # The most intuitive cross-platform REST API Client
    maven
    nodejs
    nodePackages.zx # A tool for writing better scripts.
    nodePackages.snyk # snyk library and cli utility
    obsidian # A powerful knowledge base that works on top of a local folder of plain text Markdown files
    openjdk19
    poppler # A PDF rendering library
    poppler_utils # A PDF rendering library
    python3
    (pkgs.python3.withPackages my-python-packages)
    pipenv # Python Development Workflow for Humans
    shellcheck # Shell script analysis tool
    just # A handy way to save and run project-specific commands
    vscode # Open source source code editor developed by Microsoft for Windows, Linux and macOS 
    vscodium # Open source source code editor developed by Microsoft for Windows, Linux and macOS (VS Code without MS branding/telemetry/licensing) 

    ### Shell and Terminal tools and apps ###
    age # Modern encryption tool with small explicit keys
    agebox # Age based repository file encryption gitops tool
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
    jq # A lightweight and flexible command-line JSON processor
    gnupg # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
    gtop # graphic top
    gum # a tool for glamorous shell scripts
    guake # Drop-down terminal for GNOME
    lsix # ls for images
    melt # Backup and restore Ed25519 SSH keys with seed words
    mods # AI on the command line
    navi # An interactive cheatsheet tool for the command-line and application launchers
    neofetch # A fast, highly customizable system info script
    miller # Like awk, sed, cut, join, and sort for data formats such as CSV, TSV, JSON, JSON Lines, and positionally-indexed
    nq # Unix command line queue utility
    pueue # A daemon for managing long running shell commands
    ranger # File manager with minimalistic curses interface
    sad # CLI tool to search and replace
    terminator # Terminal emulator with support for tiling and tabs
    thefuck # Magnificent app which corrects your previous console command
    w3m # A text-mode web browser
    wget
    xclip # Tool to access the X clipboard from a console application
    xdg-ninja
    xz # A general-purpose data compression software, successor of LZMA
    yq # Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML documents
    zellij # A terminal workspace with batteries included
    zsh
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
    solo2-cli
    nfstrace # NFS and CIFS tracing/monitoring/capturing/analyzing tool
    s3fs # Mount an S3 bucket as filesystem through FUSE
    usbutils # Tools for working with USB devices, such as lsusb
    ventoy-full # A New Bootable USB Solution
    wireplumber # A modular session / policy manager for PipeWire
    polkit # A toolkit for defining and handling the policy that allows unprivileged processes to speak to privileged processes
    yubikey-touch-detector

    ### Security ###
    chkrootkit # Locally checks for signs of a rootkit
    clamav # Antivirus engine designed for detecting Trojans, viruses, malware and other malicious threats
    lynis # Security auditing tool for Linux, macOS, and UNIX-based systems
    vt-cli # VirusTotal Command Line Interface
  ];
}
