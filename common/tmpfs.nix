{ config, lib, ... }:
with lib;
{
  # tmpfs (a filesystem stored in RAM) settings for the NixOS boot process.
  # NOTE:  boot.tmp can not be nested, must stay as toplevel as they are part of the global system configuration
  boot.tmp ={
    # Clean tmpfs on system boot, useful for ensuring a clean state.
    cleanOnBoot = true;

    # Enable tmpfs for the specified directories.
    useTmpfs = true;

    # NEW: set to auto to dynamically grow
    #boot.tmp.tmpfsSize = "25%";
  };
}
