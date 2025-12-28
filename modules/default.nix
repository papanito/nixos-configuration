{ lib, config, pkgs, ... }:
{
  imports = [
    ./rpi # raspberry pi specific stuff
    ./cloud.nix
    ./container.nix
    ./development.nix
    ./fonts.nix
    ./kde.nix
    ./gnome.nix
    ./multimedia.nix
    ./office.nix
    ./solokey.nix
    ./printing.nix
    ./security.nix
    ./virt.nix
    ./wine.nix
  ];
  
  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  security.wrappers = {
    fusermount.source  = "${pkgs.fuse}/bin/fusermount";
  };

  environment.systemPackages = with pkgs; [
    ## Essential system tools
    age # Modern encryption tool with small explicit keys
    bat # A cat(1) clone with syntax highlighting and Git integration
    btop # A monitor of resources
    btrfs-progs
    coreutils # The GNU Core Utilities
    cifs-utils # Tools for managing Linux CIFS client filesystems
    curl # A command line tool for transferring files with URL syntax
    dnsutils # Domain name server
    eza # replacement for exa which is unmaintained
    file # A program that shows the type of files
    fzf # A command-line fuzzy finder written in Go
    fd # A simple, fast and user-friendly alternative to find
    fq # jq for binary formats
    jq # A lightweight and flexible command-line JSON processor
    gnupg # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
    gtop # graphic top
    lsix # ls for images
    lsof # Tool to list open files
    ncdu # Disk usage analyzer with an ncurses interface
    parted
    psmisc # A set of small useful utilities that use the proc filesystem (such as fuser, killall and pstree)
    polkit # A toolkit for defining and handling the policy that allows unprivileged processes to speak to privileged processes
    openssl
    unzip
    yq # Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML documents

    ### Shell and Terminal tools and apps ###
    bats # Bash Automated Testing System
    duf # better df lternative
    direnv # A shell extension that manages your environment
    findutils # GNU Find Utilities, the basic directory searching utilities of the GNU operating system
    nix-direnv # A fast, persistent use_nix implementation for direnv
    ptyxis # Terminal
    glow # Render markdown on the CLI, with pizzazz
    gum # a tool for glamorous shell scripts
    atuin # Your shell history: synced, queryable, and in context
    imgcat # It's like cat, but for images
    melt # Backup and restore Ed25519 SSH keys with seed words
    miller # Like awk, sed, cut, join, and sort for data formats such as CSV, TSV, JSON, JSON Lines, and positionally-indexed
    nq # Unix command line queue utility
    pueue # A daemon for managing long running shell commands
    ripgrep
    sad # CLI tool to search and replace
    pinentry-tty # GnuPG’s interface to passphrase input
    watchman # Watches files and takes action when they change
    xz # A general-purpose data compression software, successor of LZMA
    sshfs
    
    ### Shell stuff ###
    vim
    zellij # A terminal workspace with batteries included
    zsh # zsh shell
    zoxide # A fast cd command that learns your habits
    nushell # terminal
    carapace # Multi-shell multi-command argument completer
  ];
}
