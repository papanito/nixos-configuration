# Disk layout for envy17 (x86_64).
#
# Layout:
#   nvme0n1 (Samsung MZVLW256) -> ESP + / + 8G swap
#   sda      (whole device)    -> /home (single ext4 partition)
#
# Devices are referenced via /dev/sda and the existing nvme by-id. If the
# SATA device ever shows up as /dev/sdb or similar, update the `device`
# below or switch to /dev/disk/by-id/... once you know the disk's id.
{
  disko.devices = {
    disk = {
      # NVMe: ESP (boot) + root + 8G swap (hibernate-capable for ≤8G RAM).
      # 8G is enough for a typical laptop; bump to match RAM size if you
      # upgrade past 8 GB and want reliable hibernate.
      main = {
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLW256HEHP-000H1_S340NX1JC11642";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              # Root fills the space between ESP and the swap partition below.
              # No `end` here — disko will lay root, then the swap partition.
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
            };
            };
            plainSwap = {
              size = "8G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hibernation from this device
              };
            };
          };
        };
      };

      # SATA SSD: whole device becomes /home.
      # Wipes any existing partition table on the target disk.
      home = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            home = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
              };
            };
          };
        };
      };
    };
  };
}
