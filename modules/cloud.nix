{ config, pkgs, lib, ... }:

let
   cfg = config.modules.cloud;
in
{
  options.modules.cloud = {
    enable
      = lib.mkEnableOption "enable cloud backend and tooling";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [

    ];
  };
}
