# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "usbhid"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [ ];
  };  
  
  fileSystems."/" = { 
      device = "/dev/disk/by-uuid/0a81878c-2e28-4c73-8589-96446e93c6a4";
      fsType = "ext4";
  };
  fileSystems."/home" = { 
      device = "/dev/disk/by-uuid/a308663e-a262-448d-bfdf-16cd450cf246";
      fsType = "btrfs";
  };

  boot.initrd.luks.devices."luks-266811b8-953c-4007-9bbd-ed9a009f72ed".device = "/dev/disk/by-uuid/266811b8-953c-4007-9bbd-ed9a009f72ed";
  boot.initrd.luks.devices."luks-361b9e74-4d96-49fa-9243-1676586caed0".device = "/dev/disk/by-uuid/361b9e74-4d96-49fa-9243-1676586caed0";

  fileSystems."/boot" ={ 
    device = "/dev/disk/by-uuid/B581-AD78";
      fsType = "vfat";
  };

  swapDevices = [
    { 
      device = "/dev/disk/by-uuid/0b1951d8-e365-4f7a-a072-10c383407677";
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s20f0u1.useDHCP = lib.mkDefault true
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}