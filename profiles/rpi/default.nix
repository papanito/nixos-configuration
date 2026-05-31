{ lib, config, pkgs, inputs, ... }:
{
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
}
