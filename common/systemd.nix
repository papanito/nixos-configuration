
{ config, pkgs, version, ... }:
{
  services.journald.extraConfig = ''
    SystemMaxUse=2G
  '';
  systemd.coredump.enable = false;
}
