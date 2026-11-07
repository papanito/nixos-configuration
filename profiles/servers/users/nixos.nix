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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1xc6vhq7JCOt9MadtqOzLFQo6ZrtxML1qGFcq6uHnso8e1S4YLQxGIHlOZG9QOkuu2500ZDU405NXsRjHHHfA9/DvKe3rpKQEhiWfM6js4F+Co0UHV7h6f3WmdeT4x6D7CmED4NYv7i2kw0DQtyp8G07Xnnwe/hTgpmJEe4FeGcgYAj61NGc/xh+Juef7sImuhG5htm4Fw0sY01EicPuSz5f2fSHLVJtmaKQxKtIs/fuBQVRfrovkp/MfVLz2fUpGR7U+FY+tSLsmb5fFRbcQoqOicMcrlSOT06stMyPgcTaI9Dj37wPmHloG3alFLnE5WZDVQjG8ld/vYcB0toPUx8iJ9KEWd+4nOO8zuNMboVrl08cDwFCIL274Yo2DP8Geo0SVLxvpb/0hqv5tdl4bGjTdwHBvhhQx1BbBW5AUnm0XEkrCdoUDs9JFphdkuUrMO6kihrZHGchNurCxY+nAKogmeVO2KU4zMPvv5i1aH4ZvqAUad7KxkgmiWD7NbPTpAU/7fcL7vhgdYl400DLImKUUbELSf0lcAT2Rt4/zXE4FjWpGaOW1OPL9lAaH3AcqeyfNGtIxUT1TkSNas5hqvCdqtybnuX14epW4I6OacLCSrNo2Z6Teio4krIOsx9l4zckZQAYGCZeGyYJJ/pPVEAN0lqPHGvpinSQ/KAEx8w== ci-deploy@nixos-configuration"
      #''command="sudo rsync --server --daemon -vlogDtpr.",no-agent-forwarding,no-port-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ91S1yRB15KxFHvko7/ZtyUumrD44RZI4HkLpED/iRE  paperless-sync-key''
    ];
  };
}
