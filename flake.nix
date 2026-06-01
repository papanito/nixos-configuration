{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    colmena.url = "github:zhaofengli/colmena";
    terranix.url = "github:terranix/terranix";
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Add the generator input
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs"; # Forces generator to reuse YOUR nixpkgs version
    };
    # pentesting = {
    #   url = "/home/papanito/Workspaces/papanito/nix-pentesting";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, disko, sops-nix, nixos-raspberrypi, nixos-generators, colmena, terranix, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      pkgs-unstable = nixpkgs-unstable.legacyPackages."x86_64-linux";
      nixosVersion = "26.05";
      system = pkgs.stdenv.hostPlatform.system;

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
          version ? nixosVersion,
          rpiVersion ? "4",
          system ? "x86_64-linux",
          device ? "/dev/sda",
          deployment ? null # New optional argument
        }:
        let
          isRpi = type == "rpi";
          isCloud = type == "cloud";
          isServer = type == "server";
          isPC = type == "pc";

          # Use nixpkgs lib for convenience
          lib = nixpkgs.lib;

          # Define modules common to all, but keep RPi-specific
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
                    inputs.dms.nixosModules.dank-material-shell
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
            imports =[
              nixos-raspberrypi.nixosModules."raspberry-pi-${toString rpiVersion}".base
              nixos-raspberrypi.nixosModules."raspberry-pi-${toString rpiVersion}".bluetooth
              ./profiles/rpi
              ./profiles/servers
            ];
          };

          specialArgs = {
            inherit self inputs name isRpi nixosVersion rpiVersion pkgs-unstable;
            # Add this line to pass your host database to all modules
            type = type;
            hosts = self.hosts;
            isCloud = type == "cloud";
            disko = inputs.disko;
            home-manager = inputs.home-manager;
            dms = inputs.dms;
          }
          // lib.optionalAttrs isRpi {
            inherit nixos-raspberrypi;
          };
        in
        {
          inherit deployment moduleList specialArgs system type nixosVersion rpiVersion;
          pkgs = nixpkgsFor.${system};

          nixosConfig = if isRpi
            then nixos-raspberrypi.lib.nixosInstaller {
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
        envy17 = mkSystem "envy17" {
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
        custom-iso = nixos-generators.nixosGenerate {
          inherit system;
          specialArgs = { inherit self nixosVersion; };
          format = "iso";
          modules = [
            sops-nix.nixosModules.sops
            inputs.home-manager.nixosModules.home-manager
            ./profiles/servers/users
            ({ pkgs, lib, ... }: {
              system.stateVersion = nixosVersion;

              networking = {
                useDHCP = false;
                defaultGateway = "10.0.0.1";
                nameservers = [ "10.0.0.10" ];
                firewall.allowedTCPPorts = [ 22 ];
              };

              # --- FIX: RUNTIME INTERFACE DETECTION & IP ASSIGNMENT ---
              # This script runs ON THE LAPTOP right after the network card drivers load.
              systemd.services.iso-static-ip = {
                description = "Dynamically assign static IP to the physical Ethernet card";
                wantedBy = [ "network-pre.target" ];
                before = [ "network.target" ];
                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                };
                script = ''
                  # 1. Find the first physical ethernet interface name at boot runtime
                  IFACE=$(${pkgs.iproute2}/bin/ip -o link show | ${pkgs.gawk}/bin/awk -F': ' '$2 ~ /^e/ {print $2; exit}')

                  if [ -n "$IFACE" ]; then
                    echo "Found Ethernet interface: $IFACE. Assigning 10.0.0.250/24..."
                    ${pkgs.iproute2}/bin/ip addr add 10.0.0.250/24 dev "$IFACE"
                    ${pkgs.iproute2}/bin/ip link set dev "$IFACE" up
                    # --- FIX: Manually inject default route table parameters onto the interface ---
                    echo "Injecting default gateway routing rules through 10.0.0.1..."
                    ${pkgs.iproute2}/bin/ip route add default via 10.0.0.1 dev "$IFACE" proto static || true
                  else
                    echo "No physical Ethernet interface starting with 'e' was found."
                  fi
                '';
              };
              services.openssh.enable = true;

              # --- FIX: Break the mutableUsers lockdown for the live ISO session ---
              users.mutableUsers = lib.mkForce true;

              # Neutralize SOPS file runtime evaluation barriers for the ephemeral ISO run
              sops.secrets.default_password = {};
              sops.validateSopsFiles = false;

              # Force plain-text fallback credentials specifically on the physical notebook TTY console
              users.users.nixos = {
                hashedPasswordFile = lib.mkForce null;
                initialPassword = "nixos";
              };
              users.users.root = {
                hashedPasswordFile = lib.mkForce null;
                initialPassword = "nixos";
              };

              # Bypasses local sudo permission prompt blocks on the live environment console
              security.sudo.wheelNeedsPassword = lib.mkForce false;
            })
          ];
        };
      });

      devShells = forAllSystems (system: {
        default = import ./shells/default.nix {
          pkgs = nixpkgsFor.${system};
          system = system;
          inputs = inputs;      # Explicitly pass the @inputs set
          terranix = terranix;  # Pass the terranix input specifically
          nixpkgsFor = nixpkgsFor;
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
              stateVersion = lib.mkOption { type = lib.types.str; default = nixosVersion; };
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
              system.stateVersion = nixosVersion;
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
