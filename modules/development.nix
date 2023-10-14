{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ansible
    ansible-lint
    anytype # P2P note-taking tool
    obsidian # A powerful knowledge base that works on top of a local folder of plain text Markdown files
    gh # github cli
    act # Run your GitHub Actions locally
    actionlint # Static checker for GitHub Actions workflow files
    bump # CLI tool to draft a GitHub Release for the next semantic version
    doppler # The official CLI for interacting with your Doppler Enclave secrets and configuration
    glab # gitlab cli
    git
    git-crypt
    go
    openjdk19
    maven
    buildkit # Concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit
    buildkit-nix #Nix frontend for BuildKit
    buildkite-cli # A command line interface for Buildkite
    buildah # A tool which facilitates building OCI images
    wrangler_1 # A CLI tool designed for folks who are interested in using Cloudflare Workers
    cargo # Downloads your Rust project's dependencies and builds your project
    nodejs
    jq 
    yq # Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML documents
    hurl #Command line tool that performs HTTP requests defined in a simple plain text format.
    python3Full
    python311Packages.bootstrapped-pip
    python311Packages.pip
    navi # An interactive cheatsheet tool for the command-line and application launchers
    terraform
    terragrunt # A thin wrapper for Terraform that supports locking for Terraform state and enforces best practices
    terraform-docs # A utility to generate documentation from Terraform modules in various output formats
    vscode # Open source source code editor developed by Microsoft for Windows, Linux and macOS 
    vscodium # Open source source code editor developed by Microsoft for Windows, Linux and macOS (VS Code without MS branding/telemetry/licensing) 
    lazygit # Simple terminal UI for git commands
    shellcheck # Shell script analysis tool
    nodePackages.zx # A tool for writing better scripts.
    nodePackages.snyk # snyk library and cli utility
    insomnia # The most intuitive cross-platform REST API Client
    just # A handy way to save and run project-specific commands
  ];
}
