{
  system,
  nixpkgsFor,
  ...
}: # Match the arguments passed from flake.nix

let
  pkgs = nixpkgsFor.${system};

  # sudo binary is absent on run0-only hosts; fall back automatically.
  elevDetect = ''
    if [ -z "''${ELEVATOR:-}" ]; then
      if command -v sudo >/dev/null 2>&1; then
        ELEVATOR=sudo
      else
        ELEVATOR=run0
      fi
    fi
  '';

  nixsync = pkgs.writeShellScriptBin "nixsync" ''
    set -eu
    ${elevDetect}
    # Resolve the config working dir (git root when run inside a checkout,
    # else the legacy path).
    if ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" && [ -n "$ROOT" ]; then
      SRC="$ROOT"
    else
      SRC="$HOME/Projects/papanito/nixos-configuration"
    fi
    DEST=/etc/nixos
    # sync config from working dir
    $ELEVATOR rsync -rv "$SRC/" --update --delete --exclude result "$DEST"
  '';

  # Rebuild nixos with my config
  nixreb = pkgs.writeShellScriptBin "nixreb" ''
    set -u
    HOSTNAME=""
    UPGRADE=""
    IMPURE=""
    VERBOSE=""
    REMOTE=""
    SWITCH="switch"
    while getopts "uvish:r:" opt; do
      case $opt in
        u) UPGRADE="--upgrade" ;;
        i)
          IMPURE="--impure"
          export NIXPKGS_ALLOW_INSECURE=1
          ;;
        s) SWITCH="switch" ;;
        v) VERBOSE="--show-trace" ;;
        h) HOSTNAME=$OPTARG ;;
        r) REMOTE="--target-host $OPTARG" ;;
      esac
    done
    shift $((OPTIND - 1))
    ${elevDetect}
    nixsync
    # Source locale for us otherwise perl has issues
    if [ -f "$HOME/.env-us.locale" ]; then
      . "$HOME/.env-us.locale"
    fi
    if [ -f /etc/nixos/flake.nix ]; then
      exec $ELEVATOR nixos-rebuild "$SWITCH" --flake "/etc/nixos#$HOSTNAME" $UPGRADE $REMOTE $IMPURE $VERBOSE
    else
      exec $ELEVATOR nixos-rebuild "$SWITCH" $UPGRADE $IMPURE $VERBOSE
    fi
  '';
in
pkgs.mkShell {
  # Tools available in the environment
  nativeBuildInputs = [
    nixreb
    nixsync
    pkgs.terraform
    pkgs.colmena
    pkgs.hcloud
    pkgs.zsh
    pkgs.terranix
  ];
  shellHook = ''
    echo "NixOS Cloud Expert Shell Loaded"
    alias fu="nix flake update && git add flake.lock && git commit -m'Update flake'"
    alias deploy-hetzner='
      set -e
      export OUT_FILE=infra.tf.json
      echo "--- 1. Generating Infrastructure Code ---"
      nix build .#hcloud-infra --out-link $OUT_FILE

      echo "--- 2. Synchronizing Cloud State (TF Cloud) ---"
      terraform apply

      echo "--- 3. Deploying NixOS via Colmena ---"
      colmena apply
    '
  '';
}
