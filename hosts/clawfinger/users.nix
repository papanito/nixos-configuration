{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.papanito = {
    isNormalUser = true;
    description = "papanito";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
      chezmoi
      gnomeExtensions.bing-wallpaper-changer
      gnomeExtensions.keep-awake # Keep your computer awake! Prevents that your computer activates sceensaver, turns off screen(s) or goes to hibernate when not actively used for a while. 
      gnomeExtensions.gsconnect
      gnomeExtensions.hue-lights
      gnomeExtensions.top-bar-organizer
      gnomeExtensions.topiconsfix # Shows legacy tray icons on top – the fixed version of https://extensions.gnome.org/extension/495/topicons/
      gnomeExtensions.tophat
      gnomeExtensions.status-area-horizontal-spacing # Reduce the horizontal spacing between icons in the top-right status area
      #gnomeExtensions.window-state-manager
      gnomeExtensions.power-profile-switcher # Automatically switch between power profiles based on power supply and percentage.
      gnomeExtensions.just-perfection # Tweak Tool to Customize GNOME Shell, Change the Behavior and Disable UI Elements
      gnomeExtensions.ip-finder # Displays useful information about your public IP Address and VPN status.
      gnomeExtensions.forge # Tiling and window manager for GNOME
      gnomeExtensions.display-configuration-switcher # Quickly change the display configuration from the system menu.
      gnomeExtensions.another-window-session-manager # Close open windows gracefully and save them as a session. 
      gnomeExtensions.tuxedo-fnlock-status # Show the FnLock status of TUXEDO devices.
      gnomeExtensions.battery-health-charging # Set battery charging threshold / charging limit / charging mode
      gnomeExtensions.hue-lights # This extension controls Philips Hue compatible lights using Philips Hue Bridge on your local network, it also allows controlling Philips Hue Sync Box. I
      ticker # Terminal stock ticker with live updates and position tracking
      vhs # Tool for generating terminal GIFs with code
      lutris # Open Source gaming platform for GNU/Linux
    ];
  };

  systemd.services."user@".serviceConfig.Delegate="cpu cpuset io memory pids";
  #systemd.user.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";

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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

}
