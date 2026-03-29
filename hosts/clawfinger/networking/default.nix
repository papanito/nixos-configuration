{ config, pkgs, ... }:
{
  imports = [
    #./cloudflare.nix
    ./dns.nix
    ./firejail.nix
    ./tor.nix
    ./vpn.nix
  ];
  networking = {
    hostName = "clawfinger"; # Define your hostname
    interfaces.wlo1.mtu = 1492;
  };
  services.opensnitch.enable = true;
}
