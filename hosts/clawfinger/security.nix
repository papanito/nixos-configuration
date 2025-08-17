{ config, lib, pkgs, modulesPath, ... }:

{
  security.sudo = {
    enable = true;
    configFile = ''
# Command alias specification
Cmnd_Alias TOMB = /home/papanito/.nix-profile/bin/tomb
Cmnd_Alias VIRSH = /run/current-system/sw/bin/virsh
Cmnd_Alias LOSETUP = /run/current-system/sw/bin/losetup

# Avoid that tomb execution is logged by syslog
Defaults!TOMB !syslog

'';
   extraRules = [{
      groups = [ "wheel" ];
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
          command = "${pkgs.cryptsetup}/bin/cryptsetup";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.util-linux}/bin/mount";
          options = [ "NOPASSWD" ];
        }
      ];
    }
    {
      # Specific NOPASSWD rules for the user 'papanito'.
      users = [ "papanito" ];
      commands = [
        {
           command = "${pkgs.tomb}/bin/tomb";
           options = [ "NOPASSWD" ];
        }
        {
           command = "${pkgs.libvirt}/bin/virsh";
           options = [ "NOPASSWD" ];
        }
        {
           command = "${pkgs.util-linux}/bin/losetup";
           options = [ "NOPASSWD" ];
         }
      ];
    }];
    extraConfig = with pkgs; ''
      Defaults:picloud secure_path="${lib.makeBinPath [
        systemd
      ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function (action, subject) {
      if (
        subject.isInGroup("users") &&
        [
          "org.freedesktop.login1.reboot",
          "org.freedesktop.login1.reboot-multiple-sessions",
          "org.freedesktop.login1.power-off",
          "org.freedesktop.login1.power-off-multiple-sessions",
        ].indexOf(action.id) !== -1
      ) {
        return polkit.Result.YES;
      }
    });
  '';
}
