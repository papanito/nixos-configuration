{ pkgs, ... }: {
  imports = [
    ./disko.nix
    ./hardware.nix
    ./users.nix
  ];
}
