{ config, pkgs, ... }:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./cloudflare.nix
    ./dns.nix
    ./firewall.nix
    ./firejail.nix
    ./sshd.nix
    ./tor.nix
    ./vpn.nix
  ];
}
