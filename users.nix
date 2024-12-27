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
      #gnomeExtensions.resolution-and-refresh-rate-in-quick-settings
      #gnomeExtensions.vscode-search-provider
      gnomeExtensions.hue-lights # This extension controls Philips Hue compatible lights using Philips Hue Bridge on your local network, it also allows controlling Philips Hue Sync Box. I
      #gnomeExtensions.stocks-extension # Stocks Extension brings stock quotes to your GNOME Shell Panel
      gnomeExtensions.topiconsfix # Shows legacy tray icons on top – the fixed version of https://extensions.gnome.org/extension/495/topicons/
      #gnomeExtensions.battery-health-charging # Battery Health Charging: An extension to maximize the battery life of laptops by setting their charging threshold or modes.
      ticker # Terminal stock ticker with live updates and position tracking
      vhs # Tool for generating terminal GIFs with code
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
    }
  )];
}
