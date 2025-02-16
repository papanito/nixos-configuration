{ config, lib, pkgs, modulesPath, ... }:

{
  security.sudo = {
    enable = true;
    configFile = ''
# Command alias specification
Cmnd_Alias TOMB = /run/current-system/sw/bin/tomb
Cmnd_Alias VIRSH = /run/current-system/sw/bin/virsh
Cmnd_Alias LOSETUP = /run/current-system/sw/bin/losetup

# Avoid that tomb execution is logged by syslog
Defaults!TOMB !syslog

papanito ALL=(ALL:ALL) NOPASSWD: TOMB, LOSETUP, VIRSH
'';
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
          command = "TOMB";
          options = [ "NOPASSWD" ];
        }
        {
          command = "VIRSH";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/mount";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    # },{ 
    #   commands = [
    #     {
    #       command = "TOMB";
    #       options = [ "NOPASSWD" ];
    #     }
    #   ];
    #   users = [ "papanito" ];
    }];
    extraConfig = with pkgs; ''
      Defaults:picloud secure_path="${lib.makeBinPath [
        systemd
      ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
  };
}