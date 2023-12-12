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
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bleachbit # A program to clean your computer
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
    #gnomeExtensions.forge
    #gnomeExtensions.battery-health-charging # Battery Health Charging: An extension to maximize the battery life of laptops by setting their charging threshold or modes.
    gnomeExtensions.openweather
    gnomeExtensions.task-widget
    gnomeExtensions.another-window-session-manager
    gnomeExtensions.hue-lights # This extension controls Philips Hue compatible lights using Philips Hue Bridge on your local network, it also allows controlling Philips Hue Sync Box. I
    gnomeExtensions.google-earth-wallpaper # Sets your wallpaper to a random photo from the curated Google Earth collection (2604 photos).
    gnomeExtensions.stocks-extension # Stocks Extension brings stock quotes to your GNOME Shell Panel
    gnome.geary # Mail client for GNOME 3
    gnome-browser-connector # Native host connector for the GNOME Shell browser extension
    #gnomeExtensions.geary-tray-icon # Adds an icon to the panel to open mailbox and creating new mail.
    libgtop
  ];

  environment.variables = {
    GI_TYPELIB_PATH = "/run/current-system/sw/lib/girepository-1.0";
  };
}
