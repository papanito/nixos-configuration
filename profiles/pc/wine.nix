{ lib, config, pkgs, ... }:
let
   cfg = config.modules.windows-support;
in
{
  options.modules.windows-support = {
    enable
      = lib.mkEnableOption "enable kde and install related software";
  };

  config = lib.mkIf cfg.enable {
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
