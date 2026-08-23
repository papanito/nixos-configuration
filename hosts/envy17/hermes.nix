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

  # Declarative patch for the upstream Google Chat adapter
  # (plugins/platforms/google_chat/adapter.py, hermes-agent 0.19.1+).
  #
  # Bug: line 1389 does `envelope = json.loads(message.data.decode("utf-8"))`
  # and acks the message on any parse error.  Google Chat Events API
  # delivers CloudEvents-style Pub/Sub messages where the JSON payload is
  # carried in `message.attributes["ce-data"]` (structured mode) or even
  # fully in attributes, and `message.data` is frequently empty bytes.
  # Result: every inbound event hits JSONDecodeError, is ACKed silently,
  # and the bot appears unresponsive.
  #
  # Fix: inject a small `_parse_chat_envelope` helper into the adapter
  # class, and replace the brittle `json.loads(message.data.decode(...))`
  # with a call to it.  Patched via substituteInPlace on the symlinked
  # plugin tree ($out/share/hermes-agent/plugins/...) at build time, so
  # no runtime PYTHONPATH or path hacks are required and the loader
  # continues to discover the plugin exactly as upstream intends.
  patchedHermesAgent =
    let
      upstream = inputs.hermes-agent.packages.${pkgs.system}.default;
      adapter = "share/hermes-agent/plugins/platforms/google_chat/adapter.py";
    in
    upstream.overrideAttrs (_old: {
      # postInstall is wired through runHook in upstream hermes-agent.nix
      # at the end of installPhase, so this appends cleanly without
      # rewriting the whole install phase.
      postInstall = ''
        ADAPTER="$out/${adapter}"
        if [ ! -e "$ADAPTER" ]; then
          echo "patchedHermesAgent: $ADAPTER missing - refusing to apply patch" >&2
          exit 1
        fi

        # 1. Replace the brittle per-call decode with a helper call.
        substituteInPlace "$ADAPTER" \
          --replace-fail \
            'envelope = json.loads(message.data.decode("utf-8"))' \
            'envelope = self._parse_chat_envelope(message)'

        # 2. Inject the helper method just above the patched call site.
        #    Anchor on the existing _on_pubsub_message signature so the
        #    injection lands inside the same class.
        substituteInPlace "$ADAPTER" \
          --replace-fail '    def _on_pubsub_message(self, message: Any) -> None:' \
            '    def _parse_chat_envelope(self, message: Any) -> dict:
        """Parse Google Chat Pub/Sub envelope, handling empty data.

        Google Chat Events API delivers CloudEvents-style Pub/Sub
        messages.  Per the spec, the JSON payload may be carried in:

          * message.data (binary mode) - frequently ``b""`` for chat
          * message.attributes["ce-data"] (structured mode, may be
            base64-encoded JSON) - common path for chat events
          * (rarely) other attributes

        Upstream only inspected ``message.data`` and ACKed on empty
        bytes, which made the bot silently non-responsive.  This
        helper tries each location in order and returns an empty
        envelope when nothing is recoverable so downstream
        ``envelope.get("chat") or {}`` keeps working.
        """
        raw = getattr(message, "data", None) or b""
        if raw:
            try:
                return json.loads(raw.decode("utf-8"))
            except Exception:
                logger.exception(
                    "[GoogleChat] Failed to decode message.data; trying attributes"
                )
        attrs = dict(getattr(message, "attributes", {}) or {})
        for key in ("ce-data", "data", "message", "payload"):
            value = attrs.get(key)
            if not value:
                continue
            payload = value
            if key == "ce-data":
                # CloudEvents structured mode: base64-encoded JSON
                try:
                    import base64 as _b64
                    payload = _b64.b64decode(value, validate=False).decode("utf-8")
                except Exception:
                    payload = value
            try:
                decoded = json.loads(payload)
                if isinstance(decoded, dict):
                    return decoded
            except Exception:
                continue
        logger.warning(
            "[GoogleChat] Pub/Sub message had no decodable envelope "
            "(data=%sB, attrs=%s); returning empty envelope",
            len(raw) if isinstance(raw, (bytes, bytearray)) else -1,
            sorted(attrs.keys()),
        )
        return {}

    def _on_pubsub_message(self, message: Any) -> None:'

        echo "patchedHermesAgent: applied CloudEvents empty-data fix to $ADAPTER"
      '';
    });
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
    # Use the patched package that fixes the Google Chat "bot not
    # responding" bug (CloudEvents empty-data handling).  See the
    # `patchedHermesAgent` binding at the top of this file.
    package = patchedHermesAgent;
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
      HERMES_LOG_LEVEL = "DEBUG";
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
    "/var/lib/hermes/patches"
    "${inputs.hermes-agent.packages.${pkgs.system}.default}/lib/python3.12/site-packages"
    googleChatPythonPath
  ];
}
