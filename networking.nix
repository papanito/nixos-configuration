{ config, pkgs, ... }:

{
  networking.hostName = "clawfinger"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    # If using dhcpcd:
    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager = {
      enable = true;
      #dns = "none";
    };
    nameservers = [
      # "127.0.0.1"
      # "::1"
      "10.0.0.1"
      "10.0.0.10"
      "2a06:98c1:54::3cfe"
    ];
  };

  services.resolved.enable = false;
  

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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  networking.extraHosts =
    ''
      10.0.0.10 yuno.home
    '';

  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      signal-desktop = {
        executable = "${pkgs.signal-desktop}/bin/signal-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland";
        profile = "${pkgs.firejail}/etc/firejail/signal-desktop.profile";
        extraArgs = [ "--env=LC_ALL=C" "--env=GTK_THEME=Adwaita:dark" ];
      };
    };
  };

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
