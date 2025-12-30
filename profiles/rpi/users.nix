{ lib, config, pkgs, ... }:
{
  # see ../servers/users.nix
  users.users.root = {
    # Ensure no SSH keys are snuck in from the RPi base profiles
    openssh.authorizedKeys.keys = lib.mkForce [ ];
    hashedPasswordFile = config.sops.secrets.default_password.path;
  };
}
