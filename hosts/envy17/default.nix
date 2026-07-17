{ pkgs, lib, ... }: {
  imports = [
    ./disko.nix
    ./hardware.nix
    ./users.nix
  ];

  # envy17 was installed via nixos-anywhere without sops age keys on
  # the installer, so sops-nix never decrypted the default_password
  # secret. /run/secrets/default_password is empty at first boot.
  #
  # Password model (matches profiles/servers/users/{nixos,root}.nix):
  #   - Principal: hashedPasswordFile -> /run/secrets/default_password
  #     (sops-managed; empty until sops decrypts, then principal follows
  #     sops rotation automatically on next activation).
  #   - Initial:   "nixos" (fires only when the principal file is empty,
  #     so first-boot login works even without sops).
  #
  # We force-override initialPassword to "nixos" at the host level for
  # clarity, even though the profile already sets it unconditionally.
  # We do NOT force hashedPasswordFile — letting the profile's sops
  # path win means the principal flips to the sops value automatically
  # once sops decrypts, instead of being permanently nulled.
  #
  # NOTE: do not `sops.secrets.default_password = lib.mkForce null` — sops-nix
  # types `sops.secrets.<name>` as a submodule, not nullable, and rejects
  # `null` during eval with "is not of type 'submodule'".
  users.users.nixos = {
    initialPassword = lib.mkForce "nixos";
  };
  users.users.root = {
    initialPassword = lib.mkForce "nixos";
  };
}
