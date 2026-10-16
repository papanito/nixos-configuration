{ config, pkgs, ... }:
{
  imports = [
    ./restic.nix
    ./notifications.nix
    ./automation.nix
    ./tuios.nix
  ];
}
