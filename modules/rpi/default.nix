{ lib, config, pkgs, inputs, ... }:
{
  imports = [
    ./networking.nix
    ./users.nix
  ];
}
