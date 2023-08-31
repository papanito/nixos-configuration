{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports =
    [
      ./gui
      ./cloud.nix
      ./generic.nix
      ./development.nix
      ./pentesting.nix
      ./multimedia.nix
      ./system.nix
      ./tuxedo.nix
      ./virt.nix
    ];
}