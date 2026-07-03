{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.papanito = {
    isNormalUser = true;
    description = "papanito";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "input"
    ];
    packages = with pkgs; [
      chezmoi
    ];
  };
  # Fix: udev rules reference plugdev group (70-u2f.rules) which doesn't exist by default in NixOS
  users.groups.plugdev = { };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

}
