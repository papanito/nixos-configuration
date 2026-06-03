{ lib, ... }:
{
  nix.settings = {
    substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    # Caches in trusted-substituters can be used by unprivileged users i.e. in
    # flakes but are not enabled by default.
    trusted-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
}
