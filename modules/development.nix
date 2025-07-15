{ config, pkgs, lib, ... }:

let
   cfg = config.development;
in
{
  options.development = {
    enable 
      = lib.mkEnableOption "enable development tooling";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bfg-repo-cleaner # removes large or troublesome blobs in a git repository like git-filter-branch does, but faster
      cargo # Downloads your Rust project's dependencies and builds your project
      delta # Syntax-highlighting pager for git
      git # git
      git-crypt
      git-filter-repo # Quickly rewrite git repository history
      git-graph # Command line tool to show clear git graphs arranged for your branching model
      pre-commit-hook-ensure-sops # pre-commit hook to ensure that files that should be encrypted with sops are
      go
      nodejs
      openjdk21
      python3
      pipenv # Python Development Workflow for Humans
    ];
  };
}
