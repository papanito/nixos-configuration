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

### Application firewall (OpenSnitch)

- Declared in `networking/opensnitch.nix`, not from the GUI. Rules live in
  `services.opensnitch.rules`; the NixOS module symlinks each one into
  `/var/lib/opensnitch/rules` on service start, so GUI edits to a declared rule are
  overwritten on the next switch. Add new allows to the `allRules` list there.
- Evaluation is **lexicographic by rule name**, not by a numeric priority:
  `daemon/rule/loader.go` sorts active rule names and `FindFirstMatch` stops at the
  first `deny`/`reject`, otherwise the last matching `allow` wins. Hence the `0NN-`
  prefixes, and `precedence = true` on the allows so they outrank a later GUI-created
  `deny-…` rule.
- Nix store paths change hash on every upgrade, so process rules use
  `type = "regexp"` (`^/nix/store/[a-z0-9]+-<pkg>-[0-9][^/]*/<binary>$`), never an
  exact `simple` path — a hash-pinned rule silently stops matching after a rebuild.
- OpenSnitch intercepts **loopback** (all traffic traverses the OUTPUT hook), so
  `000-allow-localhost` (`dest.network` `127.0.0.0/8`) is load-bearing: agent CLIs
  spawn a local helper server and connect to it, and a stray deny breaks them.
- A `duration` other than `always` expires; `once` is never registered in the running
  rule set. Declarative rules must use `always`.

## Work Guidance

- Build parallelism is capped by `nix.settings.cores = 8` in `default.nix`. binfmt/qemu-user
  runs one `qemu-aarch64` process per emulated process, so an un-capped `cores = 0` aarch64
  kernel build (`-j20`) spawns ~90 qemu processes and pins all 20 cores. Override for a
  single invocation with `NIX_CONFIG='cores = N'`; raise the setting if native builds need
  more.
- Suspend/GNOME-freeze mitigations live here and must stay when touching boot/sleep config:
  - `hardware.nix`: `i915.enable_dc=0`, `i915.enable_psr=0`, `i915.enable_fbc=0` (post-resume shell freeze: pointer moves but clicks/overview die).
  - `default.nix`: `SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false"` on all four systemd sleep services (KVM deadlock during suspend).
  - `hardware.nix`: `loader.systemd-boot.configurationLimit = 12` (overrides the repo default of 5 in `common/nix.nix`) to keep rollback generations.
- Use the system nix binary from `/nix/store/*-nix-*/bin/nix` for evals if the profile nix misbehaves.
- Verify flake.lock pins a channel commit before deploying (cache-miss/gap-commit issue).
- NVMe/BTRFS read-only mitigations in `hardware.nix`: kernel params
  `nvme_core.default_ps_max_latency_us=0 pcie_aspm=off pcie_port_pm=off`, plus a udev rule
  pinning every NVMe PCI function to full power (`SUBSYSTEM=="pci", DRIVER=="nvme"` — do NOT
  match `KERNEL=="nvme*"` + `SUBSYSTEM=="pci"`, that combination never fires).
- `btrfs-readonly-monitor.service` polls `/home` writability; on failure it self-heals by
  PCI remove+rescan of ONLY the NVMe function backing `/home` (resolved via findmnt ->
  dm-N -> slaves -> nvme class dir), then rw remounts; alerts if still broken. Never widen
  the removal to all NVMe devices — the other drive hosts the root filesystem.
- `services.btrfs.autoScrub` scrubs `/home` weekly (single-device btrfs has no
  redundancy — scrub detects checksum errors, restic restore is the repair path).

## Verification

```sh
# Eval resolved kernel params and generation limit without building
nix eval --raw '.#nixosConfigurations.clawfinger.config.boot.kernelParams' \
  --apply 'p: builtins.concatStringsSep " " p'
nix eval '.#nixosConfigurations.clawfinger.config.boot.loader.systemd-boot.configurationLimit'
nix eval '.#nixosConfigurations.clawfinger.config.nix.settings.cores' # must be 8
# Verify udev rule targets the PCI function (must contain DRIVER=="nvme")
nix eval --raw '.#nixosConfigurations.clawfinger.config.services.udev.extraRules' | grep DRIVER
```

After deploy + reboot: `/proc/cmdline` must contain `i915.enable_dc=0`; `journalctl -b | grep 'froze unit'` should show no user.slice freezing on suspend. After a switch (no reboot required): both `/sys/class/nvme/nvme*/device/power/control` must be `on` and `d3cold_allowed` must be `0`.

## Child DOX Index

Not yet split into child docs; all clawfinger rules live here.
