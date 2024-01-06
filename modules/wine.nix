{ lib, config, pkgs, ... }:

{
  options = {
    windows-support.enable
      = lib.mkEnableOption "enable wine and stuff";
  };

  config = lib.mkIf config.windows-support.enable {
    environment.systemPackages = with pkgs; [ 
      (wine.override { wineBuild = "wine64"; })
      # wine-staging (version with experimental features)
      # wineWowPackages.staging
      winetricks # winetricks (all versions)
      wineWowPackages.waylandFull # native wayland support (unstable)
      bottles
    ];
  };
}
