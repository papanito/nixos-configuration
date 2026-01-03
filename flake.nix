{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    colmena.url = "github:zhaofengli/colmena";
    
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    pentesting = {
      url = "/home/papanito/Workspaces/papanito/nix-pentesting";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = { self, nixpkgs, disko, sops-nix, nixos-raspberrypi, colmena, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Instantiate pkgs with overlays for use in CLI (nix build .#hello)
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "electron" ]; # Centralized here
        };
        # ALL YOUR OVERLAYS GO HERE
        overlays = [ 
          # External Flake Overlays (e.g., from your pentesting input)
          # inputs.pentesting.overlays.default 

          # Custom Local Overlays
          (final: prev: {
            pentesting = inputs.pentesting.packages.${system};
          })
          # Architecture-Specific Overlays
          (final: prev: nixpkgs.lib.optionalAttrs prev.stdenv.hostPlatform.isAarch64 {
              # Only override if it actually exists in the upstream nixpkgs
              # Or, if you are trying to pull it from a specific input:
              raspberrypi-utils = if prev ? raspberrypi-utils 
                                  then prev.raspberrypi-utils 
                                  else prev.libraspberrypi; # Fallback for older nixpkgs structures
          })
        ];
      });

      # --- HOST FACTORY ---
      mkSystem = name: { 
          type,
          system ? "x86_64-linux", 
          device ? "/dev/sda",
          deployment ? null # New optional argument
        }: 
        let
          isRpi = type == "rpi";
          isArm = isRpi;
          isCloud = type == "cloud";
          isServer = type == "server";
          isPC = type == "pc";

          # Use nixpkgs lib for convenience
          lib = nixpkgs.lib;
          # 1. Define modules common to all, but keep RPi-specific 
          # declarations out of the global scope.
          moduleList = [
            ./hosts/${name}
            ./common
            sops-nix.nixosModules.sops
            disko.nixosModules.disko 
            inputs.home-manager.nixosModules.home-manager
            
            ({ ... }: {
              imports = lib.optionals (type == "pc") [ ./modules ]
                     ++ lib.optionals (type == "server") [ ./profiles/servers ./modules ]
                     ++ lib.optionals (type == "cloud") [ 
                          (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
                        ];
            })
          ];

          # 2. RPi-Specific Shim Module
          # This only exists during RPi evaluation to prevent the 'rename.nix' conflict.
          rpiShim = { lib, ... }: {
            imports = with nixos-raspberrypi.nixosModules; [
              raspberry-pi-4.base
              raspberry-pi-4.bluetooth
              ./profiles/rpi
              ./profiles/servers
            ];
          };

          specialArgs = { 
            inherit self inputs name isRpi;
            isCloud = type == "cloud";
            isArm = isRpi;
            disko = inputs.disko;
            home-manager = inputs.home-manager;
          }
          // lib.optionalAttrs isRpi {
            inherit nixos-raspberrypi;
          };
        in
        {
          inherit deployment moduleList specialArgs system;
          pkgs = nixpkgsFor.${system};

          nixosConfig = if isRpi 
            then nixos-raspberrypi.lib.nixosInstaller { 
              inherit system specialArgs; 
              # We combine the base modules with our shim
              modules = moduleList ++ [ rpiShim 
              ]; 
            }
            else nixpkgs.lib.nixosSystem { 
              inherit system specialArgs; 
              modules = moduleList; 
            };
        };
    in
    {
      # Helper to define our hosts in one place
      hosts = {
        clawfinger = mkSystem "clawfinger" { 
          type = "pc"; 
        };
        envy = mkSystem "envy" { 
          type = "server"; 
          deployment = {
            targetHost = "10.0.0.10";
            targetUser = "nixos";
          };
        };
        lenovo = mkSystem "lenovo" { 
          type = "server"; 
          deployment = {
            targetHost = "10.0.0.61";
            targetUser = "nixos";
          };
        };
        rpi4-a = mkSystem "rpi4-a" { 
          type = "rpi"; 
          system = "aarch64-linux";
          deployment = {
            targetHost = "10.0.0.1";
            targetUser = "nixos";
            # Allows x86_64 machine to build for aarch64 (needs binfmt)
            allowLocalDeployment = true;
          };
        };
      };

      # Standard NixOS Configurations
      nixosConfigurations = builtins.mapAttrs (name: h: h.nixosConfig) self.hosts;

      # Colmena Integration
      colmena = {
        meta = {
          # Use the nixpkgs from the first x86 host as a default for evaluation
          nixpkgs = import nixpkgs { 
            system = "x86_64-linux"; 
            #config.allowUnfree = true;
          };
          nodeNixpkgs = builtins.mapAttrs (name: h: h.pkgs) self.hosts;
          # Pass specialArgs to Colmena nodes
          nodeSpecialArgs = builtins.mapAttrs (name: h: h.specialArgs) self.hosts;
        };
      } // (builtins.mapAttrs (name: h: {
        imports = h.moduleList;
        deployment = h.deployment;
        # Ensure Colmena uses the correct architecture
        nixpkgs.system = h.system;
      }) (nixpkgs.lib.filterAttrs (name: h: h.deployment != null) self.hosts));
    };
}
