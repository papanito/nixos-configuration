{ config, pkgs, ... }:

{
  networking.hostName = "clawfinger"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # List services that you want to enable:

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
