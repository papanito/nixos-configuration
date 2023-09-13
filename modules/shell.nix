{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    age # Modern encryption tool with small explicit keys
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
    wget
    xdg-ninja
    yubikey-touch-detector
    zellij # A terminal workspace with batteries included
    zsh
    zoxide # A fast cd command that learns your habits
  ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # To add the zsh package to /etc/shells you must update environment.shells.
  environment.shells = with pkgs; [ zsh ];
}
