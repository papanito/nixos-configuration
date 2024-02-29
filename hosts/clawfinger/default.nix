#
# Contains modules for configuring systems.
#
{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./networking
    ./services
    ./boot.nix
  ];

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  ## pam stuff
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.logind.extraConfig = ''
    RuntimeDirectorySize=32G
    HandleLidSwitchDocked=ignore
  '';

  # modules
  gnome.enable = true;
  solokey.enable = true;
  container.enable = true;
  cloud.enable = true;
  development.enable = true;
  multimedia.enable = true;
  office.enable = true;

  ## printing module
  printing.enable = true;
  printing.drivers = [ pkgs.hplipWithPlugin ];

  ## virtualisation module
  virtualisation.enable = true;
  windows-support.enable = true;

  ## host-specific packages
  environment.systemPackages = with pkgs; [
    linuxKernel.packages.linux_latest_libre.tuxedo-keyboard
    insync
    profile-sync-daemon
    transmission # torrent client
    deluge
    qbittorrent
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
    logseq # A local-first, non-linear, outliner notebook for organizing and sharing your personal knowledge base
    mkcert # A simple tool for making locally-trusted development certificates
    rpi-imager
    signal-desktop
    slides # Terminal based presentation tool
    speechd # Common interface to speech synthesis
    tor-browser-bundle-bin
    tailscale # The node agent for Tailscale, a mesh VPN built on WireGuard
    gnomeExtensions.tailscale-qs # Add Tailscale to GNOME quick settings
    topgrade # Upgrade all the things
    timeline #  Display and navigate information on a timeline
    thunderbird # A full-featured e-mail client
    vim
    watchman # Watches files and takes action when they change
    wl-clipboard
    wiki-tui # A simple and easy to use Wikipedia Text User Inter
    #xgixy # Nginx configuration static analyzer

  ];

  pentesting.enable = false;
}
