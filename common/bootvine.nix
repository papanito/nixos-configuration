{ ... }:
{
  # Imported conditionally from flake.nix for non-RPi hosts, together with
  # bootvine.nixosModules.default. The module is left out of the RPi
  # evaluation, so the option does not exist there.
  services.bootvine.enable = true;
}
