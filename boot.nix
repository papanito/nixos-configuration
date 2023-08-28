{ config, pkgs, ... }:

{
 # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.tuxedo-keyboard.enable = true;
  boot.kernelParams = [
    "tuxedo_keyboard.mode=0"
    "tuxedo_keyboard.brightness=25"
    "tuxedo_keyboard.color_left=0x0000ff"
  ];
  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-7f34b0ef-aa8a-412a-933c-a42414371fad".device = "/dev/disk/by-uuid/7f34b0ef-aa8a-412a-933c-a42414371fad";
  boot.initrd.luks.devices."luks-7f34b0ef-aa8a-412a-933c-a42414371fad".keyFile = "/crypto_keyfile.bin";
}

