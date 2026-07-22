{
  inputs,
  pkgs,
  lib,
  config,
  sops-nix,
  ...
}:
{
  imports = [
    inputs.hermes-agent.nixosModules.default # Import the NixOS module directly from the flake
  ];

  users = {
    groups.hermes-agent = { };
    users.hermes-agent = {
      isSystemUser = true;
      group = "hermes-agent";
      description = "Service account for hermes-agent";
      # Prevents interactive login
      shell = pkgs.shadow;
      # If the serv ftice needs a home directory for config/state
      createHome = true;

      home = "/var/lib/hermes";
    };
  };

  # SOPS secret for API key
  sops.secrets = {
    "hermes_env" = {
      # Corrected key to hermes_env
      sopsFile = ./secrets.yaml;
    };
    "hermes_gcp_key" = {
      sopsFile = ./gcp-config.json;
      format = "binary"; # Keeps sops-nix from trying to parse inside the file
      owner = "hermes-agent";
      group = "hermes-agent";
      mode = "0400";
    };
  };

  # Configuration for hermes-AGent service
  services.hermes-agent = {
    enable = true;
    container.enable = true;
    container.hostUsers = [ "nixos" ];
    # Use the default package and let extraDependencyGroups pull in what you need,
    # instead of pinning to the `messaging` variant (which excludes google_chat).
    extraDependencyGroups = [
      "messaging"
      "firecrawl"
      "honcho"
    ];
    extraPythonPackages = [
      pkgs.python312Packages.google-cloud-pubsub
      pkgs.python312Packages.google-api-python-client
      pkgs.python312Packages.google-auth
      pkgs.python312Packages.google-auth-oauthlib
    ];

    settings = {
      model.default = "openrouter/free";

      google_chat = {
        enabled = true;
      };
      toolsets = [ "all" ];
      terminal = {
        backend = "local";
        timeout = 180;
      };
      display = {
        compact = false;
        personality = "kawaii";
      };
      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
      };
    };

    environment = {
      OPENAI_API_BASE = "https://openrouter.ai/api/v1";
      GOOGLE_CHAT_SERVICE_ACCOUNT_JSON = "${config.sops.secrets.hermes_gcp_key.path}";
      GOOGLE_CHAT_PROJECT_ID = "hermes-agent-chatbot-502718";
      GOOGLE_CHAT_SUBSCRIPTION_NAME = "projects/hermes-agent-chatbot-502718/subscriptions/hermes-chat-events-sub";
    };

    environmentFiles = [ config.sops.secrets.hermes_env.path ]; # Corrected reference to hermes_env
    addToSystemPackages = true;
  };
}
