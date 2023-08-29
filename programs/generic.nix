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
    gnome.geary
    mutt
    tor
    tor-browser-bundle-bin
    yubikey-touch-detector
    spotify
    irssi
    helix
    vim
  ];
  programs.gpaste.enable = true;
}
