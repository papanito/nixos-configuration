{ config, lib, pkgs, ... }:

{
  fonts= {
    packages = with pkgs; [
      font-awesome_4
      meslo-lgs-nf
      nerd-fonts.droid-sans-mono
      nerd-fonts.fantasque-sans-mono
      nerd-fonts.meslo-lg
      nerd-fonts.fira-mono
      nerd-fonts.intone-mono
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.terminess-ttf
      noto-fonts
      noto-fonts-color-emoji
      open-sans
      powerline-fonts
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
