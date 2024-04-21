{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.papanito = {
    isNormalUser = true;
    description = "papanito";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
      chezmoi
      gnomeExtensions.espresso
      gnomeExtensions.gsconnect
      gnomeExtensions.hue-lights
      gnomeExtensions.top-bar-organizer
      gnomeExtensions.stocks-extension # Outdated
      gnomeExtensions.google-earth-wallpaper
    ];
  };

  systemd.services."user@".serviceConfig.Delegate="cpu cpuset io memory pids";

  systemd.packages = [(
    pkgs.writeTextFile {
      name = "delegate.conf";
      text = ''
      [Service]
      Delegate=yes
      '';
      destination = "/etc/systemd/system/user@.service.d/delegate.conf";
    })];
  
  security.sudo.configFile = ''
%wheel  ALL=(ALL) NOPASSWD:/run/current-system/sw/bin/cryptsetup, /run/wrappers/bin/mount, /run/current-system/sw/bin/tomb
  '';
}
