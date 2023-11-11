{ config, lib, pkgs, ... }:

{
  fonts= {
    packages = with pkgs; [
      font-awesome_4
      meslo-lgs-nf
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
        monospace = [ "MesloLGS NF" "FiraCode" "Font Awesome" ];
        sansSerif = [ "Open Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };
}
