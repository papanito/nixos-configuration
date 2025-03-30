{ config, lib, pkgs, modulesPath, ... }:

{
  # fileSystems."/mnt/yunohost" = {
  #   device = "admin@yuno.home:/media";
  #   fsType = "sshfs";
  #   options = [
  #     "noauto"
  #     "x-systemd.automount"
  #     "_netdev"
  #     "reconnect"
  #     "identityfile=/home/papanito/.ssh/id_ssh_admin@yunohost.ed25519"
  #     "allow_other"
  #   ];
  # };

  fileSystems."/mnt/envy" = {
    device = "admin@10.0.0.11:/media";
    fsType = "sshfs";
    options = [
      "noauto"
      "x-systemd.automount"
      "_netdev"
      "reconnect"
      "identityfile=/home/papanito/.ssh/id_ssh_admin@envy.ed25519"
      "allow_other"
    ];
  };
}