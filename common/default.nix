{ pkgs, ... }:
{
  imports = [
    ./networking
    ./console.nix
    ./packages.nix
    ./nix.nix
    ./kernel.nix
    ./sops.nix
    ./security
    ./system.nix
    ./systemd.nix
    ./tmpfs.nix
  ];
  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  # silence ACPI "errors" at boot shown before NixOS stage 1 output (default is 4)
  boot = {
    consoleLogLevel = 3;
  };

  security.wrappers = {
    fusermount.source = "${pkgs.fuse}/bin/fusermount";
  };
}
