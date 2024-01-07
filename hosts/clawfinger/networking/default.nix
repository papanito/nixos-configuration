{ config, pkgs, ... }:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./cloudflare.nix
    ./dns.nix
    ./firejail.nix
    ./tor.nix
    ./vpn.nix
  ];
}
