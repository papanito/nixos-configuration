# clawfinger

## Purpose

Local workstation host (Tuxedo laptop, x86_64, GNOME/Wayland on Intel iGPU, libvirt/KVM). This is the machine agents typically run on.

## Ownership

- Host entry: `flake.nix` → `hosts.clawfinger = mkSystem "clawfinger" { type = "pc"; }` (no `deployment` attr).
- Local modules in this directory; shared modules under `common/` and `modules/`.

## Local Contracts

### Deployment

- Deployed LOCALLY, not via Colmena: no sshd reachable by colmena and no `deployment` attr in `flake.nix`, so colmena filters it out of the hive (`colmena apply --on clawfinger` selects 0 hosts — expected).
- Deploy from the repo root with:
  ```sh
  run0 nixos-rebuild switch --flake .#clawfinger
  ```
- Kernel parameter changes require a reboot after the switch to take effect.

### Privilege escalation

- No `sudo`/`doas` binary. Elevation is `run0` (polkit-backed); shells alias `sudo` → `run0` via `common/security/pam.nix` (`modules.security.pam`, sudo disabled by default).
- `run0` needs an interactive polkit password prompt — non-interactive agent shells cannot elevate. Ask the user to run privileged commands.
- `hosts/clawfinger/security.nix` still contains a `security.sudo` block, but it is dead config: the pam module's `sudo.enable = mkForce (!disableSudo)` overrides it. Do not rely on those sudoers rules being active.

## Work Guidance

- Suspend/GNOME-freeze mitigations live here and must stay when touching boot/sleep config:
  - `hardware.nix`: `i915.enable_dc=0`, `i915.enable_psr=0`, `i915.enable_fbc=0` (post-resume shell freeze: pointer moves but clicks/overview die).
  - `default.nix`: `SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false"` on all four systemd sleep services (KVM deadlock during suspend).
  - `hardware.nix`: `loader.systemd-boot.configurationLimit = 12` (overrides the repo default of 5 in `common/nix.nix`) to keep rollback generations.
- Use the system nix binary from `/nix/store/*-nix-*/bin/nix` for evals if the profile nix misbehaves.
- Verify flake.lock pins a channel commit before deploying (cache-miss/gap-commit issue).

## Verification

```sh
# Eval resolved kernel params and generation limit without building
nix eval --raw '.#nixosConfigurations.clawfinger.config.boot.kernelParams' \
  --apply 'p: builtins.concatStringsSep " " p'
nix eval '.#nixosConfigurations.clawfinger.config.boot.loader.systemd-boot.configurationLimit'
```

After deploy + reboot: `/proc/cmdline` must contain `i915.enable_dc=0`; `journalctl -b | grep 'froze unit'` should show no user.slice freezing on suspend.

## Child DOX Index

Not yet split into child docs; all clawfinger rules live here.
