{ config, pkgs, ... }:

{
  services.tor = {
    enable = true;
    openFirewall = true;
    settings = {
      TransPort = [ 9040 ];
      DNSPort = 5353;
      VirtualAddrNetworkIPv4 = "172.30.0.0/16";
    };
  };

  networking = {
    # useNetworkd = true;
    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        # KDE Connect
        { from = 1714; to = 1764; }
      ];
      allowedUDPPortRanges = [
        # KDE Connect
        { from = 1714; to = 1764; }
      ];

      # interfaces.tornet = {
      #   allowedTCPPorts = [ 9040 ];
      #   allowedUDPPorts = [ 5353 ];
      # };
    };

    # bridges."tornet".interfaces = [];
    # nftables = {
    #   enable = true;
    #   ruleset = ''
    #     table ip nat {
    #       chain PREROUTING {
    #         type nat hook prerouting priority dstnat; policy accept;
    #         iifname "tornet" meta l4proto tcp dnat to 127.0.0.1:9040
    #         iifname "tornet" udp dport 53 dnat to 127.0.0.1:5353
    #       }
    #     }
    #   '';
    # };
    # nat = {
    #   internalInterfaces = [ "tornet " ];
    #   forwardPorts = [
    #     {
    #       destination = "127.0.0.1:5353";
    #       proto = "udp";
    #       sourcePort = 53;
    #     }
    #   ];
    # };
  };

  # systemd.network = {
  #   enable = false;
  #   networks.tornet = {
  #     matchConfig.Name = "tornet";
  #     DHCP = "no";
  #     networkConfig = {
  #       ConfigureWithoutCarrier = true;
  #       Address = "10.100.100.1/24";
  #     };
  #     linkConfig.ActivationPolicy = "always-up";
  #   };
  # };

  # boot.kernel.sysctl = {
  #   "net.ipv4.conf.tornet.route_localnet" = 1;
  # };

}
