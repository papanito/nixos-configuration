{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    azure-cli
    insync
    google-cloud-sdk
    hcloud # A command-line interface for Hetzner Cloud, a provider for cloud virtual private servers1
    python311Packages.hcloud # Library for the Hetzner Cloud API
  ];
}

