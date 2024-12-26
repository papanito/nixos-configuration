{ lib, config, pkgs, ... }:

{
  #environment = {
  #  (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" 
  #    qemu-system-x86_64 \
  #      -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
  #      "$@"
  #  )
  #};
  options = {
    virtualisation.enable 
      = lib.mkEnableOption "enable libvirtd and install related software";
  };

  config = lib.mkIf config.virtualisation.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = ["papanito"];
    virtualisation.spiceUSBRedirection.enable = true;
    
    environment.systemPackages = with pkgs; [ 
      qemu
      virt-manager
      gnome-boxes
      #darling # Open-source Darwin/macOS emulation layer for Linux
    ];
  };
}
