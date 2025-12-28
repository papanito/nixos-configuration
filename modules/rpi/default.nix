{ lib, config, pkgs, ... }:
let
  isArm = pkgs.stdenv.hostPlatform.isAarch64;
in
{
  imports = lib.optional isArm [
    ./networking.nix
    ./users.nix
  ];

  environment.systemPackages = lib.optionals isArm (
    with pkgs; [
      tree
    ]
  );
}
