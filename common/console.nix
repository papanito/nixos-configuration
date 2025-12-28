{ config, lib, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;

  # 1. Enable Zsh as a system shell
  programs.zsh = {
    enable = true;
    
    # Enable interactive features
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # Default shell aliases
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };

    # Custom configuration for the .zshrc
    interactiveShellInit = ''
      # Add custom zsh logic here
      export EDITOR='vim'
    '';

    # Configure Oh-My-Zsh (Optional but very common)
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "docker" "sudo" ];
      theme = "robbyrussell";
    };
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
