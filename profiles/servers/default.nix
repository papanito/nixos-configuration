{ lib, config, pkgs, ... }:
{
  imports = [
    ./dns.nix
    ./networking.nix
    ./restic.nix
    ./notifications.nix
    ./users.nix 
  ];
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
  };
  nix = {
    gc = {
      options = lib.mkDefault "--delete-older-than 10d";
    };
  };
  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
  };

  ## pam stuff
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

}
