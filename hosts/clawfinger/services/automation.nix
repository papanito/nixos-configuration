{ config, pkgs, ... }:
{
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeText "wifi-toggle" ''
        USER="papanito"

        case "$2" in
          up)
            if nmcli device status | grep -q "ethernet.*connected"; then
              nmcli radio wifi off
              sudo -u $USER DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $USER)/bus notify-send "Network" "Wired connection detected. Disabling Wi-Fi."
            fi
            ;;
          down)
            if ! nmcli device status | grep -q "ethernet.*connected"; then
              nmcli radio wifi on
              sudo -u $USER DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $USER)/bus notify-send "Network" "Ethernet disconnected. Enabling Wi-Fi."
            fi
            ;;
        esac
      '';
      type = "basic";
    }
  ];
}
