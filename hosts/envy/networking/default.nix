{ config, pkgs, ... }:
{
  imports = [
    ./dns.nix
    ./firejail.nix
  ];
}
