{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    thefuck
    gnupg
    tmux
    ghostscript
    solo2-cli
    mutt
    irssi
    helix
    vim
    emacs
    wl-clipboard
    zellij
    pueue
    rpi-imager
    gum # a tool for glamorous shell scripts
    lsix # ls for images
    vte # a library implementing a terminal emulator widget for GTK
    fd # A simple, fast and user-friendly alternative to find
    melt # Backup and restore Ed25519 SSH keys with seed words
  ];
  programs.gpaste.enable = true;
}
