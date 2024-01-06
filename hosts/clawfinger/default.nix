#
# Contains modules for configuring systems.
#
{ pkgs, ... }: {
  imports = [
    ./hardware.nix
  ];

  printing.enable = true;
  printing.drivers = [ pkgs.hplipWithPlugin ];

  environment.systemPackages = [
    pkgs.linuxKernel.packages.linux_latest_libre.tuxedo-keyboard
  ];
}
