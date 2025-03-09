{ lib, config, pkgs, ... }:
{
  imports = [
    ./cloud.nix
    ./container.nix
    ./development.nix
    ./fonts.nix
    ./fun.nix
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
    direnv # A shell extension that manages your environment
    nix-direnv # A fast, persistent use_nix implementation for direnv
    ghostty # Fast, native, feature-rich terminal emulator pushing modern features
    glow # Render markdown on the CLI, with pizzazz
    gum # a tool for glamorous shell scripts
    hishtory # Your shell history: synced, queryable, and in context
    imgcat # It's like cat, but for images
    melt # Backup and restore Ed25519 SSH keys with seed words
    miller # Like awk, sed, cut, join, and sort for data formats such as CSV, TSV, JSON, JSON Lines, and positionally-indexed
    nq # Unix command line queue utility
    pueue # A daemon for managing long running shell commands
    sad # CLI tool to search and replace
    pinentry-tty # GnuPG’s interface to passphrase input
    timg # Terminal image and video viewer
    thefuck # Magnificent app which corrects your previous console command
    w3m # A text-mode web browser
    watchman # Watches files and takes action when they change
    wget # Tool for retrieving files using HTTP, HTTPS, and FTP
    xz # A general-purpose data compression software, successor of LZMA
    
    ### Shell stuff ###
    vim
    zellij # A terminal workspace with batteries included
    zsh # zsh shell
    zoxide # A fast cd command that learns your habits

    ### Encryption ###
    cryfs # Cryptographic filesystem for the cloud
    tomb # File encryption on GNU/Linux
    steghide #Open source steganography program
    sops
  ];
}
