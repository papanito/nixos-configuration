{ lib, config, pkgs, isRpi, ... }:
{
  services.resolved = {
    enable = true;
    # Or use 'extraConfig' if you want them as primary
    settings = {
      Resolve = {
        # Pass your specific nameservers here instead of networking.nameservers
        FallbackDns = [ "10.0.0.10" ];
        DNS = ["10.0.0.10"];
        Domains = ["~."];
      };
    };
  };

  networking = {
    # Disable the conflict-prone options
    resolvconf.enable = false;

    networkmanager = {
      enable = lib.mkDefault (!isRpi);
      dns = "systemd-resolved";
    };

    # Remove or comment out the global nameservers list
    # nameservers = [ "10.0.0.10" ];

    dhcpcd.extraConfig = "nohook resolv.conf";
  };
}
