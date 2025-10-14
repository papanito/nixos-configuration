{ config, pkgs, lib, ... }:

let
   cfg = config.gnome;
in
{
  options.gnome = {
    enable 
      = lib.mkEnableOption "enable gnome and install relatedd software";
  };
  config = lib.mkIf cfg.enable {
    services = {
      udev.packages = with pkgs; [ gnome-settings-daemon ];
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xserver = {
        enable = true;
        videoDrivers = [ "displaylink" ];
        # Configure keymap in X11
        xkb = {
          layout = "ch";
          variant = "de_nodeadkeys";
        };
      };
      gnome = {
        gnome-user-share.enable= true;
        gnome-online-accounts.enable = true;
        gnome-browser-connector.enable = true;
        gnome-keyring.enable = true;
      };
    };
    systemd.services.dlm.wantedBy = [ "multi-user.target" ];

    programs = {
      dconf.enable = true;
      gpaste.enable = true;
      seahorse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      epiphany # web browser
      geary # email reader
      seahorse
      gpaste
      gvfs # Virtual Filesystem support library (full GNOME support)
      ghex # Hex editor for GNOME desktop environment
      totem # Movie player for the GNOME desktop based on GStreamer
      zenity # Tool to display dialogs from the commandline and shell scripts
      evince # document viewer
      totem # video player
      nautilus
      nautilus-python
      sushi
      gnome-characters
      bleachbit # A program to cleutiluan your computer
      gdm-settings #   Settings app for GNOME's Login Manager
      gedit # text editor
      gnome-usage # A nice way to view information about use of system resources, like memory and disk space
      gnome-feeds # An RSS/Atom feed reader for GNOME
      gnome-photos # Access, organize and share your photos
      gnome-tweaks
      gnomecast # A native Linux GUI for Chromecasting local files
      denaro # Personal finance manager for GNOME
      nautilus-open-any-terminal
      gnomeExtensions.appindicator
      gnomeExtensions.task-widget
      #gnomeExtensions.sermon # SerMon: an extension for monitoring and managing systemd services, cron jobs, docker and podman containers
      gnome-browser-connector # Native host connector for the GNOME Shell browser extension
      libgtop
    ];

    environment.variables = {
      GI_TYPELIB_PATH = "/run/current-system/sw/lib/girepository-1.0";
    };
    
    qt = {
      enable = false;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
  };
}
