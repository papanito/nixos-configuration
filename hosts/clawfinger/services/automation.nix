{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    libnotify # For the notify-send command
  ];

  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeText "wifi-toggle" ''
        NM="${pkgs.networkmanager}/bin/nmcli"
        NOTIFY="${pkgs.libnotify}/bin/notify-send"
        USER="papanito"
        USER_ID=$(id -u $USER)
        export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USER_ID/bus

        # Debugging: Log every time this script is triggered to 'journalctl -u NetworkManager'
        echo "Wifi-toggle triggered: Interface=$1 Action=$2"

        # Check for ANY ethernet connection being active
        if $NM device status | grep -q "ethernet.*connected"; then
            # LAN is plugged in
            if [ "$($NM radio wifi)" = "enabled" ]; then
                $NM radio wifi off
                sudo -u $USER DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS $NOTIFY -i network-wireless-disconnected "Network" "Wired connection detected. Wi-Fi disabled."
            fi
        else
            # LAN is unplugged
            if [ "$($NM radio wifi)" = "disabled" ]; then
                $NM radio wifi on
                sudo -u $USER DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS $NOTIFY -i network-wireless-connected "Network" "Ethernet disconnected. Wi-Fi enabled."
            fi
        fi
      '';
      type = "basic";
    }
  ];
}
