{ config, pkgs, lib, ... }:

let
   cfg = config.kde;
in
{
  options.kde = {
    enable 
      = lib.mkEnableOption "enable kde and install relatedd software";
  };
  config = lib.mkIf cfg.enable {

    services.xserver.enable = true;
    services.xserver.displayManager.sddm.wayland.enable = true;
    # KDE Plasma 6 is now available on unstable
    services.xserver.desktopManager.plasma6.enable = true;
    services.xserver.displayManager.defaultSession = "plasma";

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "ch";
      variant = "de_nodeadkeys";
    };
    
    #services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  };
}
