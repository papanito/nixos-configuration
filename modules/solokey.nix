{ lib, config, pkgs, ... }:

let
   cfg = config.modules.solokey;
in
{
  options.modules.solokey = {
    enable
      = lib.mkEnableOption "enable pam using solokey";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
     solo2-cli
     pam_u2f
     libfido2
    ];

    security.pam = {
      services.polkit-1 = {
        # This adds FIDO2 as an authentication method for Polkit prompts
        # 'cue' provides a terminal message to touch the key
        rules.auth.fido2 = {
          enable = true;
          order = 10; # Usually want this before pam_unix for 'key-first' auth
          # Set the control flag (this fixes the error)
          control = "sufficient";
          # Use 'module' (not 'modulePath') and point to the .so
          modulePath = "${pkgs.pam_u2f}/lib/security/pam_u2f.so";
          settings = {
            cue = true;
            authfile = "/etc/security/fido2_keys"; # Ensure your key is enrolled here
          };
        };
      };

      # Enable the pam_u2f module globally
      u2f = {
        enable = true;
        # "sufficient" means if u2f auth succeeds, PAM chain stops. If it fails or is not used, PAM continues.
        control = "sufficient";
        # # Point to the generated u2f_keys file.
        # # We use pkgs.writeText so the file is managed by Nix and available for all users.
        # # Make sure to replace <your_username> and the content with your actual generated key data.
        # authFile = pkgs.writeText "u2f_keys" ''
        #   yourusername:keyHandle,userKey,coseType,options # Replace with content from ~/.config/Yubico/u2f_keys
        #   # Add more lines if you have multiple users or keys
        # '';
      };

      services = {
        login.u2fAuth = true;
        sudo.u2fAuth = true;
        sddm.u2fAuth = true;
        pcscd.enable = true;
      };
    };

    # https://github.com/solokeys/solo2-cli/blob/main/70-solo2.rules
    services.udev.packages = [
      pkgs.libfido2
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

    services.udev.extraRules = ''
        ACTION=="remove",\
        ENV{ID_BUS}=="usb",\
        ENV{ID_MODEL_ID}=="0407",\
        ENV{ID_VENDOR_ID}=="1050",\
        ENV{ID_VENDOR}=="Yubico",\
        RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
    '';
  };
}

# The pam module comes with a configration tool that can be used to create the keys-strings in the configration for your SoloKeys. Simply plugin your solokey into the USB port and then in a terminal run the following command:
#
# pamu2fcfg > ~/.config/Yubico/u2f_keys
# pamu2fcfg -n >> ~/.config/Yubico/u2f_keys
#
# Testing:
# nix-shell -p pamtester
# pamtester login <username> authenticate
# pamtester sudo <username> authenticate
