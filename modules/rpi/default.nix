{ lib, config, pkgs, ... }:
{
  imports = [
    ../nice-looking-console.nix
    ./networking.nix
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    tree
  ];
}
