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
    pdftk # Command-line tool for working with PDFs
    solo2-cli
    speechd # Common interface to speech synthesis
    wl-clipboard
    vim
    libreoffice-fresh # Comprehensive, professional-quality productivity suite, a variant of openoffice.o
    slides # Terminal based presentation tool
    ssh-tools # Collection of various tools using ssh
    topgrade # Upgrade all the things
    wiki-tui # A simple and easy to use Wikipedia Text User Inter
  ];
  programs.gpaste.enable = true;
}
