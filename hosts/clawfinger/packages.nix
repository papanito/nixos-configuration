{ pkgs, ... }: {
  # host-specific packages
  environment.systemPackages = with pkgs; [
    insync
    profile-sync-daemon
    #transmission # torrent client
    deluge
    ollama
    emacs
    irssi
    mutt
    bitwarden
    bitwarden-cli
    chromium
    evince
    firefox
    google-chrome
    #logseq # A local-first, non-linear, outliner notebook for organizing and sharing your personal knowledge base - disabled due to EOL electron
    rclone # Command line program to sync files and directories to and from major cloud storage
    rpi-imager
    element-desktop # A feature-rich client for Matrix.org
    signal-desktop
    slides # Terminal based presentation tool
    speechd # Common interface to speech synthesis
    tor-browser-bundle-bin
    tailscale # The node agent for Tailscale, a mesh VPN built on WireGuard
    gnomeExtensions.tailscale-qs # Add Tailscale to GNOME quick settings
    topgrade # Upgrade all the things
    timeline #  Display and navigate information on a timeline
    vim
    watchman # Watches files and takes action when they change
    wl-clipboard
    wiki-tui # A simple and easy to use Wikipedia Text User Interface
    warp # Fast and secure file transfer
    warp-terminal # Rust-based terminal
    xxh # Bring your favorite shell wherever you go through SSH

    celeste # GUI file synchronization client that can sync with any cloud provider
    websocat # Command-line client for WebSockets (like netcat/socat)
    sshfs # FUSE-based filesystem that allows remote filesystems to be mounted over SSH
    ssh-tools # Collection of various tools using ssh
    nfstrace # NFS and CIFS tracing/monitoring/capturing/analyzing tool
    s3fs # Mount an S3 bucket as filesystem through FUSE
    openssl
    certbot
    mkcert # A simple tool for making locally-trusted development certificates
    #xgixy # Nginx configuration static analyzer
  ];

  # programs.go = {
  #   enable = true;
  #   packages = { 
  #     "golang.org/x/tools/mksub" = builtins.fetchGit {
  #       url = "https://github.com/trickest/mksub";
  #       rev = "c90cbdc254378cdcee972198f878435da79103af";
  #     };
  #   };
  # };
  
  # pentesting = {
  #   enable = false;
  # };
}