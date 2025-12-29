{ config, pkgs, name, ... }:
{
  imports = [
    ./dns.nix
    ./firewall.nix
    ./sshd.nix
  ];
  networking.hostName = name;
}
