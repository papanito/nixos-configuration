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

  services.logind.settings.Login = {
    RuntimeDirectorySize ="32G";
    HandleLidSwitchDocked = "ignore";
  };

  # Create a library path that only applies to unpackaged programs by using nix-ld. Add this to your configuration.nix:
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
    ];
  };

  # modules
  gnome.enable = true;
  kde.enable = false;
  solokey.enable = true;
  container.enable = true;
  cloud.enable = true;
  development.enable = true;
  multimedia.enable = true;
  office.enable = true;
  security.enable = true;

  ## printing module
  printing.enable = true;
  printing.drivers = [ pkgs.hplipWithPlugin ];

  ## virtualisation module
  virtualisation.enable = true;
  windows-support.enable = true;
}
