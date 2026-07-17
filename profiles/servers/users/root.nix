{ lib, config, pkgs, sops-nix, ...}:
{  # allow nix-copy to live system
  users.users.root = {
    openssh.authorizedKeys.keys = lib.mkForce [ ];
    hashedPasswordFile = lib.mkIf
      ((config.sops.secrets ? default_password) &&
       (config.sops.secrets.default_password ? path))
      config.sops.secrets.default_password.path;
    initialPassword = lib.mkIf (!(config.sops.secrets ? default_password)) "nixos";
    initialHashedPassword = lib.mkForce null;
  };
}
