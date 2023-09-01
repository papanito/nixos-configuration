{ config, pkgs, ... }:

{
  #environment = {
  #  (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" 
  #    qemu-system-x86_64 \
  #      -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
  #      "$@"
  #  )
  #};

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ 
    qemu
    virt-manager
    gnome.gnome-boxes
    darling # Open-source Darwin/macOS emulation layer for Linuc
    # 
    (wine.override { wineBuild = "wine64"; })
    # wine-staging (version with experimental features)
    #wineWowPackages.staging
    # winetricks (all versions)
    winetricks
    # native wayland support (unstable)
    wineWowPackages.waylandFull
    bottles
  ];

  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.guest.x11 = true;
  # users.extraGroups.vboxusers.members = [ "papanito" ];
}
