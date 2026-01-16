{
  disko.devices.disk.main = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = { size = "1M"; type = "EF02"; }; # For BIOS/Legacy boot
        ESP = { size = "512M"; type = "EF00"; content = { type = "vfat"; format = "vfat"; mountpoint = "/boot"; }; };
        root = { size = "100%"; content = { type = "ext4"; mountpoint = "/"; }; };
      };
    };
  };
}
