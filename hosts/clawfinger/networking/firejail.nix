{ config, pkgs, ... }:

{
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      signal-desktop-bin = {
        executable = "${pkgs.signal-desktop}/bin/signal-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland";
        profile = "${pkgs.firejail}/etc/firejail/signal-desktop.profile";
        extraArgs = [ "--env=LC_ALL=C" "--env=GTK_THEME=Adwaita:dark" ];
      };
    };
  };
}
