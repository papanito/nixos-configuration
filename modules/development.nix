{ config, pkgs, lib, ... }:

let
   cfg = config.development;
   my-python-packages = ps: with ps; [
    pandas
    requests
    pip # The PyPA recommended tool for installing Python packages
    django
    pillow # The friendly PIL fork (Python Imaging Library)
    jupyter # A high-level dynamically-typed programming language
    notebook # Web-based notebook environment for interactive computing
  ];
in
{
  options.development = {
    enable 
      = lib.mkEnableOption "enable development tooling";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (pkgs.python3.withPackages my-python-packages)
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
      nodePackages.zx # A tool for writing better scripts.
      nodePackages.snyk # snyk library and cli utility
      # obsidian # A powerful knowledge base that works on top of a local folder of plain text Markdown files
      openjdk21
      python3
      pipenv # Python Development Workflow for Humans
    ];
  };
}
