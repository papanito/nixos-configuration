{ lib, config, pkgs, ... }:
{
  imports = [
    ../nice-looking-console.nix
    ./networking.nix
    ./users.nix
  ];

  # Force unblock the radio (Sometimes RPi starts with Wi-Fi disabled)
  system.activationScripts.rfkillUnblockWlan = {
    text = ''
      ${pkgs.rfkill}/bin/rfkill unblock wlan
    '';
  };

  environment.systemPackages = with pkgs; [
    tree
  ];
}
