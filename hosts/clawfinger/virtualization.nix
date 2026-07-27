{ pkgs, ... }:
{
  users.users.papanito = {
    extraGroups = [ "libvirtd" ];
  };

  # Grant read/write/execute permissions to the libvirtd group on /var/lib/libvirt/images
  systemd.tmpfiles.rules = [
    "Z /var/lib/libvirt 0775 root libvirtd - -"
  ];
  environment.systemPackages = with pkgs; [
    tigervnc
    turbovnc
  ];
}
