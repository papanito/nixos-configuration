{ config, pkgs, ... }:

{
   sops = {
    secrets.GITLAB_RUNNER_TOKEN = {
      # GitLab runner runs as the "gitlab-runner" user
      owner = "gitlab-runner";
    };
  };

  # Enable Docker (required for the Docker executor)
  virtualisation.docker.enable = true;

  # Configure the GitLab Runner service
  services.gitlab-runner = {
    enable = true;
    services = {
      # You can name this anything (e.g., "my-local-runner")
      local-builder = {
        # Get your token from GitLab: Settings > CI/CD > Runners > New project runner
        authenticationTokenConfigFile = "/etc/gitlab-runner/auth-token";
        
        executor = "docker";
        dockerImage = "golang:1.25-bookworm"; # Default image if not specified in YAML
        
        # Tags are crucial! Use this in your .gitlab-ci.yml
        tagList = [ "local-nixos" ];

        # Optional: speed up builds by allowing the runner to use host's CPU cores
        registrationFlags = [
          "--docker-network-mode=host"
        ];
      };
    };
  };

}
