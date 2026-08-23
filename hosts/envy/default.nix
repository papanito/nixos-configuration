{ pkgs, ... }: {
  imports = [
    ./adguard.nix
    ./hardware.nix
    ./jellyfin.nix
    ./networking.nix
    ./rclone.nix
  ];

}
