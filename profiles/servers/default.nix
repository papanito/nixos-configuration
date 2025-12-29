{ lib, config, pkgs, ... }:
{
  imports = [
    ./restic.nix
    ./notifications.nix
  ];
}
