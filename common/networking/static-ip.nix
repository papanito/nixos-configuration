# Static IP wiring. Reads targetIP/interface/gateway from the hosts map passed
# via specialArgs in flake.nix. Skips hosts that don't declare a targetIP (DHCP
# fallback preserved). Handles both NetworkManager and systemd-networkd stacks.
{ lib, name, hosts, type, ... }:
let
  host = hosts.${name} or null;
  ip = if host == null then null else host.targetIP;
  iface = if host == null then null else host.interface;
  gw = if host == null then "10.0.0.1" else (host.defaultGateway or "10.0.0.1");
  prefixLength = if host == null then 24 else (host.prefixLength or 24);
  isRpi = type == "rpi";
in
lib.mkIf (ip != null && iface != null) {
  assertions = [
    {
      assertion = host != null;
      message = "static-ip: host '${name}' is not registered in flake.nix hosts map";
    }
  ];

  networking = {
    useDHCP = lib.mkForce false;
    defaultGateway = gw;
  };

  # NetworkManager / generic stack: bind the static address to the interface.
  networking.interfaces.${iface}.ipv4.addresses = [{
    address = ip;
    inherit prefixLength;
  }];

  # RPi stack: systemd-networkd. The 99-prefixed static unit loads after the
  # 99-ethernet-default-dhcp unit from profiles/rpi/networking.nix so its
  # DHCP=no override wins, while Address/Gateway are merged in.
  systemd.network.networks."99-static-${iface}" = lib.mkIf isRpi {
    matchConfig.Name = iface;
    networkConfig = {
      DHCP = "no";
      Address = "${ip}/${toString prefixLength}";
      Gateway = gw;
      MulticastDNS = "yes";
    };
  };
}
