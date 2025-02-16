#
# Contains modules for configuring systems.
#
{ pkgs, ... }: {
  imports = [
    ./networking
    ./tmpfs.nix
    ./system.nix
  ];
}
