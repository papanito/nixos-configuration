{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    #./cloudflare.nix
    ./dns.nix
    ./firejail.nix
    ./tor.nix
    ./vpn.nix
  ];
  networking = {
    interfaces.wlo1.mtu = 1492;
  };

  # Disable USB Autosuspend
  # USB power management often causes "flapping" and drops on USB Ethernet adapters.
  # This disables it globally for all USB devices.
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  environment.systemPackages = with pkgs; [
    ethtool
  ];

  # This runs every time the ethernet connects, forcing GRO off AFTER NetworkManager is done.
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeText "force-offload-off" ''
        INTERFACE=$1
        ACTION=$2
        if [ "$INTERFACE" = "enp0s20f0u1u2i5" ] && [ "$ACTION" = "up" ]; then
          ${pkgs.ethtool}/bin/ethtool -K $INTERFACE tso off gso off gro off
        fi
      '';
      type = "basic";
    }
  ];

  # Fix cdc_ncm performance via udev
  # Many USB NICs have buggy implementations of Segmentation Offloading (TSO/GSO).
  # Disabling these forces the CPU to handle the packet slicing, which is much
  # more stable for the cdc_ncm driver and usually restores full speed.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", DRIVERS=="cdc_ncm", RUN+="${pkgs.ethtool}/bin/ethtool -K %k tso off gso off gro off"
  '';

  # 3. Force NetworkManager Auto-Negotiation
  # Your current 'nmcli' report showed auto-negotiate as "no".
  # This forces it back on globally for all ethernet connections.
  networking.networkmanager.settings = {
    connection = {
      "ethernet.auto-negotiate" = true;
    };
  };

  services.opensnitch.enable = true;
}
