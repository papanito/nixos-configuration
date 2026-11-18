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

    # Secrets for paperless come from the per-host sops file. paperless-ngx 3.x
    # hard-requires PAPERLESS_SECRET_KEY for EVERY entrypoint (web pre-start
    # migrations, celery beat, consumer), but the 26.05 module only exports it
    # inside the web server's main script — the same module loads
    # environmentFile for all units, so the env file below feeds the other
    # two. The 26.05 web unit's inline-generated key is unified with this
    # value via the tmpfiles C+ seed (see below).
    environmentFile = config.sops.templates."paperless-keys.env".path;

    settings = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_TIME_ZONE = "Europe/Zurich";
      # v3 deprecated single-brace placeholders; the admin UI now shows the
      # same warning. Only affects newly consumed documents.
      PAPERLESS_FILENAME_FORMAT = "{{ document_type }}/{{ correspondent }}/{{ created_year }}/{{ correspondent }}_{{ created_year }}{{ created_month }}{{ created_day }}_{{ title }}";
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
  systemd.services = {
    paperless-scheduler.after = ["var-lib-paperless.mount"];
    paperless-consumer.after = ["var-lib-paperless.mount"];
    paperless-web.after = ["var-lib-paperless.mount"];

    # The 26.05 module predates paperless AI and never sets TIKTOKEN_CACHE_DIR;
    # llama-index then downloads the cl100k tokenizer and tries to write it into
    # the read-only nix store (HTTP 500 on every AI call). The 3.x package ships
    # a pre-seeded cache — point every paperless entrypoint at it (what the
    # unstable module does).
    paperless-web.environment.TIKTOKEN_CACHE_DIR = config.services.paperless.package.tiktokenCacheDir;
    paperless-consumer.environment.TIKTOKEN_CACHE_DIR = config.services.paperless.package.tiktokenCacheDir;
    paperless-scheduler.environment.TIKTOKEN_CACHE_DIR = config.services.paperless.package.tiktokenCacheDir;
  };

  networking.firewall.allowedTCPPorts = [ 58080 ];

  # API key for the paperless AI features (ollama.com, openai-like backend).
  # Per-host sops file (rule for hosts/lenovo/* in .sops.yaml, encrypted to
  # both admins + server_lenovo). Edit with: sops hosts/lenovo/secrets.yaml
  sops.secrets.paperless_ai_api_key = {
    sopsFile = ./secrets.yaml;
  };
  # paperless-ngx 3.x requires a real PAPERLESS_SECRET_KEY in every
  # entrypoint; keep web and celery/consumer on one value (mixed keys break
  # signed payloads between them).
  sops.secrets.paperless_secret_key = {
    sopsFile = ./secrets.yaml;
  };
  sops.templates."paperless-keys.env" = {
    content = ''
      PAPERLESS_AI_LLM_API_KEY=${config.sops.placeholder.paperless_ai_api_key}
      PAPERLESS_SECRET_KEY=${config.sops.placeholder.paperless_secret_key}
    '';
    owner = "paperless";
    group = "paperless";
    mode = "0400";
  };
  # Raw copy of the secret, seeded into the key file the 26.05 module's web
  # unit reads (its generator script stops when the file already exists).
  sops.templates."paperless-secret-key" = {
    content = "${config.sops.placeholder.paperless_secret_key}\n";
    owner = "paperless";
    group = "paperless";
    mode = "0400";
  };

  systemd.tmpfiles.rules = [
    # Seed the web unit's key file with the sops value (C+ overwrites the file
    # the old generation's web unit generated). Processed before the units
    # start on switch/boot.
    "C+ /var/lib/paperless/nixos-paperless-secret-key 0400 paperless paperless - ${config.sops.templates."paperless-secret-key".path}"
    # Type | Path | Mode | User | Group | Age | Argument
    "d /var/lib/paperless 0750 paperless paperless -"
    "d /var/lib/paperless/media/documents 0750 paperless paperless -"
    "Z /var/lib/paperless - paperless paperless -"
  ];
}
