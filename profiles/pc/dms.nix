{ config, pkgs-unstable, lib, ... }:
let
  cfg = config.modules.dms;
  pkgs = pkgs-unstable;
in
{
  options.modules.dms = {
    enable
      = lib.mkEnableOption "enable kde and install related software";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true; # Or programs.hyprland.enable = true;
    # Overlay the specific packages expected by the upstream module
    # out of the pkgsUnstable instance we passed from flake.nix
    nixpkgs.overlays = [
      (final: prev: {
        inherit (pkgs-unstable)
          dms-shell
          dgop
          matugen
          cava
          khal
          fuzzel
          swaylock
          wtype;
      })
    ];
      programs.dank-material-shell = {

      enable = true;

      systemd = {
        enable = true;             # Systemd service for auto-start
        restartIfChanged = true;   # Auto-restart dms.service when dms-shell changes
      };

      # Core features
      enableSystemMonitoring = true;     # System monitoring widgets (dgop)
      enableVPN = true;                  # VPN management widget
      enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
      enableAudioWavelength = true;      # Audio visualizer (cava)
      enableCalendarEvents = true;       # Calendar integration (khal)
      enableClipboardPaste = true;       # Pasting from the clipboard history (wtype)
    };
  };
}
