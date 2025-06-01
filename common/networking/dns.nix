{ config, pkgs, ... }:

{
  # Enable networking
  networking = {
    extraHosts =
      ''
        10.0.0.10 yuno.home
        10.0.0.10 jf.home
      '';

    # If using dhcpcd:
    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager = {
      enable = true;
      dns = "none";
    };

    nameservers = [
      "127.0.0.1"
      "::1"
      "2a06:98c1:54::3cfe"
    ];
  };

  services.resolved.enable = false;

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
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
        
        ## Local resolve
        local            127.0.0.1
        internal         127.0.0.1

        ## Forward queries for example.com and *.example.com to 9.9.9.9 and 8.8.8.8
        # example.com      9.9.9.9,8.8.8.8

        ## Forward queries to a resolver using IPv6
        # ipv6.example.com [2001:DB8::42]:53

        ## Forward queries for .onion names to a local Tor client
        ## Tor must be configured with the following in the torrc file:
        ## DNSPort 9053
        ## AutomapHostsOnResolve 1

        onion            127.0.0.1:9053
      '';

      # The UNIX file mode bits
      mode = "0444";
    };
  };
}
