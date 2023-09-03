{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ansible
    ansible-lint
    gh # github cli
    act # Run your GitHub Actions locally
    actionlint # Static checker for GitHub Actions workflow files
    bump # CLI tool to draft a GitHub Release for the next semantic version
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
    wrangler_1
    cargo
    nodejs
    jq
    yq
    hurl #Command line tool that performs HTTP requests defined in a simple plain text format.
    python3Full
    navi
    terraform
    terragrunt
    vscode
    lazygit # Simple terminal UI for git commands
    shellcheck # Shell script analysis tool
    nodePackages.zx # A tool for writing better scripts.
    insomnia # The most intuitive cross-platform REST API Client
    just # A handy way to save and run project-specific commands
  ];
}
