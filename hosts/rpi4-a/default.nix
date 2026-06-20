{
  config,
  pkgs,
  lib,
  name,
  inputs,
  ...
}:
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
    options = [
      "noatime"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=1min"
    ];
  };
  # Ensure the RPi firmware is actually enabled
  hardware.enableRedistributableFirmware = true;
  boot = {
    # Explicitly define supported filesystems (exclude zfs)
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "ext4"
      "vfat"
    ];
    # Force GRUB off and enable Generic Extlinux
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      generic-extlinux-compatible.configurationLimit = 3;
    };

    # Use the well-cached mainline kernel
    kernelPackages = inputs.nixos-raspberrypi.packages.${pkgs.system}.linuxPackages_rpi4;
  };
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
