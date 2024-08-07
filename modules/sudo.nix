{ config, lib, pkgs, modulesPath, ... }:

{
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "${pkgs.systemd}/bin/systemctl suspend";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/poweroff";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/cryptsetup";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/tomb";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/mount";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
    extraConfig = with pkgs; ''
      Defaults:picloud secure_path="${lib.makeBinPath [
        systemd
      ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
  };
}