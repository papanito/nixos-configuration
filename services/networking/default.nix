{ config, pkgs, ... }:
{
  imports = [
    ./cloudflare.nix
    ./dns.nix
    ./firewall.nix
    ./firejail.nix
    ./tor.nix
    ./sshd.nix
    ./vpn.nix
  ];
}
