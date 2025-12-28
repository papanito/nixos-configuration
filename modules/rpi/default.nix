{ lib, config, pkgs, ... }:
{
  imports = [
    ./networking.nix
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    tree
  ];
}
