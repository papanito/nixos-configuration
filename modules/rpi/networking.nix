{ lib, config, pkgs, ... }:
{
  imports = [
    ../modules/nice-looking-console.nix
        users-config-stub
          network-config
  ];
        # Use less privileged nixos user
        users.users.nixos = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "networkmanager"
            "video"
          ];
          # Allow the graphical user to login without password
          initialHashedPassword = "";

        # Allow the user to log in as root without a password.
        users.users.root.initialHashedPassword = "";

        # Don't require sudo/root to `reboot` or `poweroff`.
        security.polkit.enable = true;

        # Allow passwordless sudo from nixos user
        security.sudo = {
          enable = true;
          wheelNeedsPassword = false;
        };

        # Automatically log in at the virtual consoles.
        services.getty.autologinUser = "nixos";

        # We run sshd by default. Login is only possible after adding a
        # password via "passwd" or by adding a ssh key to ~/.ssh/authorized_keys.
        # The latter one is particular useful if keys are manually added to
        # installation device for head-less systems i.e. arm boards by manually
        # mounting the storage in a different system.
        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };

        # allow nix-copy to live system
        nix.settings.trusted-users = [ "nixos" ];

        # We are stateless, so just default to latest.
        system.stateVersion = config.system.nixos.release;

        # This is mostly portions of safe network configuration defaults that
        # nixos-images and srvos provide
        networking.useNetworkd = true;
        # mdns
        networking.firewall.allowedUDPPorts = [ 5353 ];
        systemd.network.networks = {
          "99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
          "99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
        };

        # This comment was lifted from `srvos`
        # Do not take down the network for too long when upgrading,
        # This also prevents failures of services that are restarted instead of stopped.
        # It will use `systemctl restart` rather than stopping it with `systemctl stop`
        # followed by a delayed `systemctl start`.
        systemd.services = {
          systemd-networkd.stopIfChanged = false;
          # Services that are only restarted might be not able to resolve when resolved is stopped before
          systemd-resolved.stopIfChanged = false;
        };

        # Use iwd instead of wpa_supplicant. It has a user friendly CLI
        networking.wireless.enable = false;
        networking.wireless.iwd = {
          enable = true;
          settings = {
            Network = {
              EnableIPv6 = true;
              RoutePriorityOffset = 300;
            };
            Settings.AutoConnect = true;
          };
        };

        imports = [
        ];

        time.timeZone = "UTC";
        networking.hostName = "rpi${config.boot.loader.raspberryPi.variant}-demo";

        services.udev.extraRules = ''
          # Ignore partitions with "Required Partition" GPT partition attribute
          # On our RPis this is firmware (/boot/firmware) partition
          ENV{ID_PART_ENTRY_SCHEME}=="gpt", \
            ENV{ID_PART_ENTRY_FLAGS}=="0x1", \
            ENV{UDISKS_IGNORE}="1"
        '';

        environment.systemPackages = with pkgs; [
          tree
        ];

        users.users.nixos.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrOn3Kj/+ztMtQAaq4pVvXgTsIs1ZOqQDbsA+nJMuRM admin@envy from clawfinger"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTCwPNpVjW6R9vqpKgNSWgGS5hZMZcHwexAMl7E/OI2 admin@envy from clawfinger"
        ];

        users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrOn3Kj/+ztMtQAaq4pVvXgTsIs1ZOqQDbsA+nJMuRM admin@envy from clawfinger"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTCwPNpVjW6R9vqpKgNSWgGS5hZMZcHwexAMl7E/OI2 admin@envy from clawfinger"
        ];
        system.nixos.tags = let
          cfg = config.boot.loader.raspberryPi;
        in [
          "raspberry-pi-${cfg.variant}"
          cfg.bootloader
          config.boot.kernelPackages.kernel.version
        ];
      };
}
