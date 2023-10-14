{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ghostscript
    mpv # General-purpose media player, fork of MPlayer and mplayer2
    ncspot # Cross-platform ncurses Spotify client written in Rust, inspired by ncmpc and the likes
    spotify
    spotify-tui # Spotify for the terminal written in Rust
    spotify-tray # Adds a tray icon to the Spotify Linux client application.
    yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    ytmdl # YouTube Music Downloader
    youtube-dl # Command-line tool to download videos from YouTube.com and other sites
    youtube-tui # An aesthetically pleasing YouTube TUI written in Rust
    ffmpeg-full
    gst_all_1.gstreamer # Open source multimedia framework
    peertube # A free software to take back control of your videos
    streamlink # CLI for extracting streams from various websites to video player of your choosing
    vlc # Cross-platform media player and streaming server
    rhythmbox # A music playing application for GNOME
    tesseract # OCR engine
    gnome-frog # Intuitive text extraction tool (OCR) for GNOME desktop
  ];
}
