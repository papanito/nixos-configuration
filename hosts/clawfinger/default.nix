#
# Contains modules for configuring systems.
#
{ pkgs, ... }: {
  imports = [
    ./hardware.nix
  ];
  environment.systemPackages = [
    pkgs.linuxKernel.packages.linux_latest_libre.tuxedo-keyboard
  ];
}
