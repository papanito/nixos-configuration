{ config, pkgs, ... }:
{
  imports = [
    ./restic.nix
    ./notifications.nix
    ./mounts.nix
  ];
}
