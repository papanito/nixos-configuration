{ config, pkgs, lib, ... }:

let
   cfg = config.cloud;
in
{
  options.cloud = {
    enable 
      = lib.mkEnableOption "enable cloud backend and tooling";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      azure-cli
      python311Packages.msrest
      google-cloud-sdk
      hcloud # A command-line interface for Hetzner Cloud, a provider for cloud virtual private servers1
      python311Packages.hcloud # Library for the Hetzner Cloud API
      ibmcloud-cli # Command line client for IBM Cloud
      terraform
      terragrunt # A thin wrapper for Terraform that supports locking for Terraform state and enforces best practices
      terraform-docs # A utility to generate documentation from Terraform modules in various output formats
      wrangler_1 # A CLI tool designed for folks who are interested in using Cloudflare Workers
    ];
  };
}
