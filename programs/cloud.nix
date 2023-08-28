{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    azure-cli
    insync
    kind
    kubectl
    google-cloud-sdk
    kubernetes-helm
    podman
    podman-desktop
    podman-compose
    gnomeExtensions.containers
    cloudflared
    cloudflare-warp
    gnomeExtensions.cloudflare
    wrangler_1
  ];

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      # For Nixos version > 22.11
      #defaultNetwork.settings = {
      #  dns_enabled = true;
      #};
    };
    #oci-containers = {
    #  backend = "podman";
    #  containers = {
    #    container-name = {
    #      image = "container-image";
    #      autoStart = true;
    #      ports = [ "127.0.0.1:1234:1234" ];
    #    };
    #  };
    #};
  };
}

