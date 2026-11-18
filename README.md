# My NIXOS Configuration

Setup all my devices using nixos (WIP)

## General Setup

I use [nix-sops](https://github.com/Mic92/sops-nix)

```shell
nix-shell -p sops --run "sops secrets/secrets.yaml"
nix-shell -p spos --run 'sops updatekeys secrets/secrets.yaml'
```

## Deployment with Colmena

Hosts are declared once in `flake.nix` (`self.hosts`) and the Colmena hive is derived from that list: every host carrying a `deployment` attribute becomes a node, so a new machine is added in one place and appears in the hive automatically.

- **Remote hosts** are Colmena-managed: `envy` (10.0.0.10), `envy17` (10.0.0.12), `lenovo` (10.0.0.61), `rpi4-a` (10.0.0.11). Each node deploys as `nixos@<targetHost>`.
- **Schema:** the hive uses Colmena **0.4**; the devShell pins that version. A Colmena 0.5 binary expects a `colmenaHive`/`v0.5` schema and rejects this hive.
- **clawfinger** is the local workstation and is *not* in the hive (no `deployment` attribute, no sshd reachable by Colmena), so it is filtered out. Deploy it locally with `run0 nixos-rebuild switch --flake .#clawfinger`.
- **rpi4-a** is `aarch64-linux` and is cross-built on the deploy host — binfmt/qemu emulation is enabled on clawfinger and envy17. `deployment.buildOnTarget` is deliberately unset, so builds stay on the deploy host's disk and only the final closure is copied to the Pi.

```sh
# x86 hosts first, runner host last; -p 1 keeps builds serial
nix develop --command colmena apply --impure --on envy,lenovo -p 1
nix develop --command colmena apply --impure --on envy17

# Raspberry Pi (cross-built via binfmt)
nix develop --command colmena apply --impure --on rpi4-a

# Everything at once, including the Pi
nix develop --command colmena apply --impure --on envy,envy17,lenovo,rpi4-a
```

`nix develop --command colmena build --impure --on <hosts>` builds without activating — useful to pre-seed the store before a deploy window.

## Provisioning a new host (manual reference)

1. Create bootable image with fixed ip and user password/ssh_key enabled

   ```shell
   nix build ".#packages.x86_64-linux.custom-iso"
   ```

1. Boot system in live mode, which defaults to 10.0.0.250
1. Use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md)

   ```shell
   nix run github:nix-community/nixos-anywhere -- \
    --flake ".#FLAKE" \
   nixos@10.0.0.250
   ```

