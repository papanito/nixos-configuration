{ config, pkgs, version, ... }:
{
  services.journald.extraConfig = ''
    SystemMaxUse=2G
  '';

  # Do not disable systemd-coredump: with it off, kernel.core_pattern falls
  # back to the literal `core`, so every crash drops an uncapped core.<pid>
  # into the crashing process's CWD (that is how ~19k cores / 21 GB piled up
  # in $HOME, the repo, and a stopped podman container's overlay layer).
  # Keep dumps, but bounded and in one place, so `coredumpctl` still works.
  systemd.coredump = {
    enable = true;
    settings.Coredump = {
      Storage = "external";
      Compress = "yes";
      ProcessSizeMax = "2G";
      MaxUse = "5G";
      KeepFree = "1G";
    };
  };
}
