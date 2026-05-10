{ lib, config, pkgs, ...}:
{
  imports = [
    ./hardening.nix
    ./pam.nix
    ./security.nix
    ./security_tools.nix
    ./usbguard.nix
  ];
}

