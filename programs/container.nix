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
    #podman
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

      autoPrune = {
        enable = true; # Periodically prune Podman Images not in use.
        dates = "weekly";
        flags = [ "--all" ];
      };

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };

    oci-containers = {
      backend = "podman";
       containers = {
         web-check = {
           image = "lissy93/web-check";
           autoStart = true;
           ports = [ "127.0.0.1:8888:3000" ];
         };
      };
    };
  };

  networking = {
    firewall.trustedInterfaces = [ "podman0" ];
    #firewall.interfaces.podman0.allowedTCPPorts = [ 8888 ];
    firewall.interfaces.podman0.allowedUDPPorts = [ 53 ];
    firewall.allowedUDPPorts = [
      53 # DNS
      5353 # Multicast
    ];
  };
}

