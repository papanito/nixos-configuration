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
    environment.variables = {
      KWIN_DRM_PREFER_COLOR_DEPTH = "24";
    };

    services = {
      desktopManager.plasma6 = {
        enable = true;
      };
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        defaultSession = "plasma";
      };

    };

    # systemd.services.dlm.wantedBy = [ "multi-user.target" ];
    # --- THIS IS THE CRUCIAL PART FOR ENABLING THE SERVICE ---
    systemd.services.displaylink-server = {
      enable = true;
      # Ensure it starts after udev has done its work
      requires = [ "systemd-udevd.service" ];
      after = [ "systemd-udevd.service" ];
      wantedBy = [ "multi-user.target" ]; # Start at boot
      # *** THIS IS THE CRITICAL 'serviceConfig' BLOCK ***
      serviceConfig = {
        Type = "simple"; # Or "forking" if it forks (simple is common for daemons)
        # The ExecStart path points to the DisplayLinkManager binary provided by the package
        ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
        # User and Group to run the service as (root is common for this type of daemon)
        User = "root";
        Group = "root";
        # Environment variables that the service itself might need
        # Environment = [ "DISPLAY=:0" ]; # Might be needed in some cases, but generally not for this
        Restart = "on-failure";
        RestartSec = 5; # Wait 5 seconds before restarting
      };
    };

    # Add common KDE applications you want to install
    environment.systemPackages = with pkgs; [
      libinput # So touchpad gestures work

      # Basic utilities
      kdePackages.discover          # Software Center (for Flatpak/firmware updates)
      kdePackages.kcalc             # Calculator
      kdePackages.kcharselect       # Character selector
      kdePackages.kolourpaint       # Simple paint program
      kdePackages.ksystemlog        # System log viewer
      kdePackages.partitionmanager  # Disk partition manager
      kdiff3                        # File/directory comparison tool
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
      kdePackages.knewstuff

      kdePackages.sweeper           # Application that helps to clean unwanted traces the user leaves on the system
      kdePackages.kdeconnect-kde    # multi-platform app that allows your devices to communicate

      pinentry-qt
      kwalletcli # Useful for command-line KWallet interaction if needed
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


    # For SDDM, these lines are usually already present, but it's good to be explicit
    # if you have issues, you might need to use `services.pam.services.sddm.text`
    # similar to the FIDO key setup to ensure pam_kwallet5.so is correctly ordered.
    security.pam.services = {
      sddm.enableKwallet = true;
      login.enableKwallet = true; # For console logins too
      sudo.enableKwallet = true; # If you want sudo to unlock kwallet
    };

    # Environment variable for pinentry-kwallet to signal KWallet use
    environment.sessionVariables = {
      PINENTRY_KDE_USE_WALLET = "1";
      # Ensure GPG_TTY is set when launching graphical sessions
      GPG_TTY = "$HOME/.tty"; # This will be set by the session
    };
  };
}
