#
# Contains modules for configuring systems.
#
{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./networking
    ./packages.nix
    ./services
    ./boot.nix
    ./tuxedo.nix
  ];

  # Enable sound with pipewire.
  #sound.enable = true;
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
  kde.enable = false;
  solokey.enable = true;
  container.enable = true;
  cloud.enable = true;
  development.enable = true;
  multimedia.enable = true;
  office.enable = true;
  fun.enable = true;

  ## printing module
  printing.enable = true;
  printing.drivers = [ pkgs.hplipWithPlugin ];

  ## virtualisation module
  virtualisation.enable = true;
  windows-support.enable = true;
}
