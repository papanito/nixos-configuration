{ config, pkgs, ... }:
{
  imports = [
    ./networking

    ./journald.nix
    ./restic.nix
  ];
}
