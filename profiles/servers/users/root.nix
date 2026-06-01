{ lib, config, pkgs, sops-nix, ...}:
{  # allow nix-copy to live system
  users.users.root = {
    openssh.authorizedKeys.keys = lib.mkForce [ ];
    hashedPasswordFile = config.sops.secrets.default_password.path;
  };
}
