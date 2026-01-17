{ system, nixpkgsFor, inputs, ...}: # Match the arguments passed from flake.nix

let
  pkgs = nixpkgsFor.${system};
  # Access terranix and colmena from the inputs attribute
  terranix = inputs.terranix.packages.${system}.terranix;
  colmena = inputs.colmena.packages.${system}.colmena;
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
