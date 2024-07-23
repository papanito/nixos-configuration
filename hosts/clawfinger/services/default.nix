{ config, pkgs, ... }:
{
  imports = [
    ./restic.nix
    ./paperless-ngx.nix
    #./notifications.nix
  ];
}