1. Install/Update system using [colmena](https://github.com/zhaofengli/colmena)

   ```shell
   nix develop --command colmena apply --on lenovo,envy
   ```

1. Add host key to `.sops.yaml` - we use age and the key can be found in the error message

   ```shell
   [ERROR]   stderr) sops-install-secrets: Imported /etc/ssh/ssh_host_ed25519_key as age key with fingerprint ageXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

1. Update secrets

  ```shell
  sops updatekeys profiles/servers/secrets.yaml
  sops updatekeys secrets/secrets.yaml
  ...
  ```

Alternatively you can also run:

```shell
sudo -E nixos-rebuild switch --flake '.#envy' \
  --upgrade --target-host \
  nixos@<ip> --sudo
```

If there is a problem with ssh, you can specify the key to use:

```shell
NIX_SSHOPTS="-i /home/papanito/.ssh/id_ssh_admin@envy.ed25519"
```

## CI pipeline (the normal deploy path)

Deploying by hand is the exception: merges to `main` go through GitLab CI, which validates, builds and then applies Colmena to every host. The manual commands above stay the escape hatch for provisioning, runner changes and recovery.

The repository uses GitLab CI (`.gitlab-ci.yml`) with a project-scoped **shell executor** runner on `envy17` (tag `nixos-deploy`). The shell executor shares envy17's Nix store, so builds are incremental and Colmena can cross-build `rpi4-a` locally via binfmt (`extra-platforms = aarch64-linux armv7l-linux`).

Pipeline behavior:

| Event | Jobs |
| :--- | :--- |
| Merge request | evaluate every host (`nix eval ...drvPath`), build all closures |
| Push/merge to `main` | evaluate, build, then `deploy:x86` (`envy`, `lenovo`, `envy17`) and `deploy:rpi4` (`rpi4-a`) |
| Manual web pipeline on `main` | play `deploy:x86`, `deploy:rpi4`, or both independently |
| Schedule (`0 3 * * */3`: Mon/Wed/Sat 03:00 Europe/Zurich) | `nix flake update`, push `chore/update-flake-lock`, create/update an MR, announce it in Google Chat |

Merging the automated lockfile MR runs the normal `main` pipeline, so a broken update fails at build time and is never deployed. A scheduled run never deploys by itself; the merge is the deploy trigger.

Required protected CI/CD variables:

- `CI_PUSH_TOKEN` — project access token (`nixos-ci-push-api`) with `api` + `write_repository`, used to push the update branch and create/update its MR.
- `NIXOS_SSH_KEY_FILE` — file variable containing the private key for `ci-deploy@nixos-configuration`. The matching public key is in `profiles/servers/users/nixos.nix`.
- `GOOGLE_CHAT_WEBHOOK` — protected variable with the Google Chat space webhook URL used to announce the lockfile MR. GitLab rejects masking values that contain a query string, so this variable stays unmasked; the job only passes it to `curl` and never echoes it. When unset, the notification step logs a message and is skipped.

One-time bootstrap after changing runner config or the CI key:

```sh
# From clawfinger, using your personal key (already authorized)
nix develop --command colmena apply --impure --on envy,envy17,lenovo,rpi4-a

# restartIfChanged/stopIfChanged are disabled for the runner, so apply the
# new unit once manually:
ssh nixos@10.0.0.12 'sudo systemctl restart gitlab-runner'
```

After the restart, GitLab → Settings → CI/CD → Runners should show `nixos-deploy-envy17` online. Keep fork pipelines disabled (`ci_allow_fork_pipelines_to_run_in_parent_project = false`): shell jobs execute directly on envy17.

## Cloud & Networking

What leaves the LAN is declarative too: hosts join the tailnet on boot, the homelab is published without opening inbound ports, and provider-side state is managed as code.

|What|How|
|----|-----------|
|[Tailscale](https://tailscale.com/)|[`common/tailscale.nix`](./common/tailscale.nix) joins every host (clawfinger, envy, envy17, lenovo, rpi4-a) to the tailnet. `useRoutingFeatures = "client"` relaxes the firewall's reverse-path check without making any host a subnet router or exit node. The auth key comes from `secrets/secrets.yaml` via sops, so `tailscaled-autoconnect` joins on boot with no manual `tailscale up` — it must stay reusable, non-ephemeral and pre-approved.|
|[Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/)|[`hosts/clawfinger/networking/cloudflare.nix`](./hosts/clawfinger/networking/cloudflare.nix) installs `cloudflared` and `cloudflare-warp` so homelab services are reachable without inbound ports. Origin certificates live in `~/.cloudflared/`; the WARP service is wired but disabled.|
|[Cloudflare Workers](https://www.cloudflare.com/products/workers/)|Edge functions and static assets built and deployed with `wrangler` from the project repos (`wrangler.jsonc` + `wrangler.production.jsonc`, e.g. eventcompass). Not part of this flake.|
|[Backblaze B2](https://www.backblaze.com/cloud-storage) + [restic](https://restic.net/)|[`profiles/servers/restic.nix`](./profiles/servers/restic.nix) enables `services.restic.backups.b2`: encrypted, deduplicated snapshots of `/var/lib` pushed daily to `b2:<bucket>/<host>`. The repo password and B2 keys are sops secrets rendered into `restic.env`; `autorestic` is installed alongside, and a Google Chat notifier reports success and failure.|
|[GitLab](https://gitlab.com/)|Primary CI/CD and secrets backend — see [CI pipeline](#ci-pipeline-the-normal-deploy-path). Deploy credentials are protected CI/CD variables (`CI_PUSH_TOKEN`, `NIXOS_SSH_KEY_FILE`), and the runner is a project-scoped shell executor on envy17.|
|[Terraform](https://developer.hashicorp.com/terraform)|Provider-side state as code: [`hosts/terraform/terraform/variables.tfvars`](./hosts/terraform/terraform/variables.tfvars) holds the Cloudflare account and zone IDs, so zones and DNS changes are reviewed instead of clicked. Local tooling (`terraform`, `cloudflared`, `wrangler`, `restic`) comes from the dotfiles repo.|

## Raspberry PI

Follows <https://github.com/nvmd/nixos-raspberrypi?tab=readme-ov-file>

1. Build image

  ```shell
  nix build '.#nixosConfigurations.rpi4-demo.config.system.build.sdImage'
  ```

1. Unzstd image

  ```shell
  unzstd result/sd-image/nixos-sd-image-rpi4-uboot.img.zst -o nixos-sd-image-rpi4-uboot.img
  ```

1. Burn it to sdcard

  ```shell
  sudo dd if=nixos-sd-image-rpi4-uboot.img of=/dev/sda bs=4M status=progress
  ```
