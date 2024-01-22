#
# Contains modules for configuring systems.
#
{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./networking
  ];

  ## pam stuff
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # modules
  solokey.enable = true;
  container.enable = true;

  ## printing module
  printing.enable = true;
  printing.drivers = [ pkgs.hplipWithPlugin ];

  ## virtualisation module
  virtualisation.enable = true;
  windows-support.enable = true;

  ## hardware specific system packages
  environment.systemPackages = with pkgs; [
    linuxKernel.packages.linux_latest_libre.tuxedo-keyboard
    insync
  ];

  pentesting.enable = false;
}
