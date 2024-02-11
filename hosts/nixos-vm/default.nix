#
# Contains modules for configuring systems.
#
{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./networking
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

  # modules
  gnome.enable = false;
  solokey.enable = false;
  container.enable = false;
  cloud.enable = false;
  multimedia.enable = false;
  office.enable = false;

  ## printing module
  printing.enable = false;
  printing.drivers = [ pkgs.hplipWithPlugin ];

  ## virtualisation module
  virtualisation.enable = false;
  windows-support.enable = false;
}
