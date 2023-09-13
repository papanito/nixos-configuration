{ config, pkgs, ... }:
{
  imports = [
    ./gui
    ./networking
    ./services

    ./cloud.nix
    ./container.nix
    ./development.nix
    ./fonts.nix
    ./generic.nix
    ./journald.nix
    ./multimedia.nix
    ./pam.nix
    ./pentesting.nix
    ./printing.nix
    ./shell.nix
    ./system.nix
    ./virt.nix
  ];
}
