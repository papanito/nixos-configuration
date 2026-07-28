{
  inputs,
  pkgs,
  lib,
  config,
  sops-nix,
  ...
}:
let
  # google-cloud-pubsub is the only missing dep for Google Chat, but it
  # transitively depends on google-api-core which is already in the sealed
  # venv — so extraPythonPackages' collision check rejects it.  Inject the
  # full transitive closure via systemd Environment to avoid the collision.
  googleChatPythonPath = "${
    pkgs.python312.withPackages (ps: [ ps.google-cloud-pubsub ])
  }/${pkgs.python312.sitePackages}";
in
{
  imports = [
    inputs.hermes-agent.nixosModules.default # Import the NixOS module directly from the flake
  ];

  # Allow the nixos user to run hermes CLI commands against the service state
  users.users.nixos.extraGroups = [ "hermes" ];


  # SOPS secret for API key
  sops.secrets = {
    "hermes_env" = {
      # Corrected key to hermes_env
      sopsFile = ./secrets.yaml;
    };
    "hermes_gcp_key" = {
      sopsFile = ./gcp-config.json;
      format = "binary"; # Keeps sops-nix from trying to parse inside the file
      owner = "hermes";
      group = "hermes";
      mode = "0400";
    };
  };

  # Configuration for hermes-agent service
  services.hermes-agent = {
    enable = true;
    container.enable = false;
    extraDependencyGroups = [
      "messaging"
      "firecrawl"
      "honcho"
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
      GOOGLE_CHAT_ALLOWED_USERS = "aedu@wyssmann.com";
    };

    environmentFiles = [ config.sops.secrets.hermes_env.path ];
    addToSystemPackages = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/hermes 0770 hermes hermes -"
    "d /var/lib/hermes/.hermes 0770 hermes hermes -"
    "z /var/lib/hermes/.hermes 0770 hermes hermes -"
    "z /var/lib/hermes/.hermes/.hermes_history 0660 hermes hermes -"
  ];

  # Inject google-cloud-pubsub transitive closure into the hermes service's PYTHONPATH.
  # The sealed venv already has all other Google deps; extraPythonPackages can't be used
  # because the collision check rejects google-api-core (already in venv).
  systemd.services.hermes-agent.environment.PYTHONPATH = lib.concatStringsSep ":" [
    "${inputs.hermes-agent.packages.${pkgs.system}.default}/lib/python3.12/site-packages"
    googleChatPythonPath
  ];
}
