{ config, pkgs, lib, ... }:

let
   cfg = config.cloud;
in
{
  options.cloud = {
    enable 
      = lib.mkEnableOption "enable cloud backend and tooling";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [

    ];
  };
}
