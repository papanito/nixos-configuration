{ lib, config, pkgs, ...}:
{
  imports = [
    ./trusted-nix-caches.nix
    ./cloud.nix
    ./container.nix
    ./solokey.nix
    ./printing.nix
    ./virt.nix
  ];
}
