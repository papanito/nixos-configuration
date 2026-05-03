{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.security;
in {
  options.modules.security = {
    enable = mkEnableOption "Enable opinionated system hardening";

    allowBluetooth = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow Bluetooth despite hardening.";
    };

    allowGeoclue = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow geoclue2 (location servvice).";
    };

    allowAvahi = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow avahi (mDNS/DNS-SD).";
    };

    allowModemManager = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow modemmanager (WWAN/3G/4G)";
    };

    allowAccountsDaemon = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow accounts-daemon.";
    };

    allowUdisks = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow udisks2 (automounting).";
    };
  };

  config = mkMerge [
  {
    services = {
      avahi.enable = mkDefault cfg.allowAvahi;
      geoclue2.enable = mkDefault cfg.allowGeoclue;
      accounts-daemon.enable = mkDefault cfg.allowAccountsDaemon;
      udisks2.enable = mkDefault cfg.allowUdisks;
    };

    # Only needed for WWAN/3G/4G modems, otherwise it runs `mmcli` unnecessarily
    networking.modemmanager.enable = mkDefault cfg.allowModemManager;

    hardware.bluetooth.enable = mkDefault cfg.allowBluetooth;

    # Hardening often implies disabling setuid wrappers for unused tools
    security.polkit.enable = mkDefault cfg.allowUdisks;
  }
  # Conditional Systemd Hardening for Bluetooth
  (mkIf cfg.allowBluetooth {
    systemd.services = {
      bluetooth.serviceConfig = {
        ProtectKernelTunables = lib.mkDefault true;
        ProtectKernelModules = lib.mkDefault true;
        ProtectKernelLogs = lib.mkDefault true;
        ProtectHostname = true;
        ProtectControlGroups = true;
        ProtectProc = "invisible";
        SystemCallFilter = [
          "~@obsolete"
          "~@cpu-emulation"
          "~@swap"
          "~@reboot"
          "~@mount"
        ];
        SystemCallArchitectures = "native";
      };
    };
    })
  ];
}
