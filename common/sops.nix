{ lib, config, pkgs, inputs, sops-nix, ... }:

{
  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.GODSMACK = {};
    secrets.default_password = {
      neededForUsers = true; # Critical: decrypts before users are created
    };
    templates."GODSMACK.psk" = {
      path = "/var/lib/iwd/GODSMACK.psk";
      content = ''
        [Security]
        Passphrase=${config.sops.placeholder.GODSMACK}
      '';
      # iwd is very picky about permissions
      owner = "root";
      mode = "0600";
    };
  };
  environment.systemPackages = with pkgs; [
    sops
  ];
}
