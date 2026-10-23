{ config, pkgs, ... }:
{
  # boot.extraModulePackages = [
  #   (config.boot.kernelPackages.tuxedo-drivers.overrideAttrs (oldAttrs: {
  #     src = pkgs.fetchFromGitHub {
  #       owner = "tuxedocomputers";
  #       repo = "tuxedo-drivers";
  #       rev = "v4.21.0";
  #       hash = pkgs.lib.fakeHash; # Replace with SRI hash after first evaluation
  #     };
  #   }))
  # ];
  hardware.tuxedo-drivers.enable = true;
  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };
}
