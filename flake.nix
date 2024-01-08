{
  inputs = {
    agenix.url = "github:ryantm/agenix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #home-manager = 
    # tuxedo-nixos = {
    #   url = "github:blitz/tuxedo-nixos";
    #   #inputs.nixpkgs.follows = "nixpkgs";
    # };
    pentesting = {
      url = "/home/papanito/Workspaces/papanito/nix-pentesting";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
    nixosConfigurations = {
      clawfinger = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          inputs.agenix.nixosModules.default
          inputs.pentesting.nixosModules.default
          # tuxedo-nixos.nixosModules.default
          # {
          #   hardware = {
          #     tuxedo-control-center.enable = true;
          #     tuxedo-control-center.package = tuxedo-nixos.packages.x86_64-linux.default;
          #     tuxedo-keyboard.enable = true;
          #   };
          # }
        ];
      };
    };
    devShells.x86_64-linux.default = (import ./shells/cloud.nix {inhreit pkgs; });
  };
}
