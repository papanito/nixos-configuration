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
      act # Run your GitHub Actions locally
      actionlint # Static checker for GitHub Actions workflow files
      bump # CLI tool to draft a GitHub Release for the next semantic version
      ansible
      ansible-lint
      # anytype # P2P note-taking tool
      bruno # Open-source IDE For exploring and testing APIs
      buildkit # Concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit
      buildkit-nix #Nix frontend for BuildKit
      buildkite-cli # A command line interface for Buildkite
      buildah # A tool which facilitates building OCI images
      cargo # Downloads your Rust project's dependencies and builds your project
      #doppler # The official CLI for interacting with your Doppler Enclave secrets and configuration
      findutils # GNU Find Utilities, the basic directory searching utilities of the GNU operating system
      gh # github cli
      glab # gitlab cli
      git # git
      git-crypt
      git-filter-repo # Quickly rewrite git repository history
      git-graph # Command line tool to show clear git graphs arranged for your branching model
      gitleaks # Scan git repos (or files) for secrets
      pre-commit-hook-ensure-sops # pre-commit hook to ensure that files that should be encrypted with sops are
      lazygit # Simple terminal UI for git commands
      go
      hurl #Command line tool that performs HTTP requests defined in a simple plain text format.
      insomnia # The most intuitive cross-platform REST API Client
      maven
      nodejs
      nodePackages.zx # A tool for writing better scripts.
      nodePackages.snyk # snyk library and cli utility
      obsidian # A powerful knowledge base that works on top of a local folder of plain text Markdown files
      openjdk21
      poppler # A PDF rendering library
      poppler_utils # A PDF rendering library
      python3
      (pkgs.python3.withPackages my-python-packages)
      pipenv # Python Development Workflow for Humans
      shellcheck # Shell script analysis tool
      just # A handy way to save and run project-specific commands
      vscode # Open source source code editor developed by Microsoft for Windows, Linux and macOS 
      vscodium # Open source source code editor developed by Microsoft for Windows, Linux and macOS (VS Code without MS branding/telemetry/licensing) 
    ];
  };
}
