{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    emacs
    helix
    irssi
    mutt
    rpi-imager
    solo2-cli
    wl-clipboard
    vim
    libreoffice-fresh # Comprehensive, professional-quality productivity suite, a variant of openoffice.o
    slides # Terminal based presentation tool
    ssh-tools # Collection of various tools using ssh
    topgrade # Upgrade all the things
    discord # All-in-one cross-platform voice and text chat for gamers
    slack # Desktop client for Slack
    #teams # Microsoft Teams
    wiki-tui # A simple and easy to use Wikipedia Text User Inter
  ];
  programs.gpaste.enable = true;
}
