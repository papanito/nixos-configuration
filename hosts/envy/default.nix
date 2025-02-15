#
# Contains modules for configuring systems.
#
{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./packages.nix
    ./networking
  ];
  nix.settings.trusted-users = [ "admin" ];
  boot.loader = {
    systemd-boot.enable = true; 
    efi.canTouchEfiVariables = true;
  };
  services.openssh.enable = true;

  users = {
    groups ={
      admin = {};
    };
    users = {
      admin = {
        openssh.authorizedKeys.keys = [
          " ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTCwPNpVjW6R9vqpKgNSWgGS5hZMZcHwexAMl7E/OI2 admin@envy from clawfinger"
        ];
        group = "admin";
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [];
      };
    };
  };

  security = {
    pam = {
      rssh.enable     =  true;
      services = {
          sudo.rssh   =  true;
      };
    };
    sudo = {
      execWheelOnly  =  true;
      wheelNeedsPassword = false;
    };
  };


  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
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
  fun.enable = false;

  ## printing module
  printing.enable = false;
  printing.drivers = [ pkgs.hplipWithPlugin ];

  ## virtualisation module
  virtualisation.enable = false;
  windows-support.enable = false;
}
