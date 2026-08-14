{
  system,
  nixpkgsFor,
  inputs,
  ...
}: # Match the arguments passed from flake.nix

let
  pkgs = nixpkgsFor.${system};
in
pkgs.mkShell {
  # Tools available in the environment
  nativeBuildInputs = [
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
    # @section nixos
    # @description helper functions for nixos

    # @description rebuild nixos with my config
    nixsync () {
       export NIXOSWD=$HOME/Workspaces/papanito/nixos-configuration/
       export NIXOSDIR=/etc/nixos
       # 1. sync config from working dir
       sudo rsync -rv $NIXOSWD --update --delete --exclude result $NIXOSDIR
    }

    # @description rebuild nixos with my config
    nixreb () {
       declare options;
       HOSTNAME=""
       UPGRADE=""
       IMPURE=""
       VERBOSE=""
       REMOTE=""
       while getopts "uvish:r:" options; do
          case ${options} in
             u )
                UPGRADE="--upgrade"
             ;;
             i )
                IMPURE="--impure"
                export NIXPKGS_ALLOW_INSECURE=1
             ;;
             s )
                SWITCH="switch"
             ;;
             v )
                VERBOSE="--show-trace"
             ;;
             h )
                HOSTNAME=$OPTARG
             ;;
             r )
                REMOTE="--target-host $OPTARG"
             ;;
          esac
       done

       nixsync
       # Source loale for us otherwise perl has issues
       source ~/.env-us.locale
       if [[ -f "$NIXOSDIR/flake.nix" ]]; then
          command="sudo nixos-rebuild $SWITCH --flake '.#$HOSTNAME' $UPGRADE $REMOTE $IMPURE $VERBOSE"
          echo $command
          eval "$command"
       else
          sudo nixos-rebuild $SWITCH $UPGRADE $IMPURE $VERBOSE
       fi
    }
  '';
}
