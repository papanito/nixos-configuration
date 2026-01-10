{ config, pkgs, ... }:

{
   sops = {
    secrets.gitlab_runner_token = {
      sopsFile = ../../profiles/servers/secrets.yaml;
      # GitLab runner runs as the "gitlab-runner" user
      #owner = "gitlab-runner";
      key = "gitlab_runner_token";
      owner = "gitlab-runner";
      # Ensure the file is NOT executable so the shell won't try to run it
      mode = "0400";
    };

    templates."gitlab-runner-env".content = ''
      CI_SERVER_URL="https://gitlab.com";
      REGISTRATION_TOKEN="${config.sops.placeholder.gitlab_runner_token}"
    '';
  };

  users.users.gitlab-runner = {
    isSystemUser = true;
    group = "paperless";
    description = "Service account for gitlab-runner";
    # Prevents interactive login
    shell = pkgs.shadow; 
    # If the serv ftice needs a home directory for config/state
    createHome = true;
        
    home = "/var/lib/gitlab-runner";
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
        #authenticationTokenConfigFile = "${config.sops.secrets.gitlab_runner_token.path}";
        registrationConfigFile = config.sops.templates."gitlab-runner-env".path;
        
        executor = "docker";
        dockerImage = "golang:1.25-bookworm"; # Default image if not specified in YAML
        
        # Tags are crucial! Use this in your .gitlab-ci.yml
        tagList = [ "homelab" ];

        # Optional: speed up builds by allowing the runner to use host's CPU cores
        registrationFlags = [
          "--docker-network-mode=host"
        ];
      };
    };
  };

}
