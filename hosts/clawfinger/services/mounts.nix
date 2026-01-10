{ config, lib, pkgs, modulesPath, hosts, ... }:
let
  # Extract values from your existing hosts definition
  targetIp = hosts.envy.deployment.targetHost;
in
{
  fileSystems."/home/papanito/paperless-inbox" = {
    device = "${targetIp}:/var/lib/paperless/consume";
    fsType = "sshfs";
    options = [ 
      "allow_other"          # Allows your local user to see it
      "_netdev"              # Tells NixOS to wait for network before mounting
      "x-systemd.automount"  # Mounts it only when you try to access the folder
      "identityfile=/home/papanito/.ssh/id_ssh_admin@envy.ed25519"
    ];
  };

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
