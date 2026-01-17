{ lib, config, pkgs, ... }:
{
  imports = [
    ./cloud.nix
    ./container.nix
    ./solokey.nix
    ./printing.nix
    ./security.nix
    ./virt.nix
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
    glow # Render markdown on the CLI, with pizzazz
    gum # a tool for glamorous shell scripts
    atuin # Your shell history: synced, queryable, and in context
    melt # Backup and restore Ed25519 SSH keys with seed words
    miller # Like awk, sed, cut, join, and sort for data formats such as CSV, TSV, JSON, JSON Lines, and positionally-indexed
    nq # Unix command line queue utility
    ripgrep
    sad # CLI tool to search and replace
    xz # A general-purpose data compression software, successor of LZMA
    sshfs
    
    ### Shell stuff ###
    vim
    zellij # A terminal workspace with batteries included
    zsh # zsh shell
    zoxide # A fast cd command that learns your habits
  ];
}
