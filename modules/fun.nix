{ config, pkgs, lib, ... }:

let
   cfg = config.fun;
in
{
  options.fun = {
    enable 
      = lib.mkEnableOption "enable fun stuff not really needed";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      genact # Nonsense activity generator
      nms # A command line tool that recreates the famous data decryption effect seen in the 1992 movie Sneakers
    ];
  };
}
