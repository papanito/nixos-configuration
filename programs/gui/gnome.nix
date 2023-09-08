{ config, pkgs, ... }:

{
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
  
  programs.dconf.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnome.seahorse
    gnome3.gnome-tweaks
    gnome.gpaste
    #gnome.polari
    nautilus-open-any-terminal
    gnomeExtensions.appindicator
    # gnomeExtensions.paperwm
    gnomeExtensions.burn-my-windows
    #gnomeExtensions.tophat
    #gnomeExtensions.forge
    gnomeExtensions.openweather
    gnomeExtensions.task-widget
    gnomeExtensions.another-window-session-manager
    gnomeExtensions.sound-output-device-chooser
    gnome.geary # Mail client for GNOME 3
    gnomeExtensions.geary-tray-icon # Adds an icon to the panel to open mailbox and creating new mail.
  ];
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
}
