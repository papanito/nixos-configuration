#
# Contains modules for configuring systems.
#
{ pkgs, ... }: {
  imports = [
    ./hardware.nix
  ];

  ## pam stuff
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  solokey.enable = true;

  ## printing
  printing.enable = true;
  printing.drivers = [ pkgs.hplipWithPlugin ];

  ## virtualisation
  virtualisation.enable = true;
  windows-support.enable = true;

  ## hardware specific system packages
  environment.systemPackages = [
    pkgs.linuxKernel.packages.linux_latest_libre.tuxedo-keyboard
  ];
}
