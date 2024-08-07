{ lib, config, pkgs, inputs, sops-nix, ... }:

{
  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    # This will automatically import SSH keys as age keys
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.restic_password = {};
    secrets.B2_ACCOUNT_ID = {};
    secrets.B2_ACCOUNT_KEY = {};
    templates."restic.env".content = ''
      B2_ACCOUNT_ID=${config.sops.placeholder.B2_ACCOUNT_ID}
      B2_ACCOUNT_KEY=${config.sops.placeholder.B2_ACCOUNT_KEY}
    '';
  };
}