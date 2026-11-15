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

- `networking/opensnitch.nix` owns both halves: `services.opensnitch.enable = true`
  (the `opensnitchd` daemon unit; the UI is a client and reports "not running"
  without it) and `services.opensnitch.rules`, which the NixOS module symlinks
  into `/var/lib/opensnitch/rules` on service start. The whole permanent set is
  declared there (migrated from the old GUI rules); add new permanents to
  `allRules` rather than clicking them in the UI.
- Home-manager cannot own these: the UI (`opensnitch-ui`, installed from
  `private_dot_config/private_home-manager/home.nix` in the chezmoi repo) is only a
  client. Rules belong to the root daemon, whose `Rules.Path` is `root:root 0750` — do
  not point it at a user-writable dir, that would let the user inject allow/deny.
- Evaluation is **lexicographic by rule name**, not numeric priority:
  `daemon/rule/loader.go` sorts active rule names and `FindFirstMatch` returns on the
  first `deny`/`reject` **or `precedence`** match, otherwise the last matching allow
  wins. Since `deny-*` sorts after `allow-*`, every declared rule sets
  `precedence = true`, which makes a declared rule authoritative over a GUI-created
  deny. That is deliberate: declaring a rule *is* the policy decision.
- Known overrides: `allow-always-bin-opencode2` and `allow-always-lib-orca-orca-ide`
  now outrank the stray GUI denies for opencode2 and orca-ide. The security denies
  (adb, openssl, python3.14, uv, qoder runtime-info) are untouched — no declared allow
  matches those paths.
- Process rules use `type = "regexp"` (`/nix/store/.*/<binary>`): `simple` compares
  with exact `EqualFold`, so a hash-pinned path would silently stop matching on the
  next upgrade. This was the failure mode of several old GUI rules (a few carried
  regex metacharacters under `type = "simple"`, i.e. they never matched at all).
- OpenSnitch intercepts **loopback** (all traffic traverses the OUTPUT hook), so
  `000-allow-localhost` (`dest.network` `127.0.0.0/8`) is load-bearing: agent CLIs
  spawn a local helper server on loopback and connect to it.
- A `duration` other than `always` expires, and `once` is never registered in the
  running rule set — declarative rules must use `always`.

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
- Kernel policy: `hardware.nix` sets `kernelPackages = pkgs.linuxPackages_latest` — never pin a
  numbered series (`linuxPackages_7_2`). nixpkgs deletes EOL series outright (`error: linux 7.2
  was removed because it has reached its end of life upstream`), which hard-fails evaluation on
  the next lock bump, and any series pin breaks when its own EOL arrives. What actually breaks
  on a kernel bump are the out-of-tree modules: `evdi` (DisplayLink, `extraModulePackages`),
  `tuxedo-drivers` (`hardware.tuxedo-drivers`), `opensnitch-ebpf`. Check them with
  `nix build ".#nixosConfigurations.clawfinger.config.boot.kernelPackages.<name>"`; only the
  channel-default kernel gets cached module builds, so a non-default kernel rebuilds
  `tuxedo-drivers` locally.
- `tuxedo-drivers` carries a local override in `hardware.nix`: nixpkgs' 4.20.1 still registers a
  `struct acpi_driver`, which kernel 7.3 removed (`'struct acpi_driver' has no member named
  'name'`), so the set is `linuxPackages_latest.extend` with the package pinned to upstream
  v4.25.0. 4.25.0 also moved the udev rules to `files/usr/lib/udev/rules.d`, hence the
  `postInstall` override — without it `substituteInPlace` aborts on an unmatched glob. Drop both
  once nixpkgs ships >= 4.25 and the plain package builds.
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
