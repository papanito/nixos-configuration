{ config, pkgs, ... }:
{
  hardware.tuxedo-keyboard.enable = true;
  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };
}