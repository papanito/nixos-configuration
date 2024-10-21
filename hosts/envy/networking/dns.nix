{ config, pkgs, ... }:

{
  # Enable networking
  networking = {
    hostName = "envy"; # Define your hostname
    wireless.enable = true;  # Enables wireless support via wpa_supplicant

    proxy = {
      # Configure network proxy if necessary
      # default = "http://user:password@proxy:port/";
      # noProxy = "127.0.0.1,localhost,internal.domain";
    };

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

      forwarding_rules = "/etc/nixos/hosts/clawfinger/networking/forwarding-rules.txt";
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };

  # services.stubby = {
  #   enable = true;
  #   settings = pkgs.stubby.passthru.settingsExample // {
  #     upstream_recursive_servers = [{
  #       address_data = "2a06:98c1:54::3cfe";
  #       tls_auth_name = "cloudflare-dns.com";
  #       tls_pubkey_pinset = [{
  #         digest = "sha256";
  #         value = "GP8Knf7qBae+aIfythytMbYnL+yowaWVeD6MoLHkVRg=";
  #       }];
  #     }];
  #   };
  # };
}
