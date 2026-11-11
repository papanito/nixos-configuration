# envy17

## Purpose

Server host at `10.0.0.12` that also hosts the project-scoped GitLab runners used by CI, including the shell runner for the `nixos-configuration` flake-update/Colmena pipeline.

## Ownership

- Host entry: `flake.nix` → `hosts.envy17 = mkServer "envy17" "10.0.0.12"`.
- Runner configuration: `hosts/envy17/gitlab-runner.nix`.
- Runner auth tokens: `hosts/envy17/secrets.yaml` (`gitlab_runner_token`, `gitlab_runner_nixos_token`).
- Pipeline definition: `.gitlab-ci.yml` at the repository root.

## Local Contracts

### GitLab runners

- Two runner services are registered:
  - `local-builder` — Docker executor, tag `homelab`.
  - `nixos-deploy` — shell executor, tag `nixos-deploy`; used by `.gitlab-ci.yml`. Created with `access_level=not_protected`, `run_untagged=false`, `locked=true`.
- Shell jobs run as `gitlab-runner` (HOME `/var/lib/gitlab-runner`) inside the service's mount namespace, share envy17's `/nix` store, and use the host `nix-daemon`.
- `services.gitlab-runner.extraPackages` provides `nix`, `colmena`, `git`, and `openssh` on the shell-job PATH. Add tools there, not only to `environment.systemPackages`.
- `boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ]` lets envy17 cross-build the rpi4-a closure. Do not remove it without replacing the rpi4-a CI strategy.
- `systemd.services.gitlab-runner.restartIfChanged` and `stopIfChanged` are `false` so deploying envy17 from a job running on envy17 cannot restart the runner mid-pipeline. Consequence: after changing the runner unit (packages, PATH, executor, service list), restart it manually:
  ```sh
  ssh nixos@10.0.0.12 'sudo systemctl restart gitlab-runner'
  ```

### CI credentials

- `NIXOS_SSH_KEY_FILE` (protected, file variable) holds the private key for `ci-deploy@nixos-configuration`. Its public key is authorized in `profiles/servers/users/nixos.nix`; the first deploy that adds it must be run from clawfinger.
- `CI_PUSH_TOKEN` (protected, masked) is the project access token `nixos-ci-push-api` with `api` + `write_repository`, used by the scheduled job to push `chore/update-flake-lock` and create/update its MR through the API.
- `GOOGLE_CHAT_WEBHOOK` (protected, masked) is the Google Chat space webhook the scheduled job posts the MR notice to. Optional: when unset the job logs a warning and skips the notification.
- The shell runner must stay at `access_level=not_protected` so merge-request pipelines can run validation. Do not execute fork pipelines: `ci_allow_fork_pipelines_to_run_in_parent_project` must remain `false`.

### Deployment

- Bootstrap/manual deploy from clawfinger: `nix develop --command colmena apply --impure --on envy17` (the flake pins Colmena 0.4; the 0.5 hive schema is not compatible).
- The pipeline deploys envy17 last, after `envy,lenovo` and `rpi4-a`.

## Work Guidance

- Keep the shell executor's `requestConcurrency = 1`; the pipeline also uses `resource_group: nixos-deploy` to serialize deploys.
- Do not put the SSH deploy key in a world-readable path or in the repo. It lives only in the protected CI variable and is written to `$HOME/.ssh/id_ed25519` for the duration of the deploy job.
- When changing runner tags, update them in GitLab (runner settings) as well as `.gitlab-ci.yml`; tags set via `tagList` are ignored when using an authentication token.

## Verification

```sh
ssh nixos@10.0.0.12 'systemctl status gitlab-runner'
ssh nixos@10.0.0.12 'systemctl show -p DynamicUser -p User gitlab-runner'
nix eval --raw '.#nixosConfigurations.envy17.config.boot.binfmt.emulatedSystems' \
  --apply 'lib: builtins.concatStringsSep "," lib'
nix eval --raw '.#nixosConfigurations.envy17.config.services.gitlab-runner.services.nixos-deploy.executor'
```

After bootstrap and the manual runner restart, GitLab → Settings → CI/CD → Runners must show `nixos-deploy-envy17` as online.

## Child DOX Index

Not yet split into child docs; all envy17 rules live here.
