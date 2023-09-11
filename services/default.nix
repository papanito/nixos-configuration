{ config, pkgs, ... }:
{
  imports = [
    ./networking

    ./container.nix
    ./journald.nix
    ./restic.nix
  ];
}
