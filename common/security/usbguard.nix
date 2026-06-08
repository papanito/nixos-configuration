{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.security.usbguard;
in {
  options.modules.security.usbguard = {
    enable = lib.mkEnableOption "usbguard";

    allowedUsers = mkOption {
      type = types.listOf types.str;
      default = [ "root" "nixos" ];
      description = "List of users allowed to interact with the USBGuard daemon via IPC.";
    };

    rules = mkOption {
      type = types.lines;
      default = ''
        # Slokey
        allow id 1209:beee

        # Block suspicious combinations FIRST
        reject with-interface all-of { 08:*:* 03:00:* }
        reject with-interface all-of { 08:*:* 03:01:* }
        reject with-interface all-of { 08:*:* e0:*:* }
        reject with-interface all-of { 08:*:* 02:*:* }

        # Allow legitimate single-purpose devices
        allow with-interface equals { 08:*:* }
        allow with-interface equals { 03:*:* }
      '';
      description = "The USBGuard policy rules.";
    };
  };

  config = mkIf cfg.enable {
    services.usbguard = {
      dbus.enable = true;
      enable = true;
      # Reference the list from the option
      IPCAllowedUsers = cfg.allowedUsers;

      presentDevicePolicy = "allow";
      rules = cfg.rules;
    };

    environment.systemPackages = [ pkgs.usbguard ];
  };
}
