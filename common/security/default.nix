{ lib, config, pkgs, ...}:
{
  imports = [
    ./pam.nix
    ./security.nix
    ./security_tools.nix
  ];
}

