{ config, pkgs, lib, ... }:

let
   cfg = config.container;
in
{
  options.container = {
    enable 
      = lib.mkEnableOption "enable container backend and tooling";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      podman
      podman-desktop # A graphical tool for developing on containers and Kubernetes
      pods # A podman desktop application
      podman-tui
      podman-compose
      runc # A CLI tool for spawning and running containers according to the OCI specification
      containerd # A daemon to control runC
      gnomeExtensions.containers
      argocd
      kind
      k3s # lightweight Kubernetes distribution
      k9s
      slirp4netns # User-mode networking for unprivileged network namespaces
      kubectl
      google-cloud-sdk
      kubernetes-helm
      nova # Find outdated or deprecated Helm charts running in your cluster
    ];

    systemd.services."user@".serviceConfig = {
      Delegate = "cpu cpuset io memory pids";
    };

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
        defaultNetwork.settings.dns_enabled = true;
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
  };
}
