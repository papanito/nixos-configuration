{ lib, config, pkgs, inputs, ... }:
{
  imports = [
    ./development.nix
    ./fonts.nix
    ./kde.nix
    ./gnome.nix
    ./multimedia.nix
    ./office.nix
    ./wine.nix
  ];

  environment.systemPackages = with pkgs; [
    lsix # ls for images
    ptyxis # Terminal
    imgcat # It's like cat, but for images
    pinentry-tty # GnuPG’s interface to passphrase inputt
    gtop # graphic top
    nushell # terminal
    carapace # Multi-shell multi-command argument completer
    watchman # Watches files and takes action when they change
    pueue # A daemon for managing long running shell commands
  ];
}
