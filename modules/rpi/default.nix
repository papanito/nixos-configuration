{ lib, config, pkgs, ... }:
{
  imports = [
    ../modules/nice-looking-console.nix
    ./networking.nix
    ./users.nix
  ];
  environment.systemPackages = with pkgs; [
    tree
  ];
}
