{ lib, config, pkgs, ... }:
{
  imports = [
    ./restic.nix
    ./notifications.nix
    ./networking.nix
    ./users.nix 
  ];
}
