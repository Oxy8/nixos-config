{
  description = "Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nix-software-center.url = "github:vlinkz/nix-software-center";
  };

  outputs = { nixpkgs, nix-software-center, ... }@inputs:

  let

    system = "x86_64-linux";
        
  in {
    nixosConfigurations = {
      B490 = nixpkgs.lib.nixosSystem {

      	inherit system;

      	specialArgs = { inherit inputs; };

      	modules = [
      	  ./configuration.nix	
      	];
      };	
    };
  };
}
