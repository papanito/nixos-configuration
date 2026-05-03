{ pkgs, ... }:
{
  imports = [
    ./networking
    ./console.nix
    ./packages.nix
    ./nix.nix
    ./kernel.nix
    ./sops.nix
    ./system.nix
    ./systemd.nix
    ./tmpfs.nix
  ];
  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  security.wrappers = {
    fusermount.source = "${pkgs.fuse}/bin/fusermount";
  };
}
