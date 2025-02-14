{ config, pkgs, ... }:

{
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # To add the zsh package to /etc/shells you must update environment.shells.
  environment.shells = with pkgs; [ zsh ];

  services.journald.extraConfig = ''
    SystemMaxUse=2G
  '';

  ## Essential system tools
  environment.systemPackages = with pkgs; [
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
    helix # Post-modern modal text editor
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
  ];
}
