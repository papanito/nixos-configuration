{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./disko.nix
    ./paperless-ngx.nix
    ./fileserver.nix
    ./gitlab-runner.nix
  ];
}
