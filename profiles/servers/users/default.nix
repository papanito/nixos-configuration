{ lib, config, pkgs, version, home-manager, sops-nix, self, ...}:
let
  myZshConfig = import (self + /common/zsh-config.nix) { inherit pkgs; };
in {
  imports = [
    ./nixos.nix
    ./root.nix
  ];
  # allow nix-copy to live system
  nix.settings.trusted-users = [ "nixos" ];
  services.getty.autologinUser = lib.mkForce null;
  users.mutableUsers = false;
  sops = {
    secrets.default_password = {
      sopsFile = (self + /secrets/secrets.yaml);
      neededForUsers = true; # Critical: decrypts before users are created
    };
  };

  # Enable Zsh as a system shell
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.nixos = { pkgs, ... }: {
      programs.zsh = myZshConfig;
      home.stateVersion = version;
    };
  };

  security = {
    polkit.enable = true;
     # allow the nixos user to run sudo commands without a TTY:
    sudo.extraConfig = ''
      Defaults:nixos !requiretty
    '';
    # Allow passwordless sudo from nixos user
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
