{lib, config, pkgs, isArm, ... }:

let
  # Define the shared settings in a variable to avoid repetition
  dnscryptSettings = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:53" "[::1]:53" ];
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
in
{
  config = lib.mkMerge [
    {
      # Enable networking
      networking = {
        extraHosts =
          ''
          '';

        # If using dhcpcd:
        dhcpcd.extraConfig = "nohook resolv.conf";
        networkmanager = {
          enable = true;
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
    }
    # --- NON-ARM: Uses 'dnscrypt-proxy' ---
    (lib.mkIf (!isArm) {
      services.dnscrypt-proxy = dnscryptSettings;
      systemd.services.dnscrypt-proxy.serviceConfig.StateDirectory = "dnscrypt-proxy";
    })

    # --- ARM: Uses 'dnscrypt2-proxy' ---
    # We use optionalAttrs so the key 'dnscrypt2-proxy' literally doesn't 
    # exist in the set when isArm is false.
    (lib.mkIf isArm (lib.optionalAttrs isArm {
      services.dnscrypt-proxy2 = dnscryptSettings;
      systemd.services.dnscrypt-proxy2.serviceConfig.StateDirectory = "dnscrypt-proxy";
    }))
  ];
}
