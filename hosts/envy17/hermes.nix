{
  inputs,
  pkgs,
  lib,
  config,
  sops-nix,
  ...
}:
let
  # Build the Google SDKs cleanly in the Nix Store
  googleChatLibs = pkgs.python312.withPackages (ps: [
    ps.google-cloud-pubsub
    ps.google-api-python-client
    ps.google-auth
    ps.google-auth-oauthlib
  ]);
  # 2. Wrap the Hermes binaries to forcefully inject the libraries into PYTHONPATH
  hermesWrapped = pkgs.symlinkJoin {
    name = "hermes-agent-gchat";
    paths = [ inputs.hermes-agent.packages.${pkgs.system}.default ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # This wraps both 'hermes' and 'hermes-gateway' to always load the Google libs
      for bin in $out/bin/*; do
        wrapProgram "$bin" \
          --prefix PYTHONPATH : "${googleChatLibs}/${pkgs.python312.sitePackages}"
      done
    '';
  };
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
    container.enable = true;
    container.hostUsers = [ "nixos" ];
    # Use the default package and let extraDependencyGroups pull in what you need,
    # instead of pinning to the `messaging` variant (which excludes google_chat).
    extraDependencyGroups = [
      "messaging"
      "firecrawl"
      "honcho"
      "google"
    ];
    extraPythonPackages = [
      #pkgs.python312Packages.google-cloud-pubsub
      #pkgs.python312Packages.google-api-python-client
      #pkgs.python312Packages.google-auth
      #pkgs.python312Packages.google-auth-oauthlib
    ];
    package = inputs.hermes-agent.packages.${pkgs.system}.default;
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
      # This forces the /nix/store executable to see the required Google SDKs
      PYTHONPATH = "${googleChatLibs}/${pkgs.python312.sitePackages}";

      OPENAI_API_BASE = "https://openrouter.ai/api/v1";
      GOOGLE_CHAT_SERVICE_ACCOUNT_JSON = "${config.sops.secrets.hermes_gcp_key.path}";
      GOOGLE_CHAT_PROJECT_ID = "hermes-agent-chatbot-502718";
      GOOGLE_CHAT_SUBSCRIPTION_NAME = "projects/hermes-agent-chatbot-502718/subscriptions/hermes-chat-events-sub";
    };

    environmentFiles = [ config.sops.secrets.hermes_env.path ]; # Corrected reference to hermes_env
    addToSystemPackages = true;
  };
}
