{ config, pkgs, lib, ... }:

let
   cfg = config.office;
in
{
  options.multimedia = {
    enable 
      = lib.mkEnableOption "enable multimedia module";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      audacity #Sound editor with graphical UI
      ffmpeg-full
      gst_all_1.gstreamer # Open source multimedia framework
      gimp
      #gimpPlugins.gap
      #gimpPlugins.gmic
      gimpPlugins.bimp
      gimpPlugins.fourier
      gimpPlugins.texturize
      gimpPlugins.lqrPlugin
      gimpPlugins.lightning
      gimpPlugins.gimplensfun
      gimpPlugins.waveletSharpen
      ghostscript # PostScript interpreter (mainline version)
      gnome-frog # Intuitive text extraction tool (OCR) for GNOME desktop
      imagemagick # A software suite to create, edit, compose, or convert bitmap images
      ncspot # Cross-platform ncurses Spotify client written in Rust, inspired by ncmpc and the likes
      peertube # A free software to take back control of your videos
      rhythmbox # A music playing application for GNOME
      spotify
      spotify-tray # Adds a tray icon to the Spotify Linux client application.
      spotdl # Download your Spotify playlists and songs along with album art and metadata
      streamlink # CLI for extracting streams from various websites to video player of your choosing
      tesseract # OCR engine
      vlc # Cross-platform media player and streaming server
      yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
      youtube-tui # An aesthetically pleasing YouTube TUI written in Rust
      ytmdl # neYouTube Music Downloader
    ];
  };
}
