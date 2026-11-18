# lenovo — wired server host (10.0.0.61)

## Purpose

Server host running the household document pipeline: paperless-ngx (`paperless-ngx.nix`), its consume-area fileserver (`fileserver.nix`, rsync target for clawfinger), and the colmena/CI-deployed NixOS system itself.

## Ownership

- Deployed with Colmena from the deploy host: `nix develop --command colmena apply --impure --on lenovo` (see root AGENTS.md deployment rules). Merges to `main` deploy it via the `deploy:x86` CI job.
- `paperless-ngx.nix` owns the paperless service account, AI settings, and the sops secret/templates for the AI key. `fileserver.nix` owns only the consume-area rsync service.
- The AI API key lives in this host's own sops file: `sops hosts/lenovo/secrets.yaml` (creation rule in the repo root `.sops.yaml`; key `paperless_ai_api_key`, encrypted to both admins + `server_lenovo`). It ships with an empty placeholder value — set the real key before relying on AI.
- The 3.x paperless package comes from `pkgs-unstable.paperless-ngx`; contract details (version coupling, `PAPERLESS_ENABLE_NLTK = false`, one-way migrations, sops key) are documented in the root AGENTS.md *Package pins* section — keep the two in sync.

## Local Contracts

- paperless serves on 10.0.0.61:58080 (`paperless.home`), firewall-opened; data lives under `/var/lib/paperless` (SQLite).
- Document content is sent to `ollama.com` while AI features are on; RAG/chat embeddings run locally through the huggingface backend (`paraphrase-multilingual-MiniLM-L12-v2`), so the first index build downloads that model from huggingface.co.
- clawfinger's restic does NOT cover `/var/lib/paperless` here — before any paperless version bump, back up `/var/lib/paperless/data` on the host itself.

## Work Guidance

- Changing AI settings only needs `PAPERLESS_AI_*` entries in `services.paperless.settings`; the API key stays environment-only (`environmentFile`), never inline.
- After changing the embedding model, rebuild the index once: `paperless-ngx-manage document_llmindex rebuild` as the `paperless` user on lenovo (the nightly cron also refreshes it).

## Verification

- `nix eval .#nixosConfigurations.lenovo.config.services.paperless.package.version` (expects 3.4.2 or newer).
- After deploy: `systemctl status paperless-web` on lenovo; AI suggestions in the web UI; document chat answers with source-document links.

## Child DOX Index

No child AGENTS.md files — flat file list, no durable sub-boundaries.
