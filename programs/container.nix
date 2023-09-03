{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    insync
    kind
    kubectl
    google-cloud-sdk
    kubernetes-helm
    podman
    podman-desktop
    podman-compose
    runc # A CLI tool for spawning and running containers according to the OCI specification
    containerd # A daemon to control runC
    gnomeExtensions.containers
    wrangler_1
    nova # Find outdated or deprecated Helm charts running in your cluster
  ];

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };

    oci-containers = {
     backend = "podman";
    #  containers = {
    #    container-name = {
    #      image = "container-image";
    #      autoStart = true;
    #      ports = [ "127.0.0.1:1234:1234" ];
    #    };
    #  };
    };
  };
}

