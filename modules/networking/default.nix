{ config, pkgs, ... }:
{
  imports = [
    ./firewall.nix
    ./sshd.nix
  ];
}
