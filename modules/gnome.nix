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
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "ch";
      variant = "de_nodeadkeys";
    };
    
    programs.dconf.enable = true;
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
    programs.gpaste.enable = true;

    services.gnome = {
      gnome-user-share.enable= true;
      gnome-online-accounts.enable = true;
      gnome-browser-connector.enable = true;
    };
    programs.seahorse.enable = true;

    environment.gnome.excludePackages = (with pkgs; [
      gnome-tour
    ])++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-terminal
      epiphany # web browser
      geary # email reader
      seahorse
      gpaste
      gvfs # Virtual Filesystem support library (full GNOME support)
      ghex # Hex editor for GNOME desktop environment
      totem # Movie player for the GNOME desktop based on GStreamer
      zenity # Tool to display dialogs from the commandline and shell scripts
      evince # document viewer
      gnome-characters
      totem # video player
      nautilus
      nautilus-python
      geary
      sushi
    ]);
    
    environment.systemPackages = with pkgs; [
      bleachbit # A program to cleutiluan your computer
      gedit # text editor
      gnome-usage # A nice way to view information about use of system resources, like memory and disk space
      gnome-feeds # An RSS/Atom feed reader for GNOME
      gnome-photos # Access, organize and share your photos
      gnome3.gnome-tweaks
      gnomecast # A native Linux GUI for Chromecasting local files
      denaro # Personal finance manager for GNOME
      nautilus-open-any-terminal
      gradience # Customize libadwaita and GTK3 apps (with adw-gtk3)
      gnomeExtensions.appindicator
      gnomeExtensions.burn-my-windows
      gnomeExtensions.tophat
      gnomeExtensions.openweather
      gnomeExtensions.task-widget
      gnomeExtensions.another-window-session-manager
      gnomeExtensions.smartcard-lock #This extension just locks the screen whenever a smartcard token recognized by GNOME as used for login is removed.
      gnome.geary # Mail client for GNOME 3
      gnome-browser-connector # Native host connector for the GNOME Shell browser extension
      libgtop
    ];

    environment.variables = {
      GI_TYPELIB_PATH = "/run/current-system/sw/lib/girepository-1.0";
    };
    
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
  };
}
