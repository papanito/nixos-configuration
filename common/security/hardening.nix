{ config, lib, pkgs, ... }:

let
  # Common hardening profile
  hardenedConfig = {
    # Sandboxing
    ProtectSystem = "strict";
    ProtectHome = "tmpfs";
    PrivateTmp = true;
    PrivateDevices = true;
    ProtectControlGroups = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];

    # Privilege Escalation
    NoNewPrivileges = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;

    # User/Group namespaces
    RestrictNamespaces = true;
    LockPersonality = true;
  };
in
{
  # Apply to specific services found in your 'UNSAFE' list
  systemd.services.geoclue.serviceConfig = hardenedConfig;
  systemd.services.colord.serviceConfig = hardenedConfig;

  # For services with specific needs, override only parts
  systemd.services.cups.serviceConfig = lib.mkMerge [
    hardenedConfig
    {
      # CUPS might need raw socket access or specific device nodes
      PrivateDevices = lib.mkForce false;
    }
  ];
}
