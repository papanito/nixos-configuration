#
# Contains modules for configuring systems.
#
{ pkgs, ... }: {
  imports = [
    ./adguard.nix
    ./hardware.nix
    ./jellyfin.nix
    ./users.nix
    ./networking.nix
  ];

  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
  };

  ## pam stuff
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # modules
  gnome.enable = false;
  solokey.enable = false;
  container.enable = false;
  cloud.enable = false;
  multimedia.enable = false;
  office.enable = false;

  ## printing module
  printing.enable = false;

  ## virtualisation module
  virtualisation.enable = false;
  windows-support.enable = false;
}
