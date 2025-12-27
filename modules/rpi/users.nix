{ lib, config, pkgs, ... }:
{
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    password = "$6$/f0v6HdHFSMjukeZ$0/QeGATuWXvhYcU60XPo6Vsqfb1hwIajKGsp90ZthLH8ionsXMFTBXyRXDA119.Ej0ldc35gT9ua0pePtwILI1";
    hashedPasswordFile = config.sops.secrets.defaul:w_password.path;
  };

  users.users.root = {
    password = "$6$/f0v6HdHFSMjukeZ$0/QeGATuWXvhYcU60XPo6Vsqfb1hwIajKGsp90ZthLH8ionsXMFTBXyRXDA119.Ej0ldc35gT9ua0pePtwILI1";
    hashedPasswordFile = config.sops.secrets.default_password.path;
  };
  
  security.polkit.enable = true;

  # Allow passwordless sudo from nixos user
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # allow nix-copy to live system
  nix.settings.trusted-users = [ "nixos" ];
}
