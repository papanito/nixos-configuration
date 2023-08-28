{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ansible
    ansible-lint
    gh
    act
    actionlint
    bump
    glab
    git
    git-crypt
    go
    openjdk19
    maven
    buildkit
    buildah
    cargo
    nodejs
    jq
    yq
    guake
    tilix
    python3Full
    navi
    terraform
    terragrunt
    vscode
  ];
}
