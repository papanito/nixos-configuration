{ config, pkgs, ... }:

let
  # CONFIRMED IP from docker network inspect <KIND_NETWORK_NAME>
  kindControlPlaneDockerIP = "10.89.0.2";
  # CONFIRMED Service CIDR (where kube-dns ClusterIP is)
  kindServiceCIDR = "10.96.0.0/16";
  dockerBridgeInterface = "podman0";
  isArm = pkgs.stdenv.hostPlatform.isAarch64;
in
{
  # Enable networking
  networking = {
    extraHosts =
      ''
      '';

    # If using dhcpcd:
    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager = {
      enable = if isArm then false else true;
      dns = "none";
    };
    # extraHostConfig = ''
    #   # Route for Kind Kubernetes cluster services
    #   # Syntax: ip route add <destination_cidr> via <gateway_ip>
    #   ip route add ${kindServiceCIDR} via ${kindControlPlaneDockerIP}
    # '';
    nameservers = [
      "127.0.0.1"
      "::1"
      "2a06:98c1:54::3cfe"
    ];
  };

  services.resolved.enable = false;
  networking.resolvconf.enable = false;

  # # This creates a .network file in /etc/systemd/network/
  # systemd.network.networks = {
  #   # You can name this file anything descriptive
  #   "10-kind-route.network" = {
  #     matchConfig = {
  #       # Match the specific Docker bridge interface name on your host
  #       Name = dockerBridgeInterface;
  #     };
  #     networkConfig = {
  #       # You generally don't configure IP/DHCP here if Docker manages it
  #       # However, you could if this interface isn't otherwise configured.
  #     };
  #     # Define the static route
  #     routes = [
  #       {
  #         # Destination network for Kubernetes services
  #         Network = kindServiceCIDR;
  #         # Gateway to reach that network (the Kind control-plane's Docker IP)
  #         Gateway = kindControlPlaneDockerIP;
  #       }
  #     ];
  #   };
  # };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = [
        "127.0.0.1:53"
        "[::1]:53"
      ];
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3"; #gitleaks:allow
      };

      forwarding_rules = "/etc/forwarding-rules.txt";
      cloaking_rules = "/etc/cloaking-rules.txt";
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };

  environment.etc = {
    # Creates /etc/forwarding-rules.txt
    "forwarding-rules.txt" = {
      text = ''
        ##################################
        #        Forwarding rules        #
        ##################################

        ## This is used to route specific domain names to specific servers.
        ## The general format is:
        ## <domain> <server address>[:port] [, <server address>[:port]...]
        ## IPv6 addresses can be specified by enclosing the address in square brackets.

        ## In order to enable this feature, the "forwarding_rules" property needs to
        ## be set to this file name inside the main configuration file.

        ## Blocking IPv6 may prevent local devices from being discovered.
        ## If this happens, set `block_ipv6` to `false` in the main config file.

        ## Forward *.lan, *.local, *.home, *.home.arpa, *.internal and *.localdomain to 10.0.0.10
        lan              10.0.0.10
        home             10.0.0.10
        home.arpa        10.0.0.10
        localdomain      10.0.0.10
        192.in-addr.arpa 10.0.0.10
        
        # Forward queries for .local domains to your Kind cluster's CoreDNS IP
        # Replace 10.96.0.10 with your actual Kind cluster's CoreDNS Cluster IP
        #cluster 10.89.0.11 # Or the actual ingress IP of your Kind cluster
        cluster 10.88.0.1 # Or the actual ingress IP of your Kind cluster

        ## Forward queries to a resolver using IPv6
        # ipv6.example.com [2001:DB8::42]:53

        ## Forward queries for .onion names to a local Tor client
        ## Tor must be configured with the following in the torrc file:
        ## DNSPort 9053
        ## AutomapHostsOnResolve 1

        onion            127.0.0.1:9053
      '';
      mode = "0444";
    };
      # Creates /etc/cloaking-rules.txt
    "cloaking-rules.txt" = {
      text = ''
      '';
      mode = "0444";
    };
  };
}
