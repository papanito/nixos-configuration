{ config, pkgs, ... }:

{
  users.groups.paperless = {
    gid = 232071;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.papanito = {
    isNormalUser = true;
    description = "papanito";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "paperless" ];
    packages = with pkgs; [
      chezmoi
      gnomeExtensions.espresso
      gnomeExtensions.gsconnect
      gnomeExtensions.hue-lights
      gnomeExtensions.top-bar-organizer
      gnomeExtensions.stocks-extension # Outdated
      gnomeExtensions.show-external-ip-thisipcancyou # Outdated
      gnomeExtensions.google-earth-wallpaper
    ];
  };
}
