{ pkgs, ... }:
{
  imports = [
    ./networking
    ./console.nix
    ./packages.nix
    ./sops.nix
    ./system.nix
    ./tmpfs.nix
  ];
  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  security.wrappers = {
    fusermount.source = "${pkgs.fuse}/bin/fusermount";
  };
}
