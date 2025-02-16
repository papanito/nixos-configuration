{ config, pkgs, ... }:
{
  imports = [
    ./dns.nix
    ./firewall.nix
    ./sshd.nix
  ];
}
