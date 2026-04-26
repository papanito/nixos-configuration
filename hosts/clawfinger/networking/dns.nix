{lib, config, pkgs, isRpi, ... }:

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
      # Local resolver just for .calico — no DNSSEC involved
      services.dnsmasq = {
        enable = true;
        settings = {
          port = 5353;
          listen-address = "127.0.0.1";
          bind-interfaces = true;
          no-resolv = true;          # don't touch upstream DNS
          address = [
            "/cluster/127.0.0.2"
            "/calico/127.0.0.2"
            "/envoy/127.0.0.2"
          ];
        };
      };
      systemd.services."lo-alias" = {
        description = "Add 127.0.0.2 loopback alias for kind cluster";
        wantedBy = [ "network.target" ];
        after = [ "network-pre.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "lo-alias-up" ''
            if ! ${pkgs.iproute2}/bin/ip addr show lo | grep -q "127.0.0.2"; then
              ${pkgs.iproute2}/bin/ip addr add 127.0.0.2/8 dev lo
            fi
          '';
          ExecStop = pkgs.writeShellScript "lo-alias-down" ''
            ${pkgs.iproute2}/bin/ip addr del 127.0.0.2/8 dev lo 2>/dev/null || true
          '';
          # Ignore error if address already exists
          ExecStartPre = "${pkgs.bash}/bin/bash -c '${pkgs.iproute2}/bin/ip addr show lo | grep -q 127.0.0.2 && exit 0 || true'";
        };
      };
      environment.etc."cloaking-rules.txt".text = ''
      '';
      # Enable networking
      networking = {
        extraHosts =
          ''
          '';
        # interfaces.lo.ipv4.addresses = [
        #   { address = "127.0.0.1"; prefixLength = 8; }
        #   { address = "127.0.0.2"; prefixLength = 8; }
        # ];
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

        resolvconf.enable = false;
        firewall = {
          allowedTCPPorts = [
            80
            443
          ];
          # checkReversePath = false;
          # allowedUDPPorts = [
          #   53
          # ];
        };
      };
      services.resolved.enable = false;

      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv4.ip_unprivileged_port_start" = 0;
      };
    }
    # --- NON-ARM: Uses 'dnscrypt-proxy' ---
    (lib.mkIf (!isRpi) {
      services.dnscrypt-proxy = dnscryptSettings;
      systemd.services.dnscrypt-proxy.serviceConfig.StateDirectory = "dnscrypt-proxy";
    })

    # --- ARM: Uses 'dnscrypt2-proxy' ---
    # We use optionalAttrs so the key 'dnscrypt2-proxy' literally doesn't
    # exist in the set when isRpi is false.
    (lib.mkIf isRpi (lib.optionalAttrs isRpi {
      services.dnscrypt-proxy2 = dnscryptSettings;
      systemd.services.dnscrypt-proxy2.serviceConfig.StateDirectory = "dnscrypt-proxy";
    }))
  ];
}
