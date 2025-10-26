
{ config, pkgs, ... }:
{
  boot.kernel.sysctl = {
    # Increase maximum receive buffer size for AdGuard Home's DNS
    "net.core.rmem_max" = 2500000;
  };
  services.adguardhome = {
    enable = true;
    settings = {
      http = {
        # You can select any ip and port, just make sure to open firewalls where needed
        address = "0.0.0.0:3003";
      };
      dns = {
        bind_hosts = [ "0.0.0.0" ]; # **Crucial: Tells AGH to listen on all interfaces**
        port = 53;                  # **Crucial: Binds to the standard DNS port**
        upstream_dns = [
          "9.9.9.9:53"
          "127.0.0.1:51"
          "[::1]:51"
        ];
        bootstrap_dns = [
          "9.9.9.9:53"
          "127.0.0.1:51"
          "[::1]:51"
        ];
        dnssec_enabled = true;
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false;  # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = true;  # Enforcing "Safe search" option for search engines, when possible.
        };
        blocked_services = {
          ids = [
            "kik"
            "betway"
            "vk"
          ];
        };
      };
      tls = {
        enabled = false;
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      filters = map(url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"  # AdGuard DNS filter
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt" # Phishing URL Blocklist (PhishTank and OpenPhish)
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_50.txt" # uBlock₀ filters – Badware risks
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_29.txt" # CHN: AdRules DNS List
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_24.txt" # 1Hosts (Lite)
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_53.txt" # AWAvenue Ads Rule
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt" # AdGuard DNS Popup Hosts filter
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_5.txt"  # OISD Blocklist Small
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt" # HaGeZi's Pro Blocklist
      ];

    };
    # Ensure the firewall is open (see next step)
    openFirewall = true;
  };
}
