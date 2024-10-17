{ config, lib, pkgs, modulesPath, ... }:

{
  fileSystems."/mnt/yunohost" = {
    device = "admin@yuno.home:/media";
    fsType = "sshfs";
    options = [
      "noauto"
      "x-systemd.automount"
      "_netdev"
      "reconnect"
      "identityfile=/home/papanito/.ssh/id_rsa"
      "allow_other"
    ];
  };
}