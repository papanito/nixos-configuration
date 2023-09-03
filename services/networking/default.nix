{ config, pkgs, ... }:
{
  imports = [
    ./cloudflare.nix
    ./dns.nix
    ./firejail.nix
    ./tor.nix
    ./sshd.nix
  ];
}
