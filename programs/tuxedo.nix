{ config, pkgs, ... }:

let
  tuxedo = import (builtins.fetchTarball "https://github.com/blitz/tuxedo-nixos/archive/master.tar.gz");
in {
  imports = [
    tuxedo.module
  ];
  hardware.tuxedo-control-center.enable = true;
  hardware.tuxedo-keyboard.enable = true;

  boot.kernelParams = [
    "tuxedo_keyboard.mode=0"
    "tuxedo_keyboard.brightness=25"
    "tuxedo_keyboard.color_left=0x0000ff"
  ];
}
