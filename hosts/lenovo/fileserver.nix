{ config, pkgs, ... }:
let
  printer_ip = "10.0.0.100";
  target_dir = "/var/lib/paperless/consume";
in
{
  environment.systemPackages = with pkgs; [
    nodejs
  ];

  # Allow the specific port HP uses for the "Scan to Computer" handshake
  networking.firewall.allowedTCPPorts = [ 8080 3389 445 ]; # 8080 is often used by the listener
  networking.firewall.allowedUDPPorts = [ 137 138 5353 ]; # mDNS/Avahi for discovery

  # 2. Create a background service to listen for the printer
  systemd.services.hp-push-scan = {
    description = "HP Scan-to-Computer Push Listener";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    # Ensure the service has the necessary binaries in its environment
    path = with pkgs; [ 
      bash 
      coreutils 
      nodejs 
    ];

    serviceConfig = {
      # We use npx to run the tool without 'installing' it globally
      ExecStart = "${pkgs.nodejs}/bin/npx node-hp-scan-to adf-autoscan -n'HP ENVY Inspire 7900e' -a ${printer_ip} -d ${target_dir} -r 300 --pdf -p yyyymmdd_hhMMdss";
      User = "paperless";
      Group = "paperless";
      # Hardening: prevent the service from gaining new privileges
      NoNewPrivileges = true;
      ProtectSystem = "strict";

      # This creates a virtual /tmp just for this service
      PrivateTmp = true;

      StateDirectory = "paperless"; # Creates /var/lib/paperless with correct perms
      Restart = "always";

      # This environment variable helps npm/npx know where to store its cache:with ; ;
      Environment = "HOME=/var/lib/paperless";
    };
  };
}
