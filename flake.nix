{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    colmena.url = "github:zhaofengli/colmena";
    terranix.url = "github:terranix/terranix";
    
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, sops-nix, nixos-raspberrypi, colmena,terranix, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      version = "25.11";
      
      # Instantiate pkgs with overlays for use in CLI (nix build .#hello)
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "electron" ]; # Centralized here
        };
        # ALL YOUR OVERLAYS GO HERE
        overlays = [ 
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
          version ? "25.11",
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
            ./modules
            sops-nix.nixosModules.sops
            disko.nixosModules.disko 
            inputs.home-manager.nixosModules.home-manager
            
            ({ ... }: {
              imports =
                lib.optionals (type == "pc") [
                    ./profiles/pc
                  ]
                ++ lib.optionals (type == "server") [
                    ./profiles/servers
                  ]
                ++ lib.optionals (type == "cloud") [ 
                    (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
                  ]
                ++ lib.optionals (type == "rpi") [
                  rpiShim
                ];
            })
          ];

          # RPi-Specific Shim Module
          # This only exists during RPi evaluation to prevent the 'rename.nix' conflict.
          rpiShim = { lib, ... }: {
            disabledModules = [ 
              "system/boot/loader/raspberrypi/raspberrypi.nix"
              "misc/rename.nix" 
            ];
            imports = with nixos-raspberrypi.nixosModules; [
              raspberry-pi-4.base
              raspberry-pi-4.bluetooth
              ./profiles/rpi
              ./profiles/servers
            ];
          };

          specialArgs = { 
            inherit self inputs name isRpi version;
            # Add this line to pass your host database to all modules
            type = type;
            hosts = self.hosts;
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
          inherit deployment moduleList specialArgs system type version;
          pkgs = nixpkgsFor.${system};

          nixosConfig = if isRpi 
            then nixos-raspberrypi.lib.nixosSystemFull { 
              inherit system specialArgs; 
              modules = moduleList;
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
            targetHost = "10.0.0.11";
            targetUser = "nixos";
            # Allows x86_64 machine to build for aarch64 (needs binfmt)
            allowLocalDeployment = true;
          };
        };
      };

      # Standard NixOS Configurations
      nixosConfigurations = builtins.mapAttrs (name: h: h.nixosConfig) self.hosts;
      # --- TERRANIX INJECTION ---
      # This generates the terraform JSON configuration
      packages = forAllSystems (system: {
        hcloud-infra = terranix.lib.terranixConfiguration {
          inherit system;
          modules = [ ./infra/hcloud.nix ]; # Path to your Hetzner resources
        };
      });
 
      # Add terranix & terraform to your devShell
      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          buildInputs = [
            nixpkgsFor.${system}.terraform
            terranix.packages.${system}.terranix
          ];
        };
      });
      
      # Colmena Integration
      colmena = {
        meta = {
          nixpkgs = nixpkgsFor."x86_64-linux"; # Use your pre-defined instance
          nodeNixpkgs = builtins.mapAttrs (name: h: h.pkgs) self.hosts;
          # Pass specialArgs to Colmena nodes
          nodeSpecialArgs = builtins.mapAttrs (name: h: h.specialArgs) self.hosts;
        };
      } // (builtins.mapAttrs (name: h: {
         deployment = h.deployment;
         imports = if h.type == "rpi" then [
          ({ lib, ... }: {
            # 1. We keep the disabledModules here
            disabledModules = [ "system/activation/top-level.nix" ];

            # 2. We define the schema (the 'slots')
            options.system = {
              build.toplevel = lib.mkOption { type = lib.types.unspecified; };
              systemBuilderCommands = lib.mkOption { type = lib.types.unspecified; };
              activatableSystemBuilderCommands = lib.mkOption { type = lib.types.unspecified; };
              stateVersion = lib.mkOption { type = lib.types.str; default = version; };
            };

            # 3. Everything else goes into 'config'
            config = {
              # This is the fix: _module.check belongs inside the config block 
              # when using the explicit options/config split.
              _module.check = false; 

              # Inject the real derivation from your flake
              system.build.toplevel = h.nixosConfig.config.system.build.toplevel;
              system.systemBuilderCommands = h.nixosConfig.config.system.systemBuilderCommands;
              system.activatableSystemBuilderCommands = h.nixosConfig.config.system.activatableSystemBuilderCommands;
              
              # Dummies to satisfy the minimal evaluation requirements
              system.stateVersion = version;
              boot.loader.grub.enable = lib.mkForce false;
              fileSystems."/".device = lib.mkForce "/dev/null";
              
              # Turn off docs to avoid further attribute-missing errors
              documentation.enable = lib.mkForce false;
            };
          })
        ] else h.moduleList;
        }) (nixpkgs.lib.filterAttrs (name: h: h.deployment != null) self.hosts));
    };
}
