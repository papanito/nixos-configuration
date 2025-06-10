{ config, pkgs, ... }:

{
  networking.firewall = {
    # allowedTCPPorts = [
    #   443
    # ];
    checkReversePath = false;
    allowedUDPPorts = [
      53
    ];
  };


  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.ip_unprivileged_port_start" = 0;
  };
}
