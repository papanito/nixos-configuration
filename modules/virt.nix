{ lib, config, pkgs, ... }:

{
  options = {
    virtualisation.enable 
      = lib.mkEnableOption "enable libvirtd and install related software";
  };

  config = lib.mkIf config.virtualisation.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = ["papanito"];
    virtualisation.spiceUSBRedirection.enable = true;
    
    networking.firewall.interfaces."virbr0" = {
      allowedUDPPorts = [ 67 68 ]; # Allow DHCP
    };

    environment.systemPackages = with pkgs; [
      qemu
      virt-manager
      virt-viewer
    ];
  };
}

