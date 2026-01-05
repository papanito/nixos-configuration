{ lib, config, pkgs, inputs, ... }:
{
  imports = [
    ./networking.nix
    ./users.nix
  ];
                  # We disable GRUB at the root level of the config
                  boot.loader.grub.enable = lib.mkForce false;
                  boot.loader.grub.devices = lib.mkForce [ "nodev" ];
  #boot.loader.generic-extlinux-compatible.enable = lib.mkForce false;
                  
                  # If your 'profiles/servers' is enabling GRUB, we kill it here
                  boot.loader.systemd-boot.enable = lib.mkForce false;
}
