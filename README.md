# My NIXOS Configuration

Setup all my devices using nixos (WIP)

## General Setup

I use [nix-sops](https://github.com/Mic92/sops-nix)

```shell
nix-shell -p sops --run "sops secrets/secrets.yaml"
nix-shell -p spos --run 'sops updatekeys secrets/secrets.yaml'
```

## Setup remote system

1. Boot system in live mode
2. Use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md)

   ```shell
   nix run github:nix-community/nixos-anywhere -- \
    --flake ".#FLAKE" \
   <nixos@10.0.0.XX>
   ```

3. Install/Update system using [colmena](https://github.com/zhaofengli/colmena)

   ```shell
   colmena apply --on lenovo,envy
   ```

4. Add host key to `.spps.yaml`
5. Update secrets

  ```shell
  sops updatekeys profiles/servers/secrets.yaml
  sops updatekeys secrets/secrets.yaml
  ...
  ```

Alternatively you can also run:

```shell
sudo -E nixos-rebuild switch --flake '.#envy' \
  --upgrade --target-host \
  nixosn@10.0.0.11 --sudo 
```

If there is a problem with ssh, you can specify the key to use:

```shell
NIX_SSHOPTS="-i /home/papanito/.ssh/id_ssh_admin@envy.ed25519"
```

## Raspberry PI

Follows <https://github.com/nvmd/nixos-raspberrypi?tab=readme-ov-file>

1. Build image

  ```shell
  nix build '.#nixosConfigurations.rpi4-demo.config.system.build.sdImage'
  ```

2. Unzstd image

  ```shell
  unzstd result/sd-image/nixos-sd-image-rpi4-uboot.img.zst -o nixos-sd-image-rpi4-uboot.img
  ```

3. Burn it to sdcard

  ```shell
  sudo dd if=nixos-sd-image-rpi4-uboot.img of=/dev/sda bs=4M status=progress
  ```
