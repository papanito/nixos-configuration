{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bitwarden
    bitwarden-cli
    chromium
    firefox
    thefuck
    gnupg
    tmux
    zellij
    ghostscript
    nextcloud-client
    onlyoffice-bin
    solo2-cli
    evince
    mutt
    tor
    tor-browser-bundle-bin
    irssi
    signal-desktop
    helix
    vim
  ];
  programs.gpaste.enable = true;
}
