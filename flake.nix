{
  inputs = {
    agenix.url = "github:ryantm/agenix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    tuxedo-nixos = {
      url = "github:blitz/tuxedo-nixos";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, tuxedo-nixos, agenix }: {
    nixosConfigurations = {
      clawfinger = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          agenix.nixosModules.default
          tuxedo-nixos.nixosModules.default
          { 
            hardware.tuxedo-control-center.enable = true; 
            # tuxedo-control-center.package = tuxedo-nixos.packages.x86_64-linux.default;
          }
        ];
      };
    };
  };
}
