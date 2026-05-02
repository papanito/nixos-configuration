{ lib, config, pkgs, ...}:

let
   cfg = config.modules.virtualisation;
in
{
  options.modules.virtualisation = {
    enable
      = lib.mkEnableOption "enable libvirtd and install related software";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true; # Helpful for FUSE/rclone permission passthrough
        # Ensure virtiofsd is visible to QEMU
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = [ "papanito" ];
    virtualisation.spiceUSBRedirection.enable = true;

    networking.firewall.interfaces."virbr0" = {
      allowedUDPPorts = [
        67
        68
      ]; # Allow DHCP
    };

    environment.systemPackages = with pkgs; [
      qemu
      virt-manager
      virt-viewer
    ];

  };
}
