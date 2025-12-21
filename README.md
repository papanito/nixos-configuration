# My NIXOS Configuration

Setup all my devices using nixos (WIP)

## General Setup

I use [nix-sops](https://github.com/Mic92/sops-nix)

```shell
nix-shell -p sops --run "sops secrets/secrets.yaml"
nix-shell -p spos --run 'sops updatekeys secrets/secrets.yaml'
```

## Setup remote system

```shell
NIX_SSHOPTS="-i /home/papanito/.ssh/id_ssh_admin@envy.ed25519" sudo -E nixos-rebuild  switch  --flake '.#envy' --upgrade --target-host admin@10.0.0.11 --use-remote-sudo 
```

## Raspberry PI

:
FOllows <https://github.com/nvmd/nixos-raspberrypi?tab=readme-ov-file>

nix build .#installerImages.rpi4
