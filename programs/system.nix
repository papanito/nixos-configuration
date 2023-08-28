{ config, pkgs, ... }:

{
  #linuxKernel.packages.linux_latest_libre.tuxedo-keyboard;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ace
    btrfs-progs
    coreutils
    curl
    exa
    fzf
    parted
    gnupg
    wget
    zsh
    zoxide
  ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # To add the zsh package to /etc/shells you must update environment.shells.
  environment.shells = with pkgs; [ zsh ];
}
