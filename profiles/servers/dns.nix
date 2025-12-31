{ lib, config, pkgs, ... }:
{
services.resolved = {
    enable = true;
    # Pass your specific nameservers here instead of networking.nameservers
    fallbackDns = [ "10.0.0.10" ]; 
    # Or use 'extraConfig' if you want them as primary
    extraConfig = ''
      DNS=10.0.0.10
      Domains=~.
    '';
  };

  networking = {
    # Disable the conflict-prone options
    resolvconf.enable = false;
    
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };

    # Remove or comment out the global nameservers list
    # nameservers = [ "10.0.0.10" ]; 

    dhcpcd.extraConfig = "nohook resolv.conf";
  };
}
