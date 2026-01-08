{ lib, config, pkgs, home-manager, sops-nix, ...}:
let
  myZshConfig = import ../../common/zsh-config.nix { inherit pkgs; };
in {
  # allow nix-copy to live system
  nix.settings.trusted-users = [ "nixos" ];
  services.getty.autologinUser = lib.mkForce null;
  users.mutableUsers = false;
  sops = {
    secrets.default_password = {
      sopsFile = ../../secrets/secrets.yaml;
      neededForUsers = true; # Critical: decrypts before users are created
    };
  };

  # Enable Zsh as a system shell
  home-manager.users.nixos = { pkgs, ... }: {
    programs.zsh = myZshConfig;
    home.stateVersion = "25.11";
  };
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    hashedPasswordFile = config.sops.secrets.default_password.path;
    # Kill the empty string fallback
    initialHashedPassword = lib.mkForce null;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrOn3Kj/+ztMtQAaq4pVvXgTsIs1ZOqQDbsA+nJMuRM nixos@envy from clawfinger"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTCwPNpVjW6R9vqpKgNSWgGS5hZMZcHwexAMl7E/OI2 nixos@envy from clawfinger"
    ];
  };

  users.users.svc-worker = {
    isSystemUser = true;
    group = "svc-worker";
    description = "Service account for non-privileged tasks";
    # Prevents interactive login
    shell = pkgs.shadow; 
    # If the service needs a home directory for config/state
    createHome = true;
    home = "/var/lib/svc-worker";
  };

# Corresponding group
users.groups.svc-worker = {};
  security.polkit.enable = true;

  # Allow passwordless sudo from nixos user
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
}
