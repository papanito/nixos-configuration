{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ghostscript
    ncspot # Cross-platform ncurses Spotify client written in Rust, inspired by ncmpc and the likes
    spotify
    spotify-tui # Spotify for the terminal written in Rust
    spotify-tray # Adds a tray icon to the Spotify Linux client application.
    yt-dlp
    ytmdl
    ffmpeg-full
    peertube # A free software to take back control of your videos
    vlc # Cross-platform media player and streaming server
    rhythmbox # A music playing application for GNOME
  ];
}
