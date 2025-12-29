#
# Contains modules for configuring systems.
#
{ config, pkgs, lib, name, ... }: {
  imports = [
  ];

    system.nixos.tags = let
      cfg = config.boot.loader.raspberryPi;
    in [
      "raspberry-pi-${cfg.variant}"
      cfg.bootloader
      config.boot.kernelPackages.kernel.version
    ];
}
