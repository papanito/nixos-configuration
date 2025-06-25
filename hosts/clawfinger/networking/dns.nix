{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    # checkReversePath = false;
    # allowedUDPPorts = [
    #   53
    # ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.ip_unprivileged_port_start" = 0;
  };

  environment.etc = {
    # Creates /etc/cloaking-rules.txt
    "cloaking-rules.txt" = {
      text = ''
        *.cluster 127.0.0.2
      '';
      mode = "0444";
    };
  };
}
