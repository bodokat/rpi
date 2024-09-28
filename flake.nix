{
  description = "My raspberry pi confix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    helix.url = "github:helix-editor/helix";
    deploy-rs.url = "github:serokell/deploy-rs";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-hardware,
      # lix-module,
      deploy-rs,
      ...
    }:
    {
      nixosConfigurations = {

        pi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            nixos-hardware.nixosModules.raspberry-pi-4
            "${nixpkgs}/nixos/modules/profiles/minimal.nix"
            # lix-module.nixosModules.default

            ./configuration.nix
          ];
        };
      };

      # sd card image
      images = {
        pi =
          (self.nixosConfigurations.pi.extendModules {
            modules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              {
                disabledModules = [ "profiles/base.nix" ];
                sdImage.compressImage = false;
              }
            ];
          }).config.system.build.sdImage;
      };

      # deploy-rs configuration
      deploy.nodes.berni-pi = {
        hostname = "Berni-Pi";
        # remoteBuild = true;
        profiles.system = {
          user = "root";
          sshUser = "root";
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pi;
        };
      };
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    };
}
