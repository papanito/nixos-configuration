{ pkgs, ... }: {
  imports = [
    ./networking
    ./tmpfs.nix
    ./system.nix
    ./console.nix
    ./sops.nix
  ];
}
