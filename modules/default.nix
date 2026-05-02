{ lib, config, pkgs, ...}:
{
  imports = [
    ./cloud.nix
    ./container.nix
    ./solokey.nix
    ./printing.nix
    ./security
    ./virt.nix
  ];
}
