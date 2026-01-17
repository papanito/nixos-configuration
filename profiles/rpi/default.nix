{ lib, config, pkgs, inputs, ... }:
{
  imports = [
    ./networking.nix
    ./users.nix
  ];
  # modules
  # solokey.enable = false;
  # container.enable = false;
  # cloud.enable = false;
  # printing.enable = false;
  # virtualisation.enable = false;
  
  # Disable the X11 library stack globally
  # This is the modern replacement for noXlibs
  environment.variables.NIXOS_OZONE_WL = "0"; # Optional: helps with some wayland-aware libs
  documentation.nixos.enable = false;
}
