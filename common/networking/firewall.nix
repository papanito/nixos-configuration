{ config, pkgs, ... }:
{
   ## app-specific firewall rules are found in the respective nix-file
   networking.firewall.enable = true;
}
