{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bitwarden
    bitwarden-cli
    chromium
    firefox
    gimp-with-plugins
    nextcloud-client
    onlyoffice-bin
    evince
    tor-browser-bundle-bin
    signal-desktop
    rpi-imager
  ];
  programs.gpaste.enable = true;
}
