{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixpkgs-stable = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };
    disko.url = "github:nix-community/disko";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pentesting = {
      url = "/home/papanito/Workspaces/papanito/nix-pentesting";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = { self, nixpkgs, disko, pentesting, sops-nix, ... }@inputs:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
    pkgs = forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      #in { default = import ./pkgs { inherit pkgs; }; }
      in { inherit pkgs; }
    );

    nixosConfigurations = {
      clawfinger = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        inherit system;
        modules = [
          ./configuration.nix
          ./hosts/clawfinger # Include the results of the hardware scan.
          inputs.sops-nix.nixosModules.sops
        ];
      };
      envy = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        inherit system;
        modules = [
          ./configuration.nix
          ./hosts/envy # Include the results of the hardware scan.
          inputs.sops-nix.nixosModules.sops
        ];
      };
      hetzner-cloud = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({modulesPath, ... }: {
            imports = [
              ./configuration.nix
              "${modulesPath}/installer/scan/not-detected.nix"
              "${modulesPath}/profiles/qemu-guest.nix"
              disko.nixosModules.disko
            ];
            disko.devices = import ./single-gpt-disk-fullsize-ext4.nix "/dev/sda";
            boot.loader.grub = {
              devices = [ "/dev/sda" ];
              efiSupport = true;
              efiInstallAsRemovable = true;
            };
            services.openssh.enable = true;

            users.users.root.openssh.authorizedKeys.keys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDDW6I1hIPUBCGNCLa7Rfb++19kqgWwz3oKoyOCGE8csP8W83VNCiNnDxOZf3uASpUtz9ObP67IV7YiSFKOKksC6jt8SpLFCITD2n9EdC1j7Aii6eX/oF4OeFLadi5iOvsnw4Y7exoon4U6FlGlc6PdfBOKTRyB3W+69QT7N0RDuWS7s2M6+lTOxGhlWP+qeYDh5aT8/GVIFXzJCk+0aEShzXvF23BnrfCfDj7owfxNayDCMpTw6wnDQCB535sQtTkK4UtLoOQVAzMOj3h7ErEVPkpYbxLaE36xal55kEWhyLdCwqoDOfEGvB+PSqIJ0WxMYsoRi7b2EazTzyj+TKJ0oUAlw8RecWiJjnqfxIf+fR2bx4fmhurTiVzXm/Iq9dJAO0dOr4YsZlpxeh8G6Cm6TlqbtRF9ULoNrx1bL5hz2aEgTlWEyvFzztap19o0UA8h67uu6YGwpQe4KUh8GO44pxtI0ZqLFTwNhqTYu/jX94g35+X+YflydKCE3nTl3x2Jyg6hzjAALziZmMxY3JfeSD8Y9+TFfJ9P3Vr+Ag6XSX9Vrc30fBOeD9gpNlcZybQBiQSPGPNWd/54R3ob3I6w4IgGhN7T4lqE6THxEOmCwkBzMt/9jo7MePG4qPD7rxsECa+Nf4X6cLCWg7rbZ2AvIqtEhcGOQ+dwRBG9WP+5DQ=="
            ];
          })
        ];
      };
    };
    #devShells.x86_64-linux.default = (import ./shells/cloud.nix { inherit pkgs; });
  };
}
