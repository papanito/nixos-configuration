{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports =
    [
      ./gui
      ./container.nix
      ./cloud.nix
      ./generic.nix
      ./development.nix
      ./pentesting.nix
      ./multimedia.nix
      ./shell.nix
      ./system.nix
      ./virt.nix
    ];
}