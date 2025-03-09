# My NIXOS Configuration

Setup all my devices using nixos (WIP)

I use [nix-sops](https://github.com/Mic92/sops-nix)

```shell
nix-shell -p sops --run "sops secrets/secrets.yaml"
```

```shell
NIX_SSHOPTS="-i /home/papanito/.ssh/id_ssh_admin@envy.ed25519" sudo -E nixos-rebuild  switch  --flake '.#envy' --upgrade --target-host admin@10.0.0.11 --use-remote-sudo 
```

ix-shell -p spos --run 'sops updatekeys secrets/secrets.yaml'                                                                                                                                                                                        ─╯
