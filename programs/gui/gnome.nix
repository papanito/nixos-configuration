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
  ];
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
}
