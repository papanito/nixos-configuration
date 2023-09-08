{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    curl
    exa
    fzf
    fd # A simple, fast and user-friendly alternative to find
    fq # jq for binary formats
    gnupg
    gtop # graphic top
    gum # a tool for glamorous shell scripts
    guake
    tilix
    lsix # ls for images
    melt # Backup and restore Ed25519 SSH keys with seed words
    mods # AI on the command line
    glow # Render markdown on the CLI, with pizzazz
    miller # Like awk, sed, cut, join, and sort for data formats such as CSV, TSV, JSON, JSON Lines, and positionally-indexed
    direnv # A shell extension that manages your environment
    nix-direnv # A fast, persistent use_nix implementation for direnv
    nq # Unix command line queue utility
    pueue # A daemon for managing long running shell commands
    tmux
    thefuck # Magnificent app which corrects your previous console command
    vte # a library implementing a terminal emulator widget for GTK
    wget
    yubikey-touch-detector
    zellij
    zsh
    zoxide
  ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # To add the zsh package to /etc/shells you must update environment.shells.
  environment.shells = with pkgs; [ zsh ];
}
