{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # protonvpn-gui
    # protonvpn-cli
  ];
}

