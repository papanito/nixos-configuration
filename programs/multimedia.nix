{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ghostscript
    spotify
    yt-dlp
    ytmdl
    ffmpeg-full
  ];
}
