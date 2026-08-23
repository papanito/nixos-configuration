{ lib, config, pkgs, ...}:
{
  imports = [
    ./trusted-nix-caches.nix
    ./container.nix
    ./solokey.nix
    ./printing.nix
    ./virt.nix
  ];
}
