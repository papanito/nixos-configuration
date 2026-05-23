{ config, lib, pkgs, ... }:

let
  # A robust base for leaf services (e.g., geoclue, colord, tor)
  strictSandbox = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    ProtectKernelTunables = true;
    ProtectControlGroups = true;
    RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
    RestrictNamespaces = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
  };

  # Services that are safe to harden immediately
  leafServices = [
    "geoclue"
    "colord"
    "accounts-daemon"
    "cups-browsed"
    "dnscrypt-proxy"
  ];

  # Generate the set for the leaf services
  leafServicesConfig = lib.genAttrs leafServices (name: {
    serviceConfig = strictSandbox;
  });

  # Define your specific overrides in a separate set
  manualServicesConfig = {
    systemd-rfkill.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;

      # Needs access to /dev/rfkill
      DeviceAllow = [ "/dev/rfkill" ];
      PrivateDevices = false; # Must be false to use DeviceAllow

      # Privilege Escalation
      NoNewPrivileges = true;
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ]; # Required for RFKILL operations
      AmbientCapabilities = [ "CAP_NET_ADMIN" ];

      # Kernel & Hardware
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      RestrictAddressFamilies = [ "AF_UNIX" ];
    };
  };
in
{
  systemd.services = leafServicesConfig // manualServicesConfig;
}
