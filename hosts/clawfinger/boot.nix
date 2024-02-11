{ config, pkgs, ... }:

{
  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-7f34b0ef-aa8a-412a-933c-a42414371fad".device = "/dev/disk/by-uuid/7f34b0ef-aa8a-412a-933c-a42414371fad";
  boot.initrd.luks.devices."luks-7f34b0ef-aa8a-412a-933c-a42414371fad".keyFile = "/crypto_keyfile.bin";
 
  # Bootloader and stuff
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    plymouth = {
      enable = true;
      #themePackages = [ nixos-boot ];
      #theme = "load_unload";
    };
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
  };
}
