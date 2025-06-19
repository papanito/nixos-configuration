#
# Contains modules for configuring systems.
#
{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./networking
    ./packages.nix
    ./services
    ./pam.nix
    ./tuxedo.nix
    ./sops.nix
    ./sound.nix
    ./security.nix
    ./users.nix
  ];

  services.logind.extraConfig = ''
    RuntimeDirectorySize=32G
    HandleLidSwitchDocked=ignore
  '';

  # modules
  gnome.enable = false;
  kde.enable = true;
  solokey.enable = true;
  container.enable = true;
  cloud.enable = true;
  development.enable = true;
  multimedia.enable = true;
  office.enable = true;
  fun.enable = true;
  security.enable = true;

  ## printing module
  printing.enable = true;
  printing.drivers = [ pkgs.hplipWithPlugin ];

  ## virtualisation module
  virtualisation.enable = true;
  windows-support.enable = true;
}
