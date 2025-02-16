{ config, pkgs, ... }:
{
  imports = [
    #./cloudflare.nix
    ./firejail.nix
    ./tor.nix
    ./vpn.nix
  ];
  networking = {
    hostName = "clawfinger"; # Define your hostname
  };
}
