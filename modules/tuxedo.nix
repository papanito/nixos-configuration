{ pkgs, config, kernel, ... }:
let my-tuxedo-keyboard = config.boot.kernelPackages.tuxedo-keyboard.overrideAttrs (old: {
      src = "../pkgs/tuxedo-keyboard.nix";
    });
in {
  config.boot.kernelPackages.tuxedo-keyboard.package = my-tuxedo-keyboard; 
}