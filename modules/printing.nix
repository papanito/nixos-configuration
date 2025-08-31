{ lib, config, pkgs, ... }:

let
   cfg = config.printing;
in
{
  options.printing = {
    enable 
      = lib.mkEnableOption "enable printing module";

    drivers = lib.mkOption {
      default = [];
      description = ''
        List of printing drivers
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable CUPS to print documents.
    services.printing.enable = true;
    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;

    # for a WiFi printer
    services.avahi.openFirewall = true;
    services.printing.drivers = cfg.drivers;
    environment.systemPackages = with pkgs; [
      hplip
    ];
  };
}
