{ lib, config, pkgs, isRpi, ... }:
{
  services.resolved = {
    enable = true;
    fallbackDns = [ "10.0.0.10" ];
    domains = [ "~." ];
  };

  networking = {
    # Set nameservers here; resolved will pick them up
    nameservers = [ "10.0.0.10" ];

    # Disable the conflict-prone options
    resolvconf.enable = false;

    networkmanager = {
      enable = lib.mkDefault (!isRpi);
      dns = "systemd-resolved";
    };

    dhcpcd.extraConfig = "nohook resolv.conf";
  };
}
