{ config, pkgs, ... }:
{
  imports = [
    ./journald.nix
    ./restic.nix
  ];
}
