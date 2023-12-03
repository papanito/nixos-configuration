{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "ch";
    xkbVariant = "de_nodeadkeys";
  };
  
  programs.dconf.enable = true;
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  programs.gpaste.enable = true;


  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
  ])++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-terminal
    gedit # text editor
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    nautilus
    nautilus-python
    geary
    sushi
  ]);
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bleachbit # A program to clean your computer
    gnome.seahorse
    gnome3.gnome-tweaks
    gnome.gpaste
    gnome.gvfs # Virtual Filesystem support library (full GNOME support)
    gnome.ghex # Hex editor for GNOME desktop environment
    gnome.totem # Movie player for the GNOME desktop based on GStreamer
    gnome-usage # A nice way to view information about use of system resources, like memory and disk space
    gnome-feeds # An RSS/Atom feed reader for GNOME
    gnome.zenity # Tool to display dialogs from the commandline and shell scripts
    gnome-photos # Access, organize and share your photos
    gnomecast # A native Linux GUI for Chromecasting local files
    denaro # Personal finance manager for GNOME
    nautilus-open-any-terminal
    gradience # Customize libadwaita and GTK3 apps (with adw-gtk3)
    gnomeExtensions.appindicator
    gnomeExtensions.burn-my-windows
    #gnomeExtensions.tophat
    #gnomeExtensions.forge
    #gnomeExtensions.battery-health-charging # Battery Health Charging: An extension to maximize the battery life of laptops by setting their charging threshold or modes.
    gnomeExtensions.openweather
    gnomeExtensions.task-widget
    gnomeExtensions.another-window-session-manager
    gnomeExtensions.sound-output-device-chooser
    gnome.geary # Mail client for GNOME 3
    #gnomeExtensions.geary-tray-icon # Adds an icon to the panel to open mailbox and creating new mail.
  ];
}
