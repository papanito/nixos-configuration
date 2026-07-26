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
  # venv — so extraPythonPackages' collision check rejects it.  Work around
  # by pre-wrapping the package with the full transitive closure on PYTHONPATH.
  googleChatPythonPath = "${pkgs.python312.withPackages (ps: [ ps.google-cloud-pubsub ])}/${pkgs.python312.sitePackages}";
  hermesWithPubsub = inputs.hermes-agent.packages.${pkgs.system}.default.overrideAttrs (prev: {
    buildInputs = (prev.buildInputs or [ ]) ++ [ pkgs.makeWrapper ];
    installPhase = (prev.installPhase or "") + ''
      for bin in $out/bin/*; do
        wrapProgram "$bin" \
          --suffix PYTHONPATH : "${googleChatPythonPath}"
      done
    '';
  });
in
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
    package = hermesWithPubsub;
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
    };

    environmentFiles = [ config.sops.secrets.hermes_env.path ]; # Corrected reference to hermes_env
    addToSystemPackages = true;
  };
}
