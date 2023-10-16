{ config, pkgs, ... }:

{
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # To add the zsh package to /etc/shells you must update environment.shells.
  environment.shells = with pkgs; [ zsh ];
}
