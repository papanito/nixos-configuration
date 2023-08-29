{ config, pkgs, ... }:

{
  imports =
    [
       ./cloud.nix
       ./generic.nix
       ./development.nix
       ./pentesting.nix
       ./multimedia.nix
       ./system.nix
       ./tuxedo.nix
       ./virt.nix
    ];
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
