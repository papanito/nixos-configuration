{ lib, config, pkgs, inputs, ... }:
{
  boot.loader.generic-extlinux-compatible.configurationLimit = lib.mkDefault 5;
  imports = [
    ./networking.nix
    ./users.nix
  ];

  # Disable features that pull in heavy dependencies
  services.pipewire.enable = lib.mkForce false;
  fonts.fontconfig.enable = lib.mkForce false;

  # Disable the X11 library stack globally
  environment.variables.NIXOS_OZONE_WL = "0";
  documentation.nixos.enable = false;
  documentation.enable = false;
  documentation.man.enable = false;
  documentation.doc.enable = false;
  documentation.info.enable = false;
  programs.command-not-found.enable = false;
}
