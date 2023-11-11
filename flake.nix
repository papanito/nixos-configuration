{
  inputs = {
    agenix.url = "github:ryantm/agenix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # tuxedo-nixos = {
    #   url = "github:blitz/tuxedo-nixos";
    #   #inputs.nixpkgs.follows = "nixpkgs";
    # };
    #nix-pentesting.url = "/home/papanito/Workspaces/papanito/nix-pentesting";
  };

  outputs = { self, nixpkgs, agenix }: {
    nixosConfigurations = {
      clawfinger = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          agenix.nixosModules.default
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
  };
}
