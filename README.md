# My NIXOS Configuration

Setup all my devices using nixos (WIP)

## General Setup

I use [nix-sops](https://github.com/Mic92/sops-nix)

```shell
nix-shell -p sops --run "sops secrets/secrets.yaml"
nix-shell -p spos --run 'sops updatekeys secrets/secrets.yaml'
```

## Setup remote system

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
   colmena apply --on lenovo,envy
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

## CI: flake updates and deployment

The repository uses GitLab CI (`.gitlab-ci.yml`) with a project-scoped **shell executor** runner on `envy17` (tag `nixos-deploy`). The shell executor shares envy17's Nix store, so builds are incremental and Colmena can cross-build `rpi4-a` locally via binfmt.

Pipeline behavior:

| Event | Jobs |
| :--- | :--- |
| Merge request | evaluate every host (`nix eval ...drvPath`), build all closures |
| Push/merge to `main` | evaluate, build, then deploy: `envy,lenovo` → `rpi4-a` → `envy17` |
| Weekly schedule (Mon 03:00 Europe/Zurich) | `nix flake update`, push `chore/update-flake-lock`, create/update an MR |

Merging the automated lockfile MR runs the normal `main` pipeline, so a broken update fails at build time and is never deployed.

Required protected CI/CD variables:

- `CI_PUSH_TOKEN` — project access token (`nixos-ci-push-api`) with `api` + `write_repository`, used to push the update branch and create/update its MR.
- `NIXOS_SSH_KEY_FILE` — file variable containing the private key for `ci-deploy@nixos-configuration`. The matching public key is in `profiles/servers/users/nixos.nix`.

One-time bootstrap after changing runner config or the CI key:

```sh
# From clawfinger, using your personal key (already authorized)
colmena apply --impure --on envy,envy17,lenovo,rpi4-a

# restartIfChanged/stopIfChanged are disabled for the runner, so apply the
# new unit once manually:
ssh nixos@10.0.0.12 'sudo systemctl restart gitlab-runner'
```

After the restart, GitLab → Settings → CI/CD → Runners should show `nixos-deploy-envy17` online. Keep fork pipelines disabled (`ci_allow_fork_pipelines_to_run_in_parent_project = false`): shell jobs execute directly on envy17.

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
