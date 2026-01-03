{ config, lib, pkgs, ... }:
let
  myZshConfig = import ./zsh-config.nix { inherit pkgs; };
in {
  users.defaultUserShell = pkgs.zsh;

  # Enable Zsh as a system shell
  #programs.zsh = myZshConfig;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = myZshConfig.oh-my-zsh;
  };

  # To add the zsh package to /etc/shells you must update environment.shells.
  environment.shells = with pkgs; [ zsh ];

  # The following have been borrowed from:
  # https://github.com/nix-community/nixos-images/blob/b733f0680a42cc01d6ad53896fb5ca40a66d5e79/nix/image-installer/module.nix#L84

  console= {
    earlySetup = true;
    # ter-u22n is probably too big
    font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u16n.psf.gz";
    keyMap = "sg";

    # Make colored console output more readable
    # for example, `ip addr`s (blues are too dark by default)
    # Tango theme: https://yayachiken.net/en/posts/tango-colors-in-terminal/
    colors = lib.mkDefault [
    "000000"
    "CC0000"
    "4E9A06"
    "C4A000"
    "3465A4"
    "75507B"
    "06989A"
    "D3D7CF"
    "555753"
    "EF2929"
    "8AE234"
    "FCE94F"
    "739FCF"
    "AD7FA8"
    "34E2E2"
    "EEEEEC"
    ];
  };
}
