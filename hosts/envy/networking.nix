{ config, pkgs, ... }:
{
  networking = {
    hostName = "envy"; # Define your hostname

    interfaces = {
      enp0s20f0u5.ipv4.addresses = [{
        address = "10.0.0.11";
        prefixLength = 16;
      }];
    };
  };
}
