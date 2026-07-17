{ pkgs, lib, ... }: {
  imports = [
    ./disko.nix
    ./hardware.nix
    ./users.nix
  ];

  # envy17 was installed via nixos-anywhere without sops age keys on
  # the installer, so the sops-nix activation never decrypted the
  # default_password secret. Force the fallback path so first-boot
  # login with the plaintext 'nixos' works; the user will `passwd`
  # over it after login and re-add the sops wiring if desired.
  sops.secrets.default_password = lib.mkForce null;
  users.users.nixos = {
    hashedPasswordFile = lib.mkForce null;
    initialPassword = lib.mkForce "nixos";
  };
  users.users.root = {
    hashedPasswordFile = lib.mkForce null;
    initialPassword = lib.mkForce "nixos";
  };
}
