{ lib, config, pkgs, ... }:

let
   cfg = config.solokey;
in
{
  options.solokey = {
    enable 
      = lib.mkEnableOption "enable pam using solokey";
  };

  config = lib.mkIf cfg.enable {
    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };

    # https://github.com/solokeys/solo2-cli/blob/main/70-solo2.rules
    services.udev.packages = [
      pkgs.yubikey-personalization
      (pkgs.writeTextFile {
        name = "wally_udev";
        text = ''
          # NXP LPC55 ROM bootloader (unmodified)
          SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="0021", TAG+="uaccess"
          # NXP LPC55 ROM bootloader (with Solo 2 VID:PID)
          SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="b000", TAG+="uaccess"
          # Solo 2
          SUBSYSTEM=="tty", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="beee", TAG+="uaccess"
          # Solo 2
          SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="beee", TAG+="uaccess"
        '';
        destination = "/etc/udev/rules.d/70-solo2.rules";
      })
    ];

    environment.systemPackages = with pkgs; [
     solo2-cli
    ];
  };
}
