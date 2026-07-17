{ lib, config, pkgs, sops-nix, ...}:
{  # allow nix-copy to live system
  users.users.root = {
    openssh.authorizedKeys.keys = lib.mkForce [ ];
    # Principal (ongoing) password: read from the sops-decrypted file when
    # sops is wired up. See profiles/servers/users/nixos.nix for the full
    # rationale on the dual password model.
    hashedPasswordFile = lib.mkIf
      ((config.sops.secrets ? default_password) &&
       (config.sops.secrets.default_password ? path))
      config.sops.secrets.default_password.path;
    initialPassword = "nixos";
    # Prevent nixpkgs from setting a placeholder hash that would override
    # both `hashedPasswordFile` and `initialPassword`.
    initialHashedPassword = lib.mkForce null;
  };
}
