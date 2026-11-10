{ config, lib, pkgs, ... }:

{
  sops = {
    secrets.gitlab_runner_token = {
      sopsFile = ./secrets.yaml;
      # GitLab runner runs as the "gitlab-runner" user
      #owner = "gitlab-runner";
      key = "gitlab_runner_token";
      owner = "gitlab-runner";
      # Ensure the file is NOT executable so the shell won't try to run it
      mode = "0400";
    };

    # Authentication token for the project-scoped shell runner used by the
    # nixos-configuration pipeline (tag: nixos-deploy, untagged: false).
    # The token is created in GitLab under Settings > CI/CD > Runners and
    # stored in secrets.yaml as `gitlab_runner_nixos_token`.
    secrets.gitlab_runner_nixos_token = {
      sopsFile = ./secrets.yaml;
      key = "gitlab_runner_nixos_token";
    };

    # Authentication token for the existing local-builder runner.
    templates."gitlab-runner-env".content = ''
      CI_SERVER_URL="https://gitlab.com";
      CI_SERVER_TOKEN="${config.sops.placeholder.gitlab_runner_token}"
    '';

    # Authentication token for the nixos-configuration project runner.
    templates."gitlab-runner-nixos-env".content = ''
      CI_SERVER_URL="https://gitlab.com";
      CI_SERVER_TOKEN="${config.sops.placeholder.gitlab_runner_nixos_token}"
    '';

    # Authentication token for the homelab group runner (wyssmann/projects,
    # tag: homelab). Separate from the project runner tokens above so the
    # group registration can be rotated independently.
    secrets.gitlab_runner_group_token = {
      sopsFile = ./secrets.yaml;
      key = "gitlab_runner_group_token";
    };

    templates."gitlab-runner-group-env".content = ''
      CI_SERVER_URL="https://gitlab.com";
      CI_SERVER_TOKEN="${config.sops.placeholder.gitlab_runner_group_token}"
    '';

    # Secret containing Docker Hub authentication details (optional, but prevents rate limits)
    secrets.docker_hub_auth = {
      sopsFile = ./secrets.yaml;
      key = "docker_hub_auth";
      owner = "gitlab-runner";
      group = "gitlab-runner";
    };
  };
  users.users.gitlab-runner = {
    isSystemUser = true;
    group = "gitlab-runner";
    description = "Service account for gitlab-runner";
    # Prevents interactive login
    shell = pkgs.shadow;
    # If the serv ftice needs a home directory for config/state
    createHome = true;

    extraGroups = [ "docker" ];
    home = "/var/lib/gitlab-runner";
  };
  users.groups.gitlab-runner = { };

  # Enable Docker (required for the Docker executor)
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    buildkit # BuildKit for advanced Docker builds (DOCKER_BUILDKIT=1)
    docker-buildx # Docker CLI plugin for BuildKit (docker buildx)

    # The shell executor runs jobs through a login shell, which resets PATH
    # to /run/current-system/sw/bin. These must therefore be in the system
    # profile, not only in services.gitlab-runner.extraPackages.
    colmena
    curl
    git
    jq
    nix
    openssh
  ];

  # The shell executor sets client-side Nix config (the flake's nixConfig
  # and NIX_CONFIG). Without trusted status, Nix ignores restricted settings
  # such as extra-platforms and prints "not a trusted user" warnings.
  nix.settings.trusted-users = lib.mkAfter [ "gitlab-runner" ];

  # rpi4-a is aarch64: the CI shell runner cross-builds its closure locally on
  # this x86_64 host, so binfmt/QEMU has to be available here.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];

  # The GitLab Runner service file changes on every nixpkgs bump (ExecStart
  # points into the new nixpkgs). Without this, deploying envy17 from a job
  # running on envy17 would stop/restart the runner underneath the job and
  # kill the pipeline mid-activation. A unit change now requires a manual
  # `systemctl restart gitlab-runner` (or a reboot) to take effect.
  systemd.services.gitlab-runner = {
    restartIfChanged = false;
    stopIfChanged = false;
  };

  # Configure the GitLab Runner service
  services.gitlab-runner = {
    enable = true;

    # Three runner services: local-builder (1), nixos-deploy (2) and
    # homelab-group (1). Keep the global limit at their sum so no runner
    # starves on long-polling.
    settings.concurrent = 4;

    # Packages placed on the PATH of shell-executor jobs. The module already
    # provides bash/coreutils; Nix, Git, SSH and Colmena are needed by the
    # nixos-configuration pipeline.
    extraPackages = with pkgs; [
      colmena
      curl
      git
      nix
      openssh
    ];

    services = {
      # You can name this anything (e.g., "my-local-runner")
      local-builder = {
        # Get your token from GitLab: Settings > CI/CD > Runners > New project runner
        #authenticationTokenConfigFile = "${config.sops.secrets.gitlab_runner_token.path}";
        #registrationConfigFile = config.sops.templates."gitlab-runner-env".path;
        authenticationTokenConfigFile = config.sops.templates."gitlab-runner-env".path;

        executor = "docker";
        dockerImage = "golang:1.25-bookworm"; # Default image if not specified in YAML

        # Tags are configured in GitLab when the runner is created; tagList
        # with an authentication token has no effect and only warns.

        # Optional: speed up builds by allowing the runner to use host's CPU cores
        registrationFlags = [
          "--docker-network-mode=host"
        ];
        # Keep docker jobs from consuming both runner slots.
        requestConcurrency = 1;

        # 1. Fallback to local image cache if upstream registry throws 50x / rate limit
        dockerPullPolicy = "if-not-present";
        # Bind host Docker socket into the CI job containers
        dockerVolumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];

        # Override DOCKER_HOST to prevent jobs from trying to tcp://docker:2375
        environmentVariables = {
          DOCKER_HOST = "unix:///var/run/docker.sock";
        };
      };

      # Shell executor for the nixos-configuration flake update + Colmena
      # deploy pipeline. Runs directly on this host, so it shares the local
      # Nix store (incremental builds, no per-job closure downloads) and can
      # reach the other homelab hosts over SSH.
      nixos-deploy = {
        authenticationTokenConfigFile = config.sops.templates."gitlab-runner-nixos-env".path;
        executor = "shell";
        # Allow build:x86 and build:rpi4 to run in parallel.
        requestConcurrency = 2;
      };

      # Group runner for wyssmann/projects (tag: homelab in GitLab). Serves
      # agentdotconf, eventgenie and the other group projects. Docker
      # executor so jobs can use their own image; tags come from the runner
      # record in GitLab, not from this file.
      homelab-group = {
        authenticationTokenConfigFile = config.sops.templates."gitlab-runner-group-env".path;
        executor = "docker";
        dockerImage = "golang:1.26-bookworm";
        requestConcurrency = 1;
        dockerPullPolicy = "if-not-present";
        dockerVolumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        environmentVariables = {
          DOCKER_HOST = "unix:///var/run/docker.sock";
        };
        registrationFlags = [
          "--docker-network-mode=host"
        ];
      };
    };
  };

}
