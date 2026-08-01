{ lib, config, pkgs, inputs, ... }:
{
  # Boot generations: 2 to revert + the current one. SD cards are small;
  # keeping only 3 extlinux entries avoids filling /boot/firmware.
  boot.loader.generic-extlinux-compatible.configurationLimit = lib.mkDefault 3;
  imports = [
    ./networking.nix
    ./users.nix
  ];

  # Disable features that pull in heavy dependencies
  services.pipewire.enable = lib.mkForce false;
  fonts.fontconfig.enable = lib.mkForce false;

  # Disable the X11 library stack globally
  environment.variables.NIXOS_OZONE_WL = "0";
  documentation.nixos.enable = false;
  documentation.enable = false;
  documentation.man.enable = false;
  documentation.doc.enable = false;
  documentation.info.enable = false;
  programs.command-not-found.enable = false;

  # --- Tight retention for SD-card storage ---
  # Journald: cap at 100M and drop entries older than 7 days. The common
  # setting (SystemMaxUse=2G) is far too large for a Pi's SD card.
  services.journald.extraConfig = lib.mkForce ''
    SystemMaxUse=100M
    MaxRetentionSec=7d
  '';

  # Nix GC: keep only the last 7 days of store paths (down from 30d).
  nix.gc.options = lib.mkForce "--delete-older-than 7d";
}
