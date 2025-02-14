{ pkgs, ... }: {
  # host-specific packages
  environment.systemPackages = with pkgs; [
    
    ### UI Tools ###
    profile-sync-daemon
    deluge
    emacs
    irssi
    mutt
    chromium
    evince
    firefox
    google-chrome
    #logseq # A local-first, non-linear, outliner notebook for organizing and sharing your personal knowledge base - disabled due to EOL electron
    ollama
    rpi-imager
    element-desktop # A feature-rich client for Matrix.org
    signal-desktop
    speechd # Common interface to speech synthesis
    tor-browser-bundle-bin
    tailscale # The node agent for Tailscale, a mesh VPN built on WireGuard
    gnomeExtensions.tailscale-qs # Add Tailscale to GNOME quick settings
    timeline #  Display and navigate information on a timeline
    xdg-ninja # Shell script which checks your $HOME for unwanted files and directories
    watchman # Watches files and takes action when they change
    wl-clipboard
    xclip # Tool to access the X clipboard from a console application
    wiki-tui # A simple and easy to use Wikipedia Text User Interface

    #celeste # GUI file synchronization client that can sync with any cloud provider

    ### File system, Storage, File Transfer ###
    insync
    sshfs # FUSE-based filesystem that allows remote filesystems to be mounted over SSH
    ssh-tools # Collection of various tools using ssh
    nfstrace # NFS and CIFS tracing/monitoring/capturing/analyzing tool
    rclone # Command line program to sync files and directories to and from major cloud storage
    s3fs # Mount an S3 bucket as filesystem through FUSE
    warp # Fast and secure file transfer
    
    ### Cert and Security ###
    bitwarden
    bitwarden-cli
    certbot
    mkcert # A simple tool for making locally-trusted development certificates

    ### Shell stuff ###
    guake # Drop-down terminal for GNOME
    mods # AI on the command line
    navi # An interactive cheatsheet tool for the command-line and application launchers
    oh-my-posh # Prompt theme engine for any shell
    ranger # File manager with minimalistic curses interface
    slides # Terminal based presentation tool
    warp-terminal # Rust-based terminal
    xxh # Bring your favorite shell wherever you go through SSH
    
    ### Security and Testing Tools ###
    websocat # Command-line client for WebSockets (like netcat/socat)
    #xgixy # Nginx configuration static analyzer

    ### System ###
    bluez # Bluetooth support for Linux
    bluez-tools # Command line bluetooth manager for Bluez5
    blueman # GTK-based Bluetooth Manager
    brightnessctl # This program allows you read and control device brightness
    home-manager # Nix-based user environment configurator
    paper-age # Easy and secure paper backups of secrets
    power-profiles-daemon # Makes user-selected power profiles handling available over D-Bus
    gnomeExtensions.power-profile-switcher # Automatically switch between power profiles based on power supply and percentage.
    usbutils # Tools for working with USB devices, such as lsusb
    ventoy-full # A New Bootable USB Solution
    wireplumber # A modular session / policy manager for PipeWire
    # yubikey-touch-detector
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