{lib, config, pkgs,  ... }:
{
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
