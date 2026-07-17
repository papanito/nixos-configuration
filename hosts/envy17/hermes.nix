{ pkgs, lib, ... }:
{
  # Hermes Agent — NousResearch, OpenRouter (free models).
  # SOPS secret is decrypted by sops-nix into /run/secrets/hermes_env
  # and loaded by the service via environmentFiles. The non-secret
  # OPENAI_API_BASE in `environment` redirects the OpenAI-compatible
  # client at OpenRouter.
  sops.secrets."hermes/env" = {
    sopsFile = ./secrets.yaml;
  };
  services.hermes-agent = {
    enable = true;
    settings.model = "meta-llama/llama-3.3-70b-instruct:free";
    environment.OPENAI_API_BASE = "https://openrouter.ai/api/v1";
    environmentFiles = [ config.sops.secrets."hermes/env".path ];
  };
}
