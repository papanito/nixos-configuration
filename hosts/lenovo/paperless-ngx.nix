{ config, pkgs, pkgs-unstable, ... }:

{
  users.users.paperless = {
    isSystemUser = true;
    group = "paperless";
    description = "Service account for non-privileged tasks";
    # Prevents interactive login
    shell = pkgs.shadow;
    # If the service needs a home directory for config/state
    createHome = true;
    home = "/var/lib/paperless";
  };

  # Corresponding group
  users.groups.paperless = {};
  users.users.nixos = {
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "paperless"
    ];
  };
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;
    consumptionDirIsPublic = true;
    user = "paperless";
    domain = "paperless.home";

    # paperless-ngx 3.x from nixpkgs-unstable for the native AI features
    # (PAPERLESS_AI_*, only available since v3.0). The 26.05 module drives this
    # package fine. Migrations to 3.x are one-way (must come from exactly
    # 2.20.15); every version bump of this package is a document-database
    # migration, so back up /var/lib/paperless/data before the deploy.
    package = pkgs-unstable.paperless-ngx;

    # Secret comes from sops (see template below); without the key the
    # PAPERLESS_AI_LLM_API_KEY env var is missing and AI calls fail.
    environmentFile = config.sops.templates."paperless-ai-key.env".path;

    settings = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_TIME_ZONE = "Europe/Zurich";
      PAPERLESS_FILENAME_FORMAT = "{document_type}/{correspondent}/{created_year}/{correspondent}_{created_year}{created_month}{created_day}_{title}";
      PAPERLESS_CONSUMER_RECURSIVE =  true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      # UMASK 0027 allows the group to read/list, but keeps 'others' blocked.
      PAPERLESS_UMASK = "0027";

      # The 26.05 module sets PAPERLESS_NLTK_DIR from package.nltkDataDir,
      # which the 3.x package no longer defines (v3 dropped NLTK). Must stay
      # false or the whole config fails to evaluate.
      PAPERLESS_ENABLE_NLTK = false;

      # --- Native AI (paperless-ngx 3.x), LLM at ollama.com cloud ---
      # openai-like backend → OpenAI-compatible API of ollama.com; documents
      # are sent to ollama.com during suggestions and chat. The API key is
      # injected via the sops template (environmentFile above).
      PAPERLESS_AI_ENABLED = true;
      PAPERLESS_AI_LLM_BACKEND = "openai-like";
      PAPERLESS_AI_LLM_ENDPOINT = "https://ollama.com/v1";
      PAPERLESS_AI_LLM_MODEL = "gemma4:31b";
      PAPERLESS_AI_LLM_OUTPUT_LANGUAGE = "German";

      # Chat/RAG needs an embedding backend; ollama.com's cloud catalog has no
      # embedding model, so embeddings run locally. Default MiniLM is
      # English-focused; the multilingual model matches the German archive.
      # First use downloads the model from huggingface.co into
      # /var/lib/paperless/.cache/huggingface.
      PAPERLESS_AI_LLM_EMBEDDING_BACKEND = "huggingface";
      PAPERLESS_AI_LLM_EMBEDDING_MODEL = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2";
    };
  };
  systemd.services.paperless-scheduler.after = ["var-lib-paperless.mount"];
  systemd.services.paperless-consumer.after = ["var-lib-paperless.mount"];
  systemd.services.paperless-web.after = ["var-lib-paperless.mount"];

  networking.firewall.allowedTCPPorts = [ 58080 ];

  # This ensures that every time the system boots or you run nixos-rebuild, the permissions are enforced
  systemd.tmpfiles.rules = [
    # Type | Path | Mode | User | Group | Age | Argument
    "d /var/lib/paperless 0750 paperless paperless -"
    "d /var/lib/paperless/media/documents 0750 paperless paperless -"
    "Z /var/lib/paperless - paperless paperless -"
  ];

  # API key for the paperless AI features (ollama.com, openai-like backend).
  # Per-host sops file (rule for hosts/lenovo/* in .sops.yaml, encrypted to
  # both admins + server_lenovo). Create/rotate with: sops hosts/lenovo/secrets.yaml
  sops.secrets.paperless_ai_api_key = {
    sopsFile = ./secrets.yaml;
  };
  sops.templates."paperless-ai-key.env" = {
    content = "PAPERLESS_AI_LLM_API_KEY=${config.sops.placeholder.paperless_ai_api_key}\n";
    owner = "paperless";
    group = "paperless";
    mode = "0400";
  };
}
