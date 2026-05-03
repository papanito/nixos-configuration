{ config, lib, pkgs, ... }:

let
  cfg = config.modules.security.pam;
  inherit (lib) mkOption types mkIf mkForce mkDefault;
in
{
  options.modules.security.pam = {
    useRun0Alias = mkOption {
      type = types.bool;
      default = true;
      description = "Alias sudo to systemd-run0.";
    };

    disableSudo = mkOption {
      type = types.bool;
      default = true;
      description = "Disable the standard sudo module and its setuid wrappers.";
    };

    disabledWrappers = mkOption {
      type = types.listOf types.str;
      default = [
        "su"
        "sudoedit"
        "sg"
        "fusermount"
        "fusermount3"
        "pkexec"
        "newgrp"
        "newgidmap"
        "newuidmap"
      ];
      description = "List of security wrappers to forcefully disable.";
    };
  };

  config = {
    security = {
      # systemd-run0
      run0.enableSudoAlias = cfg.useRun0Alias;

      # Polkit is the backend for run0
      polkit.enable = mkDefault true;

      # Toggle the standard sudo module
      sudo.enable = !cfg.disableSudo;

      # Map the list of disabled wrappers into the security.wrappers attribute set
      wrappers = builtins.listToAttrs (map (name: {
        name = name;
        value = {
          enable = mkForce false;
          setuid = mkForce false;
        };
      }) cfg.disabledWrappers);
    };
  };
}
