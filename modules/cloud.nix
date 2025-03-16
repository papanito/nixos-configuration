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
      goofys # A high-performance, POSIX-ish Amazon S3 file system written in Go
      hcloud # A command-line interface for Hetzner Cloud, a provider for cloud virtual private servers1
      ibmcloud-cli # Command line client for IBM Cloud
      python311Packages.hcloud # Library for the Hetzner Cloud API
      terraform
      #terragrunt # A thin wrapper for Terraform that supports locking for Terraform state and enforces best practices
      terraform-docs # A utility to generate documentation from Terraform modules in various output formats
      tflint
      wrangler_1 # A CLI tool designed for folks who are interested in using Cloudflare Workers
    ];
  };
}
