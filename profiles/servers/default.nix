{ lib, config, pkgs, ... }:
{
  imports = [
    ./restic.nix
    ./notifications.nix
    ./dns.nix
    ./networking.nix
    ./users.nix 
  ];
}
