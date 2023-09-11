{ config, pkgs, ... }:

{
  # see also ../services/container-nix
  environment.systemPackages = with pkgs; [
    kind
    kubectl
    google-cloud-sdk
    kubernetes-helm
    wrangler_1
    nova # Find outdated or deprecated Helm charts running in your cluster
  ];
}

