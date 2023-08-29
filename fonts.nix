{ config, lib, pkgs, ... }: {
  fonts = lib.mkIf config.programs.sway.enable {
    fonts = with pkgs; [
      font-awesome_4
      nerdfonts
      noto-fonts
      noto-fonts-emoji
      open-sans
      powerline-fonts
      terminus-nerdfont
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "FiraCode" "Font Awesome" ];
        sansSerif = [ "Open Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };
}