{ config, pkgs, ... }:
let
  printer_ip = "10.0.0.100";
  target_dir = "/var/tmp/scans";
  username = "admin";
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
    serviceConfig = {
      # We use npx to run the tool without 'installing' it globally
      ExecStart = "${pkgs.nodejs}/bin/npx node-hp-scan-to -a ${printer_ip} -d ${target_dir}";
      User = username;
      Restart = "always";
    };
  };
}
