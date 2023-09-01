{ config, pkgs, ... }:

{
  #linuxKernel.packages.linux_latest_libre.tuxedo-keyboard;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    exa
    fzf
    fd # A simple, fast and user-friendly alternative to find
    fq # jq for binary formats
    gnupg
    gum # a tool for glamorous shell scripts
    lsix # ls for images
    melt # Backup and restore Ed25519 SSH keys with seed words
    nix-direnv
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
