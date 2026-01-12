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
}
