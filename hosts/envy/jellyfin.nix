{ pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # host-specific packages
  environment.systemPackages = with pkgs; [
    jellyfin # Free Software Media System
    jellyfin-web
    jellyfin-ffmpeg
    sqlite
    adguardhome
  ];

  fileSystems."/media" = {
    device = "/dev/sda1";
    fsType = "ext4";
    options = [
      "defaults"
      "user"
    ];
  };
}
