{ pkgs, lib, ... }: {
  imports = [
    ./hardware.nix
    ./disko.nix
    ./paperless-ngx.nix
    ./fileserver.nix
    ./gitlab-runner.nix
  ];

  # dbus-broker 37 (nixpkgs bump 2026-11-18) cannot be reloaded on this host:
  # activation calls `systemctl reload dbus-broker` and it exits 4
  # ("Failed to reload dbus-broker.service"), which aborts
  # switch-to-configuration and fails deploy:x86. Restart the daemon when its
  # unit changes instead of reloading it. mkForce: dbus.nix sets it to true.
  systemd.services.dbus-broker.reloadIfChanged = lib.mkForce false;
}
