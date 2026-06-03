{ config, pkgs, lib, name, ... }:
{
  imports = [
  ];

  # --- File Systems (from your cat /etc/fstab output) ---
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = [ "noatime" "noauto" "x-systemd.automount" "x-systemd.idle-timeout=1min" ];
  };
  # Ensure the RPi firmware is actually enabled
  hardware.enableRedistributableFirmware = true;
  # Explicitly define supported filesystems (exclude zfs)
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "ext4" "vfat" ];
  # Force GRUB off and enable Generic Extlinux
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.generic-extlinux-compatible.configurationLimit = 3;

  # Use the well-cached mainline kernel
  boot.kernelPackages = pkgs.linuxPackages;

  # Disable the vendor-specific loader module
  # (This prevents the "grub.devices" requirement)
  #boot.loader.raspberryPi.enable = lib.mkForce false;

  # Refactored Tags
  # We manually set these because 'config.boot.loader.raspberryPi'
  # is no longer being populated.
  system.nixos.tags = [
    "rpi-mainline"
    "extlinux"
    config.boot.kernelPackages.kernel.version
  ];
}
