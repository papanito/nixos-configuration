{
  lib,
  config,
  pkgs,
  nixosVersion,
  home-manager,
  sops-nix,
  ...
}:
{
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "docker"
    ];
    # Principal (ongoing) password: read from the sops-decrypted file when
    # sops is wired up. The file at /run/secrets/default_password is
    # sops-managed, so the principal follows sops rotation automatically.
    #
    # Initial password: always `nixos` as a first-boot recovery key. The
    # NixOS user module only consumes `initialPassword` when the principal
    # source is missing or empty (file exists but has 0 bytes), so this
    # doesn't conflict with the sops file once it decrypts — the principal
    # just flips to the sops value on the next activation.
    #
    # IMPORTANT: guard BOTH the outer attribute and the inner `.path`. Any
    # module that does `sops.secrets.<name> = lib.mkForce null` would
    # otherwise crash eval at `null.path`.
    hashedPasswordFile = lib.mkIf (
      (config.sops.secrets ? default_password) && (config.sops.secrets.default_password ? path)
    ) config.sops.secrets.default_password.path;
    initialPassword = "nixos";
    # Prevent nixpkgs from setting a placeholder hash that would override
    # both `hashedPasswordFile` and `initialPassword`.
    initialHashedPassword = lib.mkForce null;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrOn3Kj/+ztMtQAaq4pVvXgTsIs1ZOqQDbsA+nJMuRM nixos@homelab from clawfinger"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTCwPNpVjW6R9vqpKgNSWgGS5hZMZcHwexAMl7E/OI2 nixos@homelab from clawfinger"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ91S1yRB15KxFHvko7/ZtyUumrD44RZI4HkLpED/iRE paperless-sync-key"
      # Used by the nixos-configuration GitLab pipeline (shell runner on
      # envy17) to deploy via Colmena. Private key lives in the protected
      # CI variable NIXOS_SSH_KEY_FILE.
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKCx+XrnBuaAdHuS8yUUMOXFqrWuVgCDGOwvuDd3wS6 ci-deploy@nixos-configuration"
      #''command="sudo rsync --server --daemon -vlogDtpr.",no-agent-forwarding,no-port-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ91S1yRB15KxFHvko7/ZtyUumrD44RZI4HkLpED/iRE  paperless-sync-key''
    ];
  };
}
