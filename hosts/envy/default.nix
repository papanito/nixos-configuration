{ pkgs, ... }: {
  imports = [
    ./adguard.nix
    ./hardware.nix
    ./jellyfin.nix
    ./users.nix
    ./networking.nix
  ];

}
