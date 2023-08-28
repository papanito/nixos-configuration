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
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  ];
  programs.gpaste.enable = true;
}
