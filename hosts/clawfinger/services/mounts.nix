{ config, lib, pkgs, modulesPath, hosts, ... }:
let
  # Extract values from your existing hosts definition
  targetIpEnvy = hosts.envy.deployment.targetHost;
  targetIpLenovo = hosts.lenovo.deployment.targetHost;
in
{
  fileSystems."/home/papanito/paperless/inbox" = {
    device = "nixos@${targetIpLenovo}:/var/lib/paperless/consume";
    fsType = "sshfs";
    options = [ 
      "allow_other"          # Allows your local user to see it
      "_netdev"              # Tells NixOS to wait for network before mounting
      "x-systemd.automount"  # Mounts it only when you try to access the folder
      "identityfile=/home/papanito/.ssh/id_ssh_nixos@homelab.ed25519.pub"
    ];
  };

  fileSystems."/mnt/envy" = {
    device = "nixos${targetIpEnvy}:/media";
    fsType = "sshfs";
    options = [
      "x-systemd.automount"
      "_netdev"
      "reconnect"
      "identityfile=/home/papanito/.ssh/id_ssh_nixos@homelab.ed25519.pub"
      "allow_other"
    ];
  };
}
