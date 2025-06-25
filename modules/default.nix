{ lib, config, pkgs, ... }:
{
  imports = [
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

  environment.systemPackages = with pkgs; [
    ### Shell and Terminal tools and apps ###
    bats # Bash Automated Testing System
    duf # better df lternative
    direnv # A shell extension that manages your environment
    findutils # GNU Find Utilities, the basic directory searching utilities of the GNU operating system
    nix-direnv # A fast, persistent use_nix implementation for direnv
    ptyxis
    glow # Render markdown on the CLI, with pizzazz
    gum # a tool for glamorous shell scripts
    atuin # Your shell history: synced, queryable, and in context
    imgcat # It's like cat, but for images
    melt # Backup and restore Ed25519 SSH keys with seed words
    miller # Like awk, sed, cut, join, and sort for data formats such as CSV, TSV, JSON, JSON Lines, and positionally-indexed
    nq # Unix command line queue utility
    pueue # A daemon for managing long running shell commands
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

    ### Encryption ###
    sops
  ];
}
