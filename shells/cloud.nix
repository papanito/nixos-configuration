{ pkgs ? (import <nixpkgs> { 
 config.allowUnfree = true;
}), ... }:

pkgs.mkShell
{
  nativeBuildInputs = with pkgs; [
    azure-cli
    python312Packages.msrest
    google-cloud-sdk
    hcloud # A command-line interface for Hetzner Cloud, a provider for cloud virtual private servers1
    python312Packages.hcloud # Library for the Hetzner Cloud API
    terragrunt # A thin wrapper for Terraform that supports locking for Terraform state and enforces best practices
    terraform-docs # A utility to generate documentation from Terraform modules in various output formats
    wrangler_1 # A CLI tool designed for folks who are interested in using Cloudflare Workers
  ];

  shellHook = ''
    zsh
  '';
}