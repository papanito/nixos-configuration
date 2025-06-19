{ config, pkgs, lib, ... }:

let
   cfg = config.kde;
in
{
  options.kde = {
    enable 
      = lib.mkEnableOption "enable kde and install related software";
  };

  config = lib.mkIf cfg.enable {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
        defaultSession = "plasma";
      };
    };

    # Add common KDE applications you want to install
    environment.systemPackages = with pkgs; [
      # Basic utilities
      kdePackages.discover          # Software Center (for Flatpak/firmware updates)
      kdePackages.kcalc             # Calculator
      kdePackages.kcharselect       # Character selector
      kdePackages.kolourpaint       # Simple paint program
      kdePackages.ksystemlog        # System log viewer
      kdePackages.partitionmanager  # Disk partition manager
      kdiff3            # File/directory comparison tool
      kdePackages.spectacle         # Screenshot tool

      # More advanced KDE applications (add as needed)
      kdePackages.dolphin           # File manager (often installed with plasma6 already, but good to include if missing)
      kdePackages.kate              # Advanced text editor
      kdePackages.konsole           # Terminal emulator
      kdePackages.okular            # Document viewer
      kdePackages.kdenlive          # Video editor (large package)
      kdePackages.kmail             # Email client
      kdePackages.gwenview          # Image viewer
      kdePackages.kfind             # File search tool
      kdePackages.ark               # Archiving tool

      kdePackages.sweeper           # Application that helps to clean unwanted traces the user leaves on the system
      kdePackages.kdeconnect-kde    # multi-platform app that allows your devices to communicate

      # If you want a more "complete" set of default KDE apps, you can look at the plasma6 module's source:
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/desktop-managers/plasma6.nix
      # and add packages from its `environment.systemPackages` list or `excludePackages` list.
      # For example, to include all applications that `plasma6` would normally install:
      # (However, this is generally not recommended as it's better to pick what you need.)
      # config.services.desktopManager.plasma6.packages
    ];

    # Optional: Exclude specific packages if you want a lighter install
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
    #   plasma-browser-integration # Comment out if you use KDE Connect
    #   kdepim-runtime             # Unneeded if you use Thunderbird, etc.
      konsole                    # If you prefer another terminal
    ];
  };
}
