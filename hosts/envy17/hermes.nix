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

  # Allow the nixos user to run hermes CLI commands against the service state
  users.users.nixos.extraGroups = [ "hermes" ];

  # SOPS secret for API key
  sops.secrets."hermes_env" = {
    sopsFile = ./secrets.yaml;
  };

  # Configuration for hermes-agent service.
  # No chat platform integration (Google Chat removed); the service runs
  # headless and is driven via the hermes CLI by users in the `hermes` group.
  services.hermes-agent = {
    enable = true;
    container.enable = false;
    # honcho was dropped upstream (no longer an optional-dependency group);
    # only groups defined in hermes-agent's pyproject.toml validate.
    extraDependencyGroups = [
      "messaging"
      "firecrawl"
    ];
    settings = {
      model.default = "openrouter/free";

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
      HERMES_LOG_LEVEL = "DEBUG";
    };

    environmentFiles = [ config.sops.secrets.hermes_env.path ];
    addToSystemPackages = true;

    # Web dashboard backend (hermes-agent module term: `serve`+UI). Runs as a
    # separate hermes-backend.service sharing HERMES_HOME with the gateway.
    # Bound to the tailscale0 interface address so the dashboard is reachable
    # ONLY via the tailnet: http://100.77.170.127:9119 (MagicDNS is off; use
    # the IP — the backend pins the Host header to what it binds).
    # Non-loopback bind enables the dashboard auth gate; credentials are set
    # in the browser on first visit.
    backend = {
      mode = "dashboard";
      waitFor = "interface";
      interfaceName = "tailscale0";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/hermes 0770 hermes hermes -"
    "d /var/lib/hermes/.hermes 0770 hermes hermes -"
    "z /var/lib/hermes/.hermes 0770 hermes hermes -"
    "z /var/lib/hermes/.hermes/.hermes_history 0660 hermes hermes -"
  ];
}
