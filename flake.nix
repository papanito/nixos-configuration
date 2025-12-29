{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    
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

  outputs = { self, nixpkgs, disko, sops-nix, nixos-raspberrypi, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

# Instantiate pkgs with overlays for use in CLI (nix build .#hello)
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ (final: prev: { pentesting = inputs.pentesting.packages.${system}; }) ];
        config.allowUnfree = true;
      });

      # --- HOST FACTORY ---
      mkSystem = name: { type, system ? "x86_64-linux", device ? "/dev/sda" }: 
        let
          isRpi = type == "rpi";
          isCloud = type == "cloud";
          isServer = type == "server";
      
          # Use nixpkgs lib for convenience
          lib = nixpkgs.lib;

          # 1. Define modules common to all hosts
          moduleList = [
            # Programmatically find the host configuration directory
            ./hosts/${name}

            ./common
            ./modules
            sops-nix.nixosModules.sops

            # Archetype-specific modules
            # Instead of a top-level 'if' which causes recursion in 'imports',
            # we pass a module that conditionally imports based on the variables.
            ({ ... }: {
              imports = lib.optionals isRpi (with nixos-raspberrypi.nixosModules; [
                ./profiles/rpi
                raspberry-pi-4.base
                raspberry-pi-4.bluetooth
              ]) ++ lib.optionals isCloud [
                disko.nixosModules.disko
                (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
              ] ++ lib.optionals isServer [
                ./profiles/servers
              ];
            })
          ];

          # SpecialArgs: safe place for extra variables
          specialArgs = { 
            inherit self inputs name isRpi isCloud;
            isArm = isRpi;
            nixos-raspberrypi = inputs.nixos-raspberrypi;
          };
        in
          # Strictly isolated builder calls
          if isRpi then 
            nixos-raspberrypi.lib.nixosInstaller {
              inherit system specialArgs;
              inherit (inputs) nixos-raspberrypi; # Installer requires this at top-level
              modules = moduleList;
            }
          else 
            nixpkgs.lib.nixosSystem {
              inherit system specialArgs;
              modules = moduleList;
            };
    in
    {
      # Export pkgs for use in shells/scripts
      legacyPackages = forAllSystems (system: nixpkgs.legacyPackages.${system});

      nixosConfigurations = {
        # Standard PCs
        clawfinger = mkSystem "clawfinger" { type = "pc"; };
        # Serverv
        envy       = mkSystem "envy"       { type = "server"; };

        # Raspberry Pi
        rpi4-a     = mkSystem "rpi4-a"     { type = "rpi"; system = "aarch64-linux"; };

        # Cloud
        #hetzner-cloud = mkSystem "hetzner-cloud" { type = "cloud"; device = "/dev/sda"; };
      };
    };
}
