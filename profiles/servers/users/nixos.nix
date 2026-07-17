{ lib, config, pkgs, nixosVersion, home-manager, sops-nix, ...}:
{
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    # Use the SOPS-derived password when sops is actually wired up;
    # fall back to a known plaintext for first-boot recovery on hosts
    # that were installed without sops age keys on the installer.
    hashedPasswordFile = lib.mkIf
      ((config.sops.secrets ? default_password) &&
       (config.sops.secrets.default_password ? path))
      config.sops.secrets.default_password.path;
    initialPassword = lib.mkIf (!(config.sops.secrets ? default_password)) "nixos";
    # Kill the empty string fallback
    initialHashedPassword = lib.mkForce null;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrOn3Kj/+ztMtQAaq4pVvXgTsIs1ZOqQDbsA+nJMuRM nixos@homelab from clawfinger"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTCwPNpVjW6R9vqpKgNSWgGS5hZMZcHwexAMl7E/OI2 nixos@homelab from clawfinger"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ91S1yRB15KxFHvko7/ZtyUumrD44RZI4HkLpED/iRE paperless-sync-key"
      #''command="sudo rsync --server --daemon -vlogDtpr.",no-agent-forwarding,no-port-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ91S1yRB15KxFHvko7/ZtyUumrD44RZI4HkLpED/iRE  paperless-sync-key''
    ];
  };
}
