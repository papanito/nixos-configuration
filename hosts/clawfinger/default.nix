{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./networking
    ./packages.nix
    ./services
    ./pam.nix
    ./tuxedo.nix
    ./sound.nix
    ./security.nix
    ./users.nix
    ./virtualization.nix
  ];

  services.logind.settings.Login = {
    RuntimeDirectorySize = "32G";
    HandleLidSwitchDocked = "ignore";
  };
  # --- Fix: black screen / hard freeze on suspend when QEMU/KVM VMs are running ---
  # systemd 256+ freezes user sessions before suspending. When KVM VMs are
  # running, the kernel process freezer deadlocks on KVM worker threads -
  # the freeze never completes, suspend hangs, and the display never
  # reinitializes on resume (permanent black screen, requires force-power-off).
  # Disabling user session freezing is the upstream-recommended workaround.
  # See: https://github.com/systemd/systemd/issues/34668 (and Fedora 41's
  # systemd-256.8-1 which disables this by default in KVM contexts).
  systemd.services = builtins.listToAttrs (
    builtins.map
      (name: {
        inherit name;
        value.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
      })
      [ "systemd-suspend" "systemd-hibernate" "systemd-hybrid-sleep" "systemd-suspend-then-hibernate" ]
  );

  # Create a library path that only applies to unpackaged programs by using nix-ld. Add this to your configuration.nix:
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
    ];
  };

  # modules
  modules = {
    security = {
      tools.enable = true;
    };
    container.enable = true;
    ## printing module
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
    solokey.enable = true;
    ## virtualisation module
    virtualisation.enable = true;
    windows-support.enable = true;

    ## pc modules
    dms.enable = false;
    gnome.enable = true;
    kde.enable = false;
    development.enable = true;
    multimedia.enable = true;
    office.enable = true;
  };
}
