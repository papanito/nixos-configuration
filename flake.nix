{
  inputs = {
    agenix.url = "github:ryantm/agenix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
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

  outputs = { self, nixpkgs, disko, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
    nixosConfigurations = {
      clawfinger = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
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
      hetzner-cloud = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({modulesPath, ... }: {
            imports = [
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
