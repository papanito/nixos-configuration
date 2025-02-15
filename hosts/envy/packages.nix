{ pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # host-specific packages
  environment.systemPackages = with pkgs; [
    jellyfin # Free Software Media System
    jellyfin-web
    jellyfin-ffmpeg
  ];
}